import 'package:get_it/get_it.dart';

import 'local_notification_service.dart';
import 'notification_service.dart';

/// Registers the platform notification service. A failed init must never block
/// startup: it falls back to the no-op service.
Future<void> registerNotifications(GetIt sl) async {
  NotificationService service = localNotificationsSupported()
      ? LocalNotificationService()
      : const NoopNotificationService();
  try {
    await service.init();
  } catch (_) {
    service = const NoopNotificationService();
  }
  sl.registerSingleton<NotificationService>(service);
}
