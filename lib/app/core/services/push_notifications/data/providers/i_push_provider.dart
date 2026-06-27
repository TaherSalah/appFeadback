import 'package:dartz/dartz.dart';

import '../../../../errors/failure.dart';
import '../../domain/entities/notification_payload.dart';

/// الواجهة التي يجب أن ينفّذها كل Push Provider (FCM أو HMS)
abstract class IPushProvider {
  Future<void> initialize();
  Future<Either<Failure, String>> getToken();
  Stream<String> get onTokenRefresh;
  Future<Either<Failure, bool>> requestPermission();
  Future<Either<Failure, bool>> checkPermission();
  Stream<NotificationPayload> get onForegroundMessage;
  Future<Either<Failure, NotificationPayload?>> getInitialMessage();
  Stream<NotificationPayload> get onNotificationTapped;
  Future<Either<Failure, Unit>> subscribeToTopic(String topic);
  Future<Either<Failure, Unit>> unsubscribeFromTopic(String topic);
}
