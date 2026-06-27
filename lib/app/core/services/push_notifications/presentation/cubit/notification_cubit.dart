import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/push_notification_logger.dart';
import '../../domain/entities/notification_payload.dart';
import '../../domain/usecases/get_push_token_usecase.dart';
import '../../domain/usecases/handle_notification_usecase.dart';
import '../../domain/usecases/send_token_to_backend_usecase.dart';

part 'notification_state.dart';

/// Cubit مركزي لإدارة حالة نظام الـ Push Notifications
///
/// ### دوره:
/// - تهيئة نظام الإشعارات عند بداية التطبيق
/// - الحصول على الـ Token وإرساله للـ Backend
/// - توحيد تدفق الإشعارات من FCM وHMS وiOS
/// - التنقل التلقائي عند الضغط على الإشعار
///
/// ### كيفية الاستخدام:
/// ```dart
/// // في initState أو عند تسجيل الدخول
/// context.read<NotificationCubit>().initialize();
///
/// // للتنقل عند الضغط على إشعار — في الـ listener
/// BlocListener<NotificationCubit, NotificationState>(
///   listener: (context, state) {
///     if (state is NotificationTapped) {
///       NotificationNavigator.navigate(state.payload);
///     }
///   },
/// )
/// ```
class NotificationCubit extends Cubit<NotificationState> {
  final GetPushTokenUseCase _getTokenUseCase;
  final SendTokenToBackendUseCase _sendTokenUseCase;
  final HandleNotificationUseCase _handleNotificationUseCase;
  final PushNotificationLogger _logger;

  // Subscriptions داخلية
  StreamSubscription<NotificationPayload>? _foregroundSub;
  StreamSubscription<NotificationPayload>? _tappedSub;
  StreamSubscription<String>? _tokenRefreshSub;

  NotificationCubit({
    required GetPushTokenUseCase getTokenUseCase,
    required SendTokenToBackendUseCase sendTokenUseCase,
    required HandleNotificationUseCase handleNotificationUseCase,
    PushNotificationLogger? logger,
  })  : _getTokenUseCase = getTokenUseCase,
        _sendTokenUseCase = sendTokenUseCase,
        _handleNotificationUseCase = handleNotificationUseCase,
        _logger = logger ?? PushNotificationLogger(),
        super(NotificationInitial());

  // ─────────────────────────────────────────────────────────────────
  //  Initialize — يُستدعى مرة واحدة عند تشغيل التطبيق
  // ─────────────────────────────────────────────────────────────────

  /// تهيئة نظام الإشعارات
  ///
  /// [userId]: معرف المستخدم الحالي (إذا كان مسجلاً).
  ///           يمكن تمريره `null` وإرسال الـ Token لاحقاً عبر [onUserLoggedIn].
  Future<void> initialize({String? userId}) async {
    if (state is NotificationLoading) return;

    emit(NotificationLoading());

    try {
      _logger.i('🚀 NotificationCubit: initializing...');

      // 1. طلب الإذن
      final permResult = await _handleNotificationUseCase.requestPermission();
      if (permResult.isLeft()) {
        _logger.w('Permission denied or failed');
        emit(NotificationPermissionDenied());
        return;
      }

      // 2. جلب الـ Token
      final tokenResult = await _getTokenUseCase.call();

      await tokenResult.fold(
        (failure) async {
          _logger.e('Failed to get push token: ${failure.errorMessage}');
          emit(NotificationError(message: failure.errorMessage ?? 'Token error'));
        },
        (token) async {
          _logger.i('✅ Token obtained [${token.provider.name}]');

          // 3. إرسال للـ Backend إذا كان المستخدم مسجلاً
          if (userId != null) {
            await _sendTokenToBackend(userId: userId, token: token.value, provider: token.provider.name);
          }

          emit(NotificationReady(
            token: token.value,
            provider: token.provider.name,
            platform: token.platform,
          ));
        },
      );

      // 4. التحقق من رسالة الـ Terminated State
      await _checkInitialMessage();

      // 5. الاستماع للتدفقات المستمرة
      _listenToStreams();

      _logger.i('✅ NotificationCubit: fully initialized');
    } catch (e, stack) {
      _logger.e('NotificationCubit init error', error: e, stackTrace: stack);
      emit(NotificationError(
        message: e.toString(),
        isFatal: false,
      ));
    }
  }

  // ─────────────────────────────────────────────────────────────────
  //  يُستدعى بعد تسجيل الدخول — لإرسال Token للـ Backend
  // ─────────────────────────────────────────────────────────────────

