import 'dart:async';
import 'dart:math';

import 'package:dartz/dartz.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../../../errors/failure.dart';
import '../../core/push_notification_logger.dart';
import '../../domain/entities/notification_payload.dart';
import 'i_push_provider.dart';

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ⚠️ IMPORTANT: يجب أن تكون هذه الدالة Top-Level (خارج أي class)
//    لأن Firebase تستدعيها في Isolate منفصل عند Background
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

/// معالج الرسائل في الـ Background/Terminated
///
/// يُستدعى عندما يكون التطبيق في الـ Background أو مغلقاً تماماً
/// وتصل رسالة Data-Only (بدون Notification payload).
///
/// ⚠️ قواعد مهمة:
/// - يجب أن تكون Top-Level function (خارج أي class)
/// - لا يمكن استخدام أي Flutter widgets هنا
/// - يجب تهيئة Firebase قبل أي عملية
@pragma('vm:entry-point')
Future<void> firebaseBackgroundMessageHandler(RemoteMessage message) async {
  // Firebase تُهيّئ نفسها تلقائياً في Background Isolate
  // لا حاجة لاستدعاء Firebase.initializeApp() في الإصدارات الحديثة

  // يمكن هنا:
  // 1. تحديث قاعدة بيانات محلية
  // 2. تشغيل إشعار محلي (باستخدام flutter_local_notifications)
  // 3. إرسال تحليلات

  // ملاحظة: هذا الـ Handler يعمل في Data-Only messages فقط
  // الرسائل التي تحتوي على notification payload تُعالج تلقائياً
  // من قِبل نظام Android بدون الحاجة لهذا الـ Handler
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

/// تنفيذ Push Provider باستخدام Firebase Cloud Messaging
///
/// ### المسؤوليات:
/// - تهيئة Firebase Messaging
/// - جلب FCM Token
/// - الاستماع لتغييرات الـ Token
/// - معالجة الرسائل في الـ Foreground / Background / Terminated
/// - إدارة الـ Topics
///
/// ### الأجهزة المدعومة:
/// - ✅ Android (مع Google Play Services)
/// - ✅ iOS (يُدير APNs تلقائياً)
class FcmPushProvider implements IPushProvider {
  final PushNotificationLogger _logger;

  // Stream Controllers
  final StreamController<String> _tokenRefreshController =
      StreamController<String>.broadcast();
  final StreamController<NotificationPayload> _foregroundMessageController =
      StreamController<NotificationPayload>.broadcast();
  final StreamController<NotificationPayload> _notificationTappedController =
      StreamController<NotificationPayload>.broadcast();

  // Subscriptions داخلية
  StreamSubscription<String>? _tokenRefreshSub;
  StreamSubscription<RemoteMessage>? _foregroundSub;
  StreamSubscription<RemoteMessage>? _backgroundTapSub;

  bool _isInitialized = false;

  final FirebaseMessaging? _injectedMessaging;
  FirebaseMessaging get _messaging => _injectedMessaging ?? FirebaseMessaging.instance;

  FcmPushProvider({
    FirebaseMessaging? messaging,
    PushNotificationLogger? logger,
  })  : _injectedMessaging = messaging,
        _logger = logger ?? PushNotificationLogger();

  // ─────────────────────────────────────────────────────────────────
  //  Initialization
  // ─────────────────────────────────────────────────────────────────

  @override
  Future<void> initialize() async {
    if (_isInitialized) {
      _logger.d('FCM already initialized, skipping');
      return;
    }

    try {
      _logger.i('🔥 Initializing Firebase Cloud Messaging...');

      // 1. تسجيل Background Handler (يجب قبل أي listener آخر)
      FirebaseMessaging.onBackgroundMessage(firebaseBackgroundMessageHandler);

      // 2. إعداد iOS: إذن APNs التلقائي + تعطيل عرض الـ Banner تلقائياً
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: false, // نحن نعرضها يدوياً عبر flutter_local_notifications
        badge: true,
        sound: true,
      );

      // 3. الاستماع لتغييرات الـ Token
      _tokenRefreshSub = _messaging.onTokenRefresh.listen(
        (token) {
          _logger.i('🔄 FCM Token refreshed');
          _logger.token(token, 'FCM');
          _tokenRefreshController.add(token);
        },
        onError: (e) => _logger.e('FCM token refresh error', error: e),
      );

      // 4. الاستماع للرسائل في الـ Foreground
      _foregroundSub = FirebaseMessaging.onMessage.listen(
        (message) {
          _logger.i(
              '📩 FCM Foreground message: ${message.notification?.title}');
          final payload = _mapToPayload(message, isForeground: true);
          _foregroundMessageController.add(payload);
        },
        onError: (e) => _logger.e('FCM foreground message error', error: e),
      );

      // 5. الاستماع لفتح التطبيق من إشعار Background
      _backgroundTapSub = FirebaseMessaging.onMessageOpenedApp.listen(
        (message) {
          _logger.i(
              '👆 FCM notification tapped (background): ${message.notification?.title}');
          final payload = _mapToPayload(message, isForeground: false);
          _notificationTappedController.add(payload);
        },
        onError: (e) => _logger.e('FCM background tap error', error: e),
      );

      _isInitialized = true;
      _logger.i('✅ FCM initialized successfully');
    } catch (e, stack) {
      _logger.e('❌ FCM initialization failed', error: e, stackTrace: stack);
      rethrow;
    }
  }

  // ─────────────────────────────────────────────────────────────────
  //  Token
  // ─────────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, String>> getToken() async {
    try {
      _logger.d('Getting FCM token...');

      // على iOS يجب الحصول على APNs Token أولاً
      final apnsToken = await _messaging.getAPNSToken();
      if (apnsToken != null) {
        _logger.d('APNs token available: ready for FCM');
      }

      final token = await _messaging.getToken();
      if (token == null || token.isEmpty) {
        return Left(
          PushNotificationFailure(
            errorMessage: 'FCM returned null token. Check Firebase setup.',
            code: 'NULL_TOKEN',
          ),
        );
      }

      _logger.token(token, 'FCM');
      return Right(token);
    } catch (e, stack) {
      _logger.e('Failed to get FCM token', error: e, stackTrace: stack);
      return Left(PushNotificationFailure(errorMessage: e.toString()));
    }
  }

  @override
  Stream<String> get onTokenRefresh => _tokenRefreshController.stream;

  // ─────────────────────────────────────────────────────────────────
  //  Permission
  // ─────────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, bool>> requestPermission() async {
    try {
      _logger.i('Requesting FCM notification permission...');

      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false, // true = iOS: إذن مؤقت بدون سؤال
        criticalAlert: false,
        carPlay: false,
        announcement: false,
      );

      final isGranted =
          settings.authorizationStatus == AuthorizationStatus.authorized ||
              settings.authorizationStatus == AuthorizationStatus.provisional;

      _logger.i(
          'FCM Permission result: ${settings.authorizationStatus.name} → ${isGranted ? "GRANTED" : "DENIED"}');

      return Right(isGranted);
    } catch (e, stack) {
      _logger.e('Failed to request FCM permission', error: e, stackTrace: stack);
      return Left(PermissionFailure(errorMessage: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> checkPermission() async {
    try {
      final settings = await _messaging.getNotificationSettings();
      final isGranted =
          settings.authorizationStatus == AuthorizationStatus.authorized ||
              settings.authorizationStatus == AuthorizationStatus.provisional;
      return Right(isGranted);
    } catch (e) {
      return Left(PermissionFailure(errorMessage: e.toString()));
    }
  }

  // ─────────────────────────────────────────────────────────────────
  //  Message Handling
  // ─────────────────────────────────────────────────────────────────

  @override
  Stream<NotificationPayload> get onForegroundMessage =>
      _foregroundMessageController.stream;

  @override
  Future<Either<Failure, NotificationPayload?>> getInitialMessage() async {
    try {
      _logger.d('Checking for initial FCM message (Terminated state)...');
      final message = await _messaging.getInitialMessage();

      if (message == null) {
        _logger.d('No initial FCM message found');
        return const Right(null);
      }

      _logger.i(
          '📩 App opened from terminated state via FCM: ${message.notification?.title}');
      final payload = _mapToPayload(message, isForeground: false);
      return Right(payload);
    } catch (e, stack) {
      _logger.e('Failed to get initial FCM message',
          error: e, stackTrace: stack);
      return Left(PushNotificationFailure(errorMessage: e.toString()));
    }
  }

  @override
  Stream<NotificationPayload> get onNotificationTapped =>
      _notificationTappedController.stream;

  // ─────────────────────────────────────────────────────────────────
  //  Topics
  // ─────────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, Unit>> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      _logger.i('✅ Subscribed to FCM topic: $topic');
      return const Right(unit);
    } catch (e) {
      _logger.e('Failed to subscribe to topic: $topic', error: e);
      return Left(PushNotificationFailure(errorMessage: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      _logger.i('✅ Unsubscribed from FCM topic: $topic');
      return const Right(unit);
    } catch (e) {
      _logger.e('Failed to unsubscribe from topic: $topic', error: e);
      return Left(PushNotificationFailure(errorMessage: e.toString()));
    }
  }

  // ─────────────────────────────────────────────────────────────────
  //  Mapping RemoteMessage → NotificationPayload
  // ─────────────────────────────────────────────────────────────────

  NotificationPayload _mapToPayload(
    RemoteMessage message, {
    required bool isForeground,
  }) {
    final data = Map<String, dynamic>.from(message.data);

    return NotificationPayload.fromDataMap(
      id: message.messageId ?? _generateId(),
      data: data,
      title: message.notification?.title,
      body: message.notification?.body,
      imageUrl: message.notification?.android?.imageUrl ??
          message.notification?.apple?.imageUrl,
      isForeground: isForeground,
    );
  }

  String _generateId() =>
      DateTime.now().millisecondsSinceEpoch.toString() +
      Random().nextInt(9999).toString();

  // ─────────────────────────────────────────────────────────────────
  //  Cleanup
  // ─────────────────────────────────────────────────────────────────

  Future<void> dispose() async {
    await _tokenRefreshSub?.cancel();
    await _foregroundSub?.cancel();
    await _backgroundTapSub?.cancel();
    await _tokenRefreshController.close();
    await _foregroundMessageController.close();
    await _notificationTappedController.close();
  }
}
