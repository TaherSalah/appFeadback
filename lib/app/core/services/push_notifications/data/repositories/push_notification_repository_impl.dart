import 'dart:async';
import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:dartz/dartz.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../errors/failure.dart';
import '../../core/device_push_detector.dart';
import '../../core/notification_channels_manager.dart';
import '../../core/push_notification_logger.dart';
import '../datasources/token_local_datasource.dart';
import '../datasources/token_remote_datasource.dart';
import '../providers/fcm_push_provider.dart';
import '../providers/hms_push_provider.dart';
import '../providers/i_push_provider.dart';
import '../../domain/entities/notification_payload.dart';
import '../../domain/entities/notification_token.dart';
import '../../domain/repositories/push_notification_repository.dart';

/// التنفيذ الكامل لـ PushNotificationRepository
///
/// ### مسؤولياته:
/// 1. يستخدم [DevicePushDetector] لاكتشاف نوع الـ Provider
/// 2. يختار [FcmPushProvider] أو [HmsPushProvider] تلقائياً
/// 3. يُنسّق بين [TokenLocalDataSource] و [TokenRemoteDataSource]
/// 4. يعرض الإشعارات في الـ Foreground باستخدام [AwesomeNotifications]
///
/// ### النمط المستخدم: Strategy Pattern
class PushNotificationRepositoryImpl implements PushNotificationRepository {
  final DevicePushDetector _detector;
  final FcmPushProvider _fcmProvider;
  final HmsPushProvider _hmsProvider;
  final TokenLocalDataSource _localDataSource;
  final TokenRemoteDataSource _remoteDataSource;
  final PushNotificationLogger _logger;

  // الـ Provider المُختار للجهاز الحالي
  IPushProvider? _activeProvider;
  DevicePushCapability? _capability;

  // Stream Controller للـ Repository
  final StreamController<NotificationPayload> _tappedController =
      StreamController<NotificationPayload>.broadcast();

  // Subscriptions
  StreamSubscription<NotificationPayload>? _fcmForegroundSub;
  StreamSubscription<NotificationPayload>? _hmsForegroundSub;
  StreamSubscription<NotificationPayload>? _fcmTappedSub;
  StreamSubscription<NotificationPayload>? _hmsTappedSub;
  StreamSubscription<String>? _tokenRefreshSub;

  PushNotificationRepositoryImpl({
    required DevicePushDetector detector,
    required FcmPushProvider fcmProvider,
    required HmsPushProvider hmsProvider,
    required TokenLocalDataSource localDataSource,
    required TokenRemoteDataSource remoteDataSource,
    required PushNotificationLogger logger,
  })  : _detector = detector,
        _fcmProvider = fcmProvider,
        _hmsProvider = hmsProvider,
        _localDataSource = localDataSource,
        _remoteDataSource = remoteDataSource,
        _logger = logger;

  // ─────────────────────────────────────────────────────────────────
  //  Initialization
  // ─────────────────────────────────────────────────────────────────

  Future<void> initialize() async {
    try {
      _logger.i('🚀 Initializing PushNotificationRepository...');

      // 1. اكتشاف الجهاز
      _capability = await _detector.detectCapability();
      _logger.i('📱 Device capability: ${_capability!.provider.name}');

      // 2. اختيار وتهيئة الـ Provider
      switch (_capability!.provider) {
        case PushProvider.fcm:
        case PushProvider.apns:
          _activeProvider = _fcmProvider;
          await _fcmProvider.initialize();
          _setupFcmStreams();
          break;

        case PushProvider.hms:
          _activeProvider = _hmsProvider;
          await _hmsProvider.initialize();
          _setupHmsStreams();
          break;

        case PushProvider.none:
          _logger.w('⚠️ No push provider available on this device');
          break;
      }

      // 3. تهيئة Push Channels في awesome_notifications
      await NotificationChannelsManager.createPushChannels();

      // 4. الاستماع لتجديدات الـ Token
      _setupTokenRefreshListener();

      _logger.i('✅ Repository initialized [${_capability!.provider.name}]');
    } catch (e, stack) {
      _logger.e('❌ Repository initialization failed',
          error: e, stackTrace: stack);
      rethrow;
    }
  }