  /// إرسال الـ Token للـ Backend بعد تسجيل الدخول
  Future<void> onUserLoggedIn(String userId) async {
    _logger.i('👤 User logged in: sending push token to backend');

    // جلب Token جديد ثم إرساله
    final tokenResult = await _getTokenUseCase.call();

    tokenResult.fold(
      (failure) => _logger.e('Failed to get token after login: ${failure.errorMessage}'),
      (token) => _sendTokenToBackend(
        userId: userId,
        token: token.value,
        provider: token.provider.name,
      ),
    );
  }

  /// إزالة الـ Token عند تسجيل الخروج
  Future<void> onUserLoggedOut(String userId) async {
    _logger.i('👤 User logged out: removing push token');

    final result = await _handleNotificationUseCase.removeToken(userId: userId);
    result.fold(
      (failure) => _logger.e('Failed to remove token: ${failure.errorMessage}'),
      (_) => _logger.i('✅ Token removed from backend'),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  //  Token Refresh — يُستدعى تلقائياً عند تجديد الـ Token
  // ─────────────────────────────────────────────────────────────────

  void _listenToStreams() {
    // الاستماع للـ Token الجديد
    _tokenRefreshSub =
        _handleNotificationUseCase.onTokenRefresh.listen((newToken) {
      _logger.i('🔄 Token refreshed — will re-send on next login');
      emit(NotificationTokenRefreshed(newToken));

      // إعادة إرسال للـ Backend إذا كان المستخدم مسجلاً
      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser != null) {
        _sendTokenToBackend(
          userId: currentUser.id,
          token: newToken,
          provider: 'auto',
        );
      }
    });

    // الاستماع للإشعارات في الـ Foreground
    _foregroundSub =
        _handleNotificationUseCase.onForegroundMessage.listen((payload) {
      _logger.i('📩 Foreground notification: ${payload.title}');
      // لا نُصدر state للـ foreground — الإشعار يُعرض مباشرة
      // لكن يمكن إضافة badge counter أو تحديث UI هنا
    });

    // الاستماع للضغط على الإشعار
    _tappedSub =
        _handleNotificationUseCase.onNotificationTapped.listen((payload) {
      _logger.i('👆 Notification tapped: type=${payload.type.name}');
      emit(NotificationTapped(payload));
    });
  }

  // ─────────────────────────────────────────────────────────────────
  //  Terminated State — رسالة فتحت التطبيق
  // ─────────────────────────────────────────────────────────────────

  Future<void> _checkInitialMessage() async {
    final result = await _handleNotificationUseCase.getInitialMessage();

    result.fold(
      (failure) => _logger.e('Failed to get initial message: ${failure.errorMessage}'),
      (payload) {
        if (payload != null) {
          _logger.i(
              '📩 App opened from terminated state: type=${payload.type.name}');
          // نُصدر NotificationTapped لأن المستخدم ضغط الإشعار
          emit(NotificationTapped(payload));
        }
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────
  //  Topics
  // ─────────────────────────────────────────────────────────────────

  Future<void> subscribeToTopic(String topic) async {
    final result = await _handleNotificationUseCase.subscribeToTopic(topic);
    result.fold(
      (f) => _logger.e('Failed to subscribe to topic $topic: ${f.errorMessage}'),
      (_) => _logger.i('✅ Subscribed to topic: $topic'),
    );
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    final result = await _handleNotificationUseCase.unsubscribeFromTopic(topic);
    result.fold(
      (f) => _logger.e('Failed to unsubscribe from $topic: ${f.errorMessage}'),
      (_) => _logger.i('✅ Unsubscribed from topic: $topic'),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  //  Helper
  // ─────────────────────────────────────────────────────────────────

  Future<void> _sendTokenToBackend({
    required String userId,
    required String token,
    required String provider,
  }) async {
    final tokenResult = await _getTokenUseCase.call();
    tokenResult.fold(
      (failure) => _logger.e('Cannot send: ${failure.errorMessage}'),
      (notificationToken) async {
        final result = await _sendTokenUseCase.call(
          SendTokenParams(
            userId: userId,
            token: notificationToken,
          ),
        );
        result.fold(
          (f) => _logger.e('Backend send failed: ${f.errorMessage}'),
          (_) => _logger.i('✅ Token sent to backend for user: $userId'),
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────
  //  Cleanup
  // ─────────────────────────────────────────────────────────────────

  @override
  Future<void> close() async {
    await _foregroundSub?.cancel();
    await _tappedSub?.cancel();
    await _tokenRefreshSub?.cancel();
    return super.close();
  }
}
