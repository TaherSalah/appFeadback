import 'package:dartz/dartz.dart';

import '../../../../errors/failure.dart';
import '../entities/notification_token.dart';
import '../repositories/push_notification_repository.dart';

/// بارامترات إرسال الـ Token للـ Backend
class SendTokenParams {
  /// معرّف المستخدم في Supabase
  final String userId;

  /// بيانات الـ Token المراد إرسالها
  final NotificationToken token;

  const SendTokenParams({
    required this.userId,
    required this.token,
  });
}

/// UseCase: إرسال Push Token إلى Supabase Backend
///
/// يُستدعى في هذه الحالات:
/// 1. بعد تسجيل الدخول مباشرة
/// 2. عند تجديد الـ Token (onTokenRefresh)
/// 3. عند أول تشغيل للتطبيق إذا لم يُرسل مسبقاً
///
/// المنطق الكامل:
/// - يحفظ الـ Token محلياً (SharedPreferences)
/// - يرسله إلى جدول `push_tokens` في Supabase
/// - يتجنب الإرسال المكرر إذا لم يتغير الـ Token
class SendTokenToBackendUseCase {
  final PushNotificationRepository _repository;

  const SendTokenToBackendUseCase(this._repository);

  /// تنفيذ الـ UseCase
  ///
  /// [params] يحتوي على userId والـ Token
  Future<Either<Failure, Unit>> call(SendTokenParams params) async {
    return _repository.sendTokenToBackend(
      userId: params.userId,
      token: params.token,
    );
  }
}
