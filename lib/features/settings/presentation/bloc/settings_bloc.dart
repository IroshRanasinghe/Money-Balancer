import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/app_settings.dart';
import '../../domain/usecases/get_settings.dart';
import '../../domain/usecases/save_settings.dart';
import 'settings_event.dart';
import 'settings_state.dart';

export 'settings_event.dart';
export 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc(
    this._getSettings,
    this._saveSettings, {
    AppSettings initialSettings = const AppSettings(),
  }) : super(SettingsState(settings: initialSettings)) {
    on<SettingsLoadRequested>(_onLoad);
    on<CurrencyChanged>(
        (e, emit) => _save(state.settings.copyWith(currency: e.currency), emit));
    on<DarkModeToggled>(
        (e, emit) => _save(state.settings.copyWith(darkMode: e.enabled), emit));
    on<LanguageChanged>(
        (e, emit) => _save(state.settings.copyWith(language: e.language), emit));
  }

  final GetSettings _getSettings;
  final SaveSettings _saveSettings;

  Future<void> _onLoad(
      SettingsLoadRequested event, Emitter<SettingsState> emit) async {
    final result = await _getSettings();
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (settings) => emit(SettingsState(settings: settings)),
    );
  }

  Future<void> _save(AppSettings updated, Emitter<SettingsState> emit) async {
    final result = await _saveSettings(updated);
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (_) => emit(SettingsState(settings: updated)),
    );
  }
}