  // ─────────────────────────────────────────────────────────────────
  //  Token Management
  // ─────────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, NotificationToken>> getPushToken() async {
    if (_activeProvider == null) {
      return Left(NoPushServiceFailure());
    }

    final result = await _activeProvider!.getToken();

    return result.fold(
      (failure) => Left(failure),
      (tokenValue) {
        final token = NotificationToken(
          value: tokenValue,
          provider: _capability?.provider ?? PushProvider.none,
          platform: _getPlatformString(),
          updatedAt: DateTime.now(),
        );
        _localDataSource.saveToken(token);
        return Right(token);
      },
    );
  }

  @override
  Stream<NotificationToken> get onTokenRefresh {
    if (_activeProvider == null) return const Stream.empty();

    return _activeProvider!.onTokenRefresh.map((tokenValue) => NotificationToken(
          value: tokenValue,
          provider: _capability?.provider ?? PushProvider.none,
          platform: _getPlatformString(),
          updatedAt: DateTime.now(),
        ));
  }

  @override
  Future<Either<Failure, Unit>> sendTokenToBackend({
    required String userId,
    required NotificationToken token,
  }) async {
    try {
      final hasChanged = _localDataSource.hasTokenChanged(token.value);
      final notSentBefore = !_localDataSource.isTokenSentToBackend();

      if (!hasChanged && !notSentBefore) {
        _logger.d('Token unchanged and already sent — skipping');
        return const Right(unit);
      }

      await _remoteDataSource.upsertToken(userId: userId, token: token);
      await _localDataSource.saveToken(token);
      await _localDataSource.markAsSent();

      _logger.i('✅ Token sent to backend');
      return const Right(unit);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e, stack) {
      _logger.e('Failed to send token to backend', error: e, stackTrace: stack);
      return Left(ServerFailure(errorMessage: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> removeTokenFromBackend({
    required String userId,
  }) async {
    try {
      final savedToken = _localDataSource.getSavedToken();
      if (savedToken == null || savedToken.isEmpty) {
        return const Right(unit);
      }

      await _remoteDataSource.deactivateToken(
        userId: userId,
        tokenValue: savedToken.value,
      );
      await _localDataSource.clearToken();

      _logger.i('✅ Token removed from backend');
      return const Right(unit);
    } catch (e, stack) {
      _logger.e('Failed to remove token', error: e, stackTrace: stack);
      return Left(ServerFailure(errorMessage: e.toString()));
    }
  }

  // ─────────────────────────────────────────────────────────────────
  //  Permission
  // ─────────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, bool>> requestPermission() async {
    try {
      // Android 13+ يحتاج POST_NOTIFICATIONS permission
      if (Platform.isAndroid) {
        final sdkVersion = await _getAndroidSdkVersion();
        if (sdkVersion >= 33) {
          final status = await Permission.notification.request();
          if (status.isDenied || status.isPermanentlyDenied) {
            return Left(PermissionFailure());
          }
        }
      }

      if (_activeProvider != null) {
        return _activeProvider!.requestPermission();
      }

      return const Right(true);
    } catch (e) {
      return Left(PermissionFailure(errorMessage: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> checkPermissionStatus() async {
    if (_activeProvider != null) {
      return _activeProvider!.checkPermission();
    }
    return const Right(false);
  }

  // ─────────────────────────────────────────────────────────────────
  //  Message Streams
  // ─────────────────────────────────────────────────────────────────

  @override
  Stream<NotificationPayload> get onForegroundMessage {
    if (_capability == null) return const Stream.empty();
    if (_capability!.isHmsOnly) return _hmsProvider.onForegroundMessage;
    return _fcmProvider.onForegroundMessage;
  }

  @override
  Future<Either<Failure, NotificationPayload?>> getInitialMessage() async {
    if (_activeProvider == null) return const Right(null);
    return _activeProvider!.getInitialMessage();
  }

  @override
  Stream<NotificationPayload> get onNotificationTapped =>
      _tappedController.stream;

  // ─────────────────────────────────────────────────────────────────
  //  Topics
  // ─────────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, Unit>> subscribeToTopic(String topic) async {
    if (_activeProvider == null) return const Right(unit);
    return _activeProvider!.subscribeToTopic(topic);
  }

  @override
  Future<Either<Failure, Unit>> unsubscribeFromTopic(String topic) async {
    if (_activeProvider == null) return const Right(unit);
    return _activeProvider!.unsubscribeFromTopic(topic);
  }

  // ─────────────────────────────────────────────────────────────────
  //  Local Notification — باستخدام awesome_notifications
  // ─────────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, Unit>> showLocalNotification(
    NotificationPayload payload,
  ) async {
    try {
      final isAllowed = await AwesomeNotifications().isNotificationAllowed();
      if (!isAllowed) {
        _logger.w('Notification permission not granted — skipping local notification');
        return Left(PermissionFailure());
      }

      final notificationId = _generateNotificationId();

      // اختيار الـ Channel المناسب لنوع الإشعار
      final channelKey = NotificationChannelsManager.getChannelForType(
        payload.type.name,
      );

      // بناء payload map (يجب أن تكون قيمه Strings فقط)
      final payloadMap = <String, String>{
        'id': payload.id,
        'type': payload.type.name,
        if (payload.targetId != null) 'target_id': payload.targetId!,
        if (payload.routePath != null) 'route': payload.routePath!,
        ...payload.data.map((k, v) => MapEntry(k, v.toString())),
      };

      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: notificationId,
          channelKey: channelKey,
          title: payload.title,
          body: payload.body,
          notificationLayout: payload.imageUrl != null
              ? NotificationLayout.BigPicture
              : NotificationLayout.BigText,
          bigPicture: payload.imageUrl,
          payload: payloadMap,
          autoDismissible: true,
          showWhen: true,
        ),
      );

      _logger.d('🔔 Local notification shown via AwesomeNotifications (id: $notificationId)');
      return const Right(unit);
    } catch (e, stack) {
      _logger.e('Failed to show local notification', error: e, stackTrace: stack);
      return Left(PushNotificationFailure(errorMessage: e.toString()));
    }
  }

  // ─────────────────────────────────────────────────────────────────
  //  Private Helpers
  // ─────────────────────────────────────────────────────────────────

  void _setupFcmStreams() {
    _fcmForegroundSub = _fcmProvider.onForegroundMessage.listen((payload) {
      _logger.d('FCM foreground → showing local notification');
      showLocalNotification(payload);
    });

    _fcmTappedSub = _fcmProvider.onNotificationTapped.listen((payload) {
      _tappedController.add(payload);
    });
  }

  void _setupHmsStreams() {
    _hmsForegroundSub = _hmsProvider.onForegroundMessage.listen((payload) {
      _logger.d('HMS foreground → showing local notification');
      showLocalNotification(payload);
    });

    _hmsTappedSub = _hmsProvider.onNotificationTapped.listen((payload) {
      _tappedController.add(payload);
    });
  }

  void _setupTokenRefreshListener() {
    if (_activeProvider == null) return;

    _tokenRefreshSub = _activeProvider!.onTokenRefresh.listen((tokenValue) {
      _logger.i('🔄 Token refreshed — saving locally');
      final token = NotificationToken(
        value: tokenValue,
        provider: _capability?.provider ?? PushProvider.none,
        platform: _getPlatformString(),
        updatedAt: DateTime.now(),
      );
      _localDataSource.saveToken(token);
    });
  }

  String _getPlatformString() {
    if (Platform.isIOS) return 'ios';
    if (_capability?.isHmsOnly == true) return 'huawei';
    return 'android';
  }

  Future<int> _getAndroidSdkVersion() async {
    if (!Platform.isAndroid) return 0;
    try {
      final versionStr = Platform.operatingSystemVersion;
      final match = RegExp(r'API (\d+)').firstMatch(versionStr);
      if (match != null) return int.tryParse(match.group(1) ?? '0') ?? 0;
      return 0;
    } catch (_) {
      return 0;
    }
  }

  int _generateNotificationId() {
    return DateTime.now().millisecondsSinceEpoch % 100000;
  }

  Future<void> dispose() async {
    await _fcmForegroundSub?.cancel();
    await _hmsForegroundSub?.cancel();
    await _fcmTappedSub?.cancel();
    await _hmsTappedSub?.cancel();
    await _tokenRefreshSub?.cancel();
    await _tappedController.close();
  }
}
