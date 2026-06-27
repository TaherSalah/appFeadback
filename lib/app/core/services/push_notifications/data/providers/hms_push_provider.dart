import 'dart:async';
import 'dart:math';

import 'package:dartz/dartz.dart';
import 'package:huawei_push/huawei_push.dart' as hms;
import 'package:flutter/services.dart';

import '../../../../errors/failure.dart';
import '../../core/push_notification_logger.dart';
import '../../domain/entities/notification_payload.dart';
import 'i_push_provider.dart';

// Removed custom EventChannel. Using hms.Push.getTokenStream directly.

/// تنفيذ Push Provider باستخدام Huawei Push Kit (HMS)
///
/// ### الأجهزة المدعومة:
/// - ✅ Huawei بدون Google Play Services
///
/// ### ملاحظات على API الـ `huawei_push` package:
/// - `Push.getToken('')` → يطلب Token لكن لا يُعيده مباشرة
/// - الـ Token يصل عبر `HmsMessageService.onNewToken()` في Kotlin
/// - نحن نستقبله في Dart عبر EventChannel مخصص في `MuslimDailyApplication`
/// - `Push.onMessageReceivedStream` → يُعيد `Stream<dynamic>` وليس `Stream<RemoteMessage>`
class HmsPushProvider implements IPushProvider {
  final PushNotificationLogger _logger;

  // Stream Controllers
  final StreamController<String> _tokenRefreshController =
      StreamController<String>.broadcast();
  final StreamController<NotificationPayload> _foregroundMessageController =
      StreamController<NotificationPayload>.broadcast();
  final StreamController<NotificationPayload> _notificationTappedController =
      StreamController<NotificationPayload>.broadcast();

  // Subscriptions (dynamic لأن huawei_push يُعيد Stream<dynamic>)
  StreamSubscription<dynamic>? _foregroundSub;
  StreamSubscription<dynamic>? _notificationOpenSub;
  StreamSubscription<dynamic>? _hmsTokenSub;

  bool _isInitialized = false;

  HmsPushProvider({PushNotificationLogger? logger})
      : _logger = logger ?? PushNotificationLogger();

  // ─────────────────────────────────────────────────────────────────
  //  Initialization
  // ─────────────────────────────────────────────────────────────────

  @override
  Future<void> initialize() async {
    if (_isInitialized) {
      _logger.d('HMS already initialized, skipping');
      return;
    }

    try {
      _logger.i('🟡 Initializing Huawei Push Kit...');

      // 1. تفعيل Auto-Initialization
      await hms.Push.setAutoInitEnabled(true);

      // 2. الاستماع للـ Token من hms.Push.getTokenStream
      _hmsTokenSub = hms.Push.getTokenStream.listen(
        (String token) {
          if (token.isNotEmpty) {
            _logger.i('🔄 HMS Token received via getTokenStream');
            _logger.token(token, 'HMS');
            _tokenRefreshController.add(token);
          }
        },
        onError: (e) => _logger.e('HMS token stream error', error: e),
      );

      // 3. الاستماع لرسائل الـ Foreground
      // onMessageReceivedStream يُعيد Stream<dynamic> في huawei_push
      _foregroundSub = hms.Push.onMessageReceivedStream.listen(
        (dynamic message) {
          _logger.i('📩 HMS Foreground message received');
          final payload = _parseMessage(message, isForeground: true);
          if (payload != null) {
            _foregroundMessageController.add(payload);
          }
        },
        onError: (e) => _logger.e('HMS foreground message error', error: e),
      );

      // 4. الاستماع للضغط على الإشعار من الـ Background
      _notificationOpenSub = hms.Push.onNotificationOpenedApp.listen(
        (dynamic message) {
          _logger.i('👆 HMS notification tapped');
          final payload = _parseMessage(message, isForeground: false);
          if (payload != null) {
            _notificationTappedController.add(payload);
          }
        },
        onError: (e) => _logger.e('HMS notification open error', error: e),
      );

      _isInitialized = true;
      _logger.i('✅ HMS initialized successfully');
    } catch (e, stack) {
      _logger.e('❌ HMS initialization failed', error: e, stackTrace: stack);
      rethrow;
    }
  }

