import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/notifications/notification_service.dart';

class RequestNotificationPermission {
  const RequestNotificationPermission(this._notifications);

  final NotificationService _notifications;

  /// Right(true) when the user allows notifications.
  Future<Either<Failure, bool>> call() async {
    try {
      return Right(await _notifications.requestPermission());
    } on NotificationException catch (e) {
      return Left(NotificationFailure(e.message));
    }
  }
}
