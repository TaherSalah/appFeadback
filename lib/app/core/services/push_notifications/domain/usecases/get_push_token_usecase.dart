import 'package:dartz/dartz.dart';

import '../../../../errors/failure.dart';
import '../entities/notification_token.dart';
import '../repositories/push_notification_repository.dart';

/// UseCase: الحصول على Push Token للجهاز الحالي
///
/// يُستخدم في:
/// 1. عند تسجيل الدخول لإرسال الـ Token للـ Backend
/// 2. عند بدء التطبيق للتحقق من صحة الـ Token المحفوظ
///
/// يكتشف تلقائياً:
/// - GMS (Google): يستخدم FCM
/// - Huawei بدون GMS: يستخدم HMS
/// - iOS: يستخدم APNs عبر FCM
class GetPushTokenUseCase {
  final PushNotificationRepository _repository;

  const GetPushTokenUseCase(this._repository);

  /// تنفيذ الـ UseCase
  Future<Either<Failure, NotificationToken>> call() async {
    return _repository.getPushToken();
  }
}
