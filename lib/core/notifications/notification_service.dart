import '../error/exceptions.dart';

/// Local notifications. Infrastructure, not a feature: implementations throw
/// [NotificationException]; use cases map it to a failure.
abstract class NotificationService {
  /// Whether this platform can show notifications at all.
  bool get isSupported;

  /// Whether the OS currently allows this app to show notifications.
  Future<bool> hasPermission();

  /// Prepares the platform plugin. Safe to call once at startup.
  Future<void> init();

  /// Asks the OS for permission to show notifications. Returns whether it is
  /// granted. Call only in response to a user action.
  Future<bool> requestPermission();

  Future<void> show({
    required int id,
    required String title,
    required String body,
  });
}

/// Used on web and other unsupported platforms: every call is a silent no-op.
class NoopNotificationService implements NotificationService {
  const NoopNotificationService();

  @override
  bool get isSupported => false;

  @override
  Future<bool> hasPermission() async => false;

  @override
  Future<void> init() async {}

  @override
  Future<bool> requestPermission() async => false;

  @override
  Future<void> show({
    required int id,
    required String title,
    required String body,
  }) async {}
}