  // ─────────────────────────────────────────────────────────────────
  //  Token — الحصول على الـ Token عبر Completer
  //
  //  في huawei_push، getToken() يُطلق الطلب ثم يصل الـ Token
  //  عبر HmsMessageService.onNewToken() → EventChannel → هنا
  // ─────────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, String>> getToken() async {
    try {
      _logger.d('Requesting HMS Push Token...');

      final completer = Completer<String>();
      StreamSubscription<dynamic>? sub;

      // استمع للـ Token القادم من HMS عبر getTokenStream
      sub = hms.Push.getTokenStream.listen(
        (String token) {
          if (token.isNotEmpty && !completer.isCompleted) {
            completer.complete(token);
            sub?.cancel();
          }
        },
        onError: (e) {
          if (!completer.isCompleted) {
            completer.completeError(e);
          }
          sub?.cancel();
        },
      );

      // اطلب الـ Token من HMS — getToken() قد تُعيد void في بعض إصدارات huawei_push
      // لذلك نتجاهل القيمة المُعادة ونعتمد على الـ EventChannel لاستقبال الـ Token
      try {
        // ignore: unnecessary_statements
        hms.Push.getToken('');
      } on PlatformException catch (e) {
        _logger.w('HMS getToken PlatformException: ${e.message}');
        // استمر — الـ Token قد يصل عبر الـ EventChannel
      }

      // انتظر الـ Token لمدة 30 ثانية
      final token = await completer.future.timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          sub?.cancel();
          throw TimeoutException(
            'HMS Token request timed out. '
            'Check: 1) agconnect-services.json exists, '
            '2) App is registered in AppGallery Connect',
          );
        },
      );

      _logger.token(token, 'HMS');
      return Right(token);
    } on TimeoutException catch (e) {
      _logger.e('HMS Token timeout', error: e);
      return Left(HmsFailure(
        errorMessage: e.message ?? 'HMS token timeout after 30s',
        hmsErrorCode: -1,
      ));
    } on PlatformException catch (e) {
      _logger.e('HMS Token PlatformException', error: e);
      return Left(HmsFailure(
        errorMessage: '${e.code}: ${e.message}',
        hmsErrorCode: int.tryParse(e.code),
      ));
    } catch (e, stack) {
      _logger.e('Failed to get HMS token', error: e, stackTrace: stack);
      return Left(HmsFailure(errorMessage: e.toString()));
    }
  }

  @override
  Stream<String> get onTokenRefresh => _tokenRefreshController.stream;

  // ─────────────────────────────────────────────────────────────────
  //  Permission
  // ─────────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, bool>> requestPermission() async {
    // HMS على Android لا يحتاج إذن explicit في API < 33
    // Android 13+ يُعالَج في Repository level عبر permission_handler
    return const Right(true);
  }

  @override
  Future<Either<Failure, bool>> checkPermission() async {
    return const Right(true);
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
      _logger.d('Checking for initial HMS message...');

      // في huawei_push، يمكن الحصول على الـ data من الإشعار الذي فتح التطبيق
      final dynamic initialData = await hms.Push.getInitialNotification();

      if (initialData == null) {
        _logger.d('No initial HMS message found');
        return const Right(null);
      }

      _logger.i('📩 App opened from terminated state via HMS');

      final payload = _parseRawData(initialData, isForeground: false);
      return Right(payload);
    } catch (e, stack) {
      _logger.e('Failed to get initial HMS message',
          error: e, stackTrace: stack);
      return Left(HmsFailure(errorMessage: e.toString()));
    }
  }

  @override
  Stream<NotificationPayload> get onNotificationTapped =>
      _notificationTappedController.stream;

  // ─────────────────────────────────────────────────────────────────
  //  Topics (HMS stub)
  // ─────────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, Unit>> subscribeToTopic(String topic) async {
    _logger.w('HMS: Topic subscription managed via HMS Console ($topic)');
    return const Right(unit);
  }

  @override
  Future<Either<Failure, Unit>> unsubscribeFromTopic(String topic) async {
    return const Right(unit);
  }

  // ─────────────────────────────────────────────────────────────────
  //  Parsing — يتعامل مع أنواع مختلفة من الرسائل
  // ─────────────────────────────────────────────────────────────────

  /// يحاول تحليل الرسالة القادمة بغض النظر عن نوعها (Map أو RemoteMessage)
  NotificationPayload? _parseMessage(dynamic message, {required bool isForeground}) {
    try {
      if (message == null) return null;

      String? title, body, messageId;
      Map<String, dynamic> data = {};

      // محاولة التعامل معه كـ Map (الشائع في huawei_push)
      if (message is Map) {
        final map = Map<String, dynamic>.from(message);
        title = map['title'] as String? ??
            (map['notification'] as Map?)?['title'] as String?;
        body = map['body'] as String? ??
            (map['notification'] as Map?)?['body'] as String?;
        messageId = map['messageId'] as String? ?? map['msgId'] as String?;
        final rawData = map['data'];
        if (rawData is Map) {
          data = Map<String, dynamic>.from(rawData);
        }
      } else {
        // محاولة التعامل معه كـ RemoteMessage عبر dynamic access
        try {
          // هذا آمن — إذا فشل، يُعيد null
          final rm = message;
          title = rm.notification?.title as String?;
          body = rm.notification?.body as String?;
          messageId = rm.messageId as String?;

          // HMS RemoteMessage يستخدم `data` وليس `dataMap`
          final rawData = rm.data;
          if (rawData is Map) {
            data = Map<String, dynamic>.from(rawData);
          }
        } catch (_) {
          // إذا فشل dynamic access، نُنشئ payload فارغ
          _logger.w('HMS: Could not parse message type: ${message.runtimeType}');
        }
      }

      return NotificationPayload.fromDataMap(
        id: messageId ?? _generateId(),
        data: data,
        title: title,
        body: body,
        isForeground: isForeground,
      );
    } catch (e) {
      _logger.e('Error parsing HMS message', error: e);
      return null;
    }
  }

  /// تحليل البيانات الخام من getInitialNotification
  NotificationPayload? _parseRawData(dynamic data, {required bool isForeground}) {
    try {
      final map = data is Map ? Map<String, dynamic>.from(data) : <String, dynamic>{};
      return NotificationPayload.fromDataMap(
        id: _generateId(),
        data: map,
        title: map['title'] as String?,
        body: map['body'] as String?,
        isForeground: isForeground,
      );
    } catch (_) {
      return null;
    }
  }

  String _generateId() =>
      DateTime.now().millisecondsSinceEpoch.toString() +
      Random().nextInt(9999).toString();

  // ─────────────────────────────────────────────────────────────────
  //  Cleanup
  // ─────────────────────────────────────────────────────────────────

  Future<void> dispose() async {
    await _hmsTokenSub?.cancel();
    await _foregroundSub?.cancel();
    await _notificationOpenSub?.cancel();
    await _tokenRefreshController.close();
    await _foregroundMessageController.close();
    await _notificationTappedController.close();
  }
}
