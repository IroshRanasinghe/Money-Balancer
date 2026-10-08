import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/app_settings.dart';

part 'settings_state.freezed.dart';

@freezed
abstract class SettingsState with _$SettingsState {
  const factory SettingsState({
    @Default(AppSettings()) AppSettings settings,
    String? errorMessage,

    /// Whether this platform can show notifications at all.
    @Default(false) bool notificationsSupported,

    /// Whether the OS currently allows notifications.
    @Default(false) bool notificationsPermitted,
  }) = _SettingsState;
}
