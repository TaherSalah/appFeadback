import 'package:dartz/dartz.dart';

import '../../../../errors/failure.dart';
import '../entities/notification_payload.dart';
import '../entities/notification_token.dart';

/// العقد (Contract) الذي يجب أن تُنفّذه طبقة Data
///
/// باقي التطبيق (Cubit, UseCases) يتعامل مع هذه الواجهة فقط
/// ولا يعرف شيئاً عن FCM أو HMS أو أي تقنية أخرى.
///
/// هذا يُطبّق مبدأ Dependency Inversion من SOLID.
abstract class PushNotificationRepository {
  // ─────────────────────────────────────────
  //  Token Management
  // ─────────────────────────────────────────

  /// الحصول على Push Token للجهاز الحالي
  ///
  /// يكتشف تلقائياً هل الجهاز يستخدم FCM أم HMS ويعيد الـ Token المناسب
  Future<Either<Failure, NotificationToken>> getPushToken();

  /// الاستماع لتغييرات الـ Token تلقائياً
  ///
  /// عند تجديد FCM/HMS للـ Token، يُرسل الجديد للـ Backend فوراً
  Stream<NotificationToken> get onTokenRefresh;

  /// إرسال الـ Token للـ Backend (Supabase)
  ///
  /// [userId] المستخدم المرتبط بهذا الـ Token
  /// [token] التفاصيل الكاملة للـ Token
  Future<Either<Failure, Unit>> sendTokenToBackend({
    required String userId,
    required NotificationToken token,
  });

  /// حذف الـ Token من الـ Backend عند تسجيل الخروج
  Future<Either<Failure, Unit>> removeTokenFromBackend({
    required String userId,
  });

  // ─────────────────────────────────────────
  //  Permission Management
  // ─────────────────────────────────────────

  /// طلب إذن الإشعارات من المستخدم
  ///
  /// مطلوب على iOS دائماً، وعلى Android 13+ (API 33)
  Future<Either<Failure, bool>> requestPermission();

  /// التحقق من حالة الإذن الحالية
  Future<Either<Failure, bool>> checkPermissionStatus();

  // ─────────────────────────────────────────
  //  Message Handling
  // ─────────────────────────────────────────

  /// Stream للإشعارات الواردة وقت التطبيق في الـ Foreground
  Stream<NotificationPayload> get onForegroundMessage;

  /// الحصول على الإشعار الذي فتح التطبيق من حالة Terminated
  ///
  /// يُستدعى مرة واحدة عند بدء التطبيق
  Future<Either<Failure, NotificationPayload?>> getInitialMessage();

  /// Stream للإشعارات التي ضغط عليها المستخدم وهو في الـ Background
  Stream<NotificationPayload> get onNotificationTapped;

  // ─────────────────────────────────────────
  //  Topic Subscription
  // ─────────────────────────────────────────

  /// الاشتراك في topic لاستلام إشعارات جماعية
  ///
  /// ملاحظة: Topics متاحة في FCM فقط. على HMS يُستخدم بديل (Conditions)
  Future<Either<Failure, Unit>> subscribeToTopic(String topic);

  /// إلغاء الاشتراك من topic
  Future<Either<Failure, Unit>> unsubscribeFromTopic(String topic);

  // ─────────────────────────────────────────
  //  Local Notifications
  // ─────────────────────────────────────────

  /// عرض إشعار محلي فوري (بدون إرسال من الـ Backend)
  ///
  /// يُستخدم لعرض إشعارات الـ Foreground أو إشعارات الأذكار
  Future<Either<Failure, Unit>> showLocalNotification(
    NotificationPayload payload,
  );
}
