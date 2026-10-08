import '../../../../core/notifications/notification_service.dart';

class GetNotificationStatus {
  const GetNotificationStatus(this._notifications);

  final NotificationService _notifications;

  Future<({bool supported, bool permitted})> call() async => (
        supported: _notifications.isSupported,
        permitted: _notifications.isSupported &&
            await _notifications.hasPermission(),
      );
}
