part of 'notification_cubit.dart';

/// حالات النظام الموحد للـ Push Notifications
abstract class NotificationState {}

/// الحالة الأولية — قبل أي تهيئة
class NotificationInitial extends NotificationState {}

/// جاري التهيئة
class NotificationLoading extends NotificationState {}

/// تمت التهيئة بنجاح
class NotificationReady extends NotificationState {
  final String token;
  final String provider;
  final String platform;

  NotificationReady({
    required this.token,
    required this.provider,
    required this.platform,
  });

  @override
  String toString() =>
      'NotificationReady(provider: $provider, platform: $platform)';
}

/// تم استلام إشعار في الـ Foreground
class NotificationReceived extends NotificationState {
  final NotificationPayload payload;
  NotificationReceived(this.payload);
}

/// تم الضغط على إشعار → يجب التنقل
class NotificationTapped extends NotificationState {
  final NotificationPayload payload;
  NotificationTapped(this.payload);
}

/// تم تحديث الـ Token تلقائياً
class NotificationTokenRefreshed extends NotificationState {
  final String newToken;
  NotificationTokenRefreshed(this.newToken);
}

/// خطأ في النظام
class NotificationError extends NotificationState {
  final String message;
  final bool isFatal;

  NotificationError({
    required this.message,
    this.isFatal = false,
  });

  @override
  String toString() => 'NotificationError(message: $message, fatal: $isFatal)';
}

/// المستخدم رفض الإذن
class NotificationPermissionDenied extends NotificationState {}

/// إشعار جاهز للعرض في الخلفية (لا يغير الـ state الحالي)
class NotificationBackground extends NotificationState {}
