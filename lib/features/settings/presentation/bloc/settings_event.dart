import 'package:equatable/equatable.dart';

sealed class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class SettingsLoadRequested extends SettingsEvent {
  const SettingsLoadRequested();
}

class CurrencyChanged extends SettingsEvent {
  const CurrencyChanged(this.currency);
  final String currency;
  @override
  List<Object?> get props => [currency];
}

class DarkModeToggled extends SettingsEvent {
  const DarkModeToggled(this.enabled);
  final bool enabled;
  @override
  List<Object?> get props => [enabled];
}
