import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/app_settings.dart';
import '../../domain/usecases/get_notification_status.dart';
import '../../domain/usecases/get_settings.dart';
import '../../domain/usecases/request_notification_permission.dart';
import '../../domain/usecases/save_settings.dart';
import 'settings_event.dart';
import 'settings_state.dart';

export 'settings_event.dart';
export 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc(
    this._getSettings,
    this._saveSettings,
    this._requestNotificationPermission,
    this._getNotificationStatus, {
    AppSettings initialSettings = const AppSettings(),
  }) : super(SettingsState(settings: initialSettings)) {
    on<SettingsLoadRequested>(_onLoad);
    on<CurrencyChanged>(
        (e, emit) => _save(state.settings.copyWith(currency: e.currency), emit));
    on<DarkModeToggled>(
        (e, emit) => _save(state.settings.copyWith(darkMode: e.enabled), emit));
    on<BudgetAlertsToggled>(_onBudgetAlertsToggled);
    on<NotificationStatusRequested>(_onNotificationStatus);
  }

  final GetSettings _getSettings;
  final SaveSettings _saveSettings;
  final RequestNotificationPermission _requestNotificationPermission;
  final GetNotificationStatus _getNotificationStatus;

  Future<void> _onLoad(
      SettingsLoadRequested event, Emitter<SettingsState> emit) async {
    final result = await _getSettings();
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (settings) => emit(state.copyWith(settings: settings, errorMessage: null)),
    );
  }

  /// Switching on first asks the OS for notification permission; when it is
  /// denied the setting stays off.
  Future<void> _onBudgetAlertsToggled(
      BudgetAlertsToggled event, Emitter<SettingsState> emit) async {
    if (event.enabled) {
      final granted = (await _requestNotificationPermission())
          .getOrElse(() => false);
      if (!granted) {
        emit(state.copyWith(errorMessage: null));
        emit(state.copyWith(
            errorMessage:
                'Allow notifications in system settings to get budget alerts.'));
        return;
      }
    }
    if (event.enabled) emit(state.copyWith(notificationsPermitted: true));
    await _save(
        state.settings.copyWith(budgetAlertsEnabled: event.enabled), emit);
  }

  Future<void> _onNotificationStatus(
      NotificationStatusRequested event, Emitter<SettingsState> emit) async {
    final status = await _getNotificationStatus();
    emit(state.copyWith(
        notificationsSupported: status.supported,
        notificationsPermitted: status.permitted));
  }

  Future<void> _save(AppSettings updated, Emitter<SettingsState> emit) async {
    final result = await _saveSettings(updated);
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (_) => emit(state.copyWith(settings: updated, errorMessage: null)),
    );
  }
}
