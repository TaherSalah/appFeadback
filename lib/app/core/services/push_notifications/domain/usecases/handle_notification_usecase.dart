import 'package:dartz/dartz.dart';

import '../../../../errors/failure.dart';
import '../entities/notification_payload.dart';
import '../repositories/push_notification_repository.dart';

/// UseCase موحّد لمعالجة كل عمليات الـ Push Notifications
///
/// يُلخّص كل الـ Repository calls في واجهة واحدة للـ Cubit
class HandleNotificationUseCase {
  final PushNotificationRepository _repository;

  const HandleNotificationUseCase(this._repository);

  // ─────────────────────────────────────────────────────────────────
  //  Permission
  // ─────────────────────────────────────────────────────────────────

  Future<Either<Failure, bool>> requestPermission() =>
      _repository.requestPermission();

  Future<Either<Failure, bool>> checkPermission() =>
      _repository.checkPermissionStatus();

  // ─────────────────────────────────────────────────────────────────
  //  Terminated State
  // ─────────────────────────────────────────────────────────────────

  /// يُستدعى مرة واحدة عند بدء التطبيق — للتحقق من إشعار فتح التطبيق
  Future<Either<Failure, NotificationPayload?>> getInitialMessage() =>
      _repository.getInitialMessage();

  // ─────────────────────────────────────────────────────────────────
  //  Streams
  // ─────────────────────────────────────────────────────────────────

  /// Stream للإشعارات في الـ Foreground
  Stream<NotificationPayload> get onForegroundMessage =>
      _repository.onForegroundMessage;

  /// Stream للضغط على إشعار من الـ Background
  Stream<NotificationPayload> get onNotificationTapped =>
      _repository.onNotificationTapped;

  /// Stream لتجديد الـ Token
  Stream<String> get onTokenRefresh => _repository.onTokenRefresh
      .map((token) => token.value);

  // ─────────────────────────────────────────────────────────────────
  //  Token Removal (Logout)
  // ─────────────────────────────────────────────────────────────────

  Future<Either<Failure, Unit>> removeToken({required String userId}) =>
      _repository.removeTokenFromBackend(userId: userId);

  // ─────────────────────────────────────────────────────────────────
  //  Topics
  // ─────────────────────────────────────────────────────────────────

  Future<Either<Failure, Unit>> subscribeToTopic(String topic) =>
      _repository.subscribeToTopic(topic);

  Future<Either<Failure, Unit>> unsubscribeFromTopic(String topic) =>
      _repository.unsubscribeFromTopic(topic);

  // ─────────────────────────────────────────────────────────────────
  //  Local Notification Display
  // ─────────────────────────────────────────────────────────────────

  Future<Either<Failure, Unit>> showLocalNotification(
    NotificationPayload payload,
  ) =>
      _repository.showLocalNotification(payload);

  // ─────────────────────────────────────────────────────────────────
  //  Legacy compatibility aliases
  // ─────────────────────────────────────────────────────────────────

  Future<Either<Failure, NotificationPayload?>> handleInitialMessage() =>
      getInitialMessage();

  Stream<NotificationPayload> get foregroundStream => onForegroundMessage;
  Stream<NotificationPayload> get tappedStream => onNotificationTapped;
}
