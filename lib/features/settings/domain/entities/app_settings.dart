import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_settings.freezed.dart';

@freezed
abstract class AppSettings with _$AppSettings {
  const factory AppSettings({
    @Default('USD') String currency,
    @Default(false) bool darkMode,
    @Default('en') String language,
    @Default(true) bool budgetAlertsEnabled,
  }) = _AppSettings;
}
