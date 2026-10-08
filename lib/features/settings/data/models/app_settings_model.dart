import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/app_settings.dart';

part 'app_settings_model.g.dart';

@JsonSerializable()
class AppSettingsModel {
  const AppSettingsModel({
    required this.currency,
    required this.darkMode,
    required this.language,
  });

  factory AppSettingsModel.fromJson(Map<String, dynamic> json) =>
      _$AppSettingsModelFromJson(json);

  factory AppSettingsModel.fromEntity(AppSettings settings) => AppSettingsModel(
        currency: settings.currency,
        darkMode: settings.darkMode,
        language: settings.language,
      );

  final String currency;
  final bool darkMode;
  final String language;

  Map<String, dynamic> toJson() => _$AppSettingsModelToJson(this);

  AppSettings toEntity() =>
      AppSettings(currency: currency, darkMode: darkMode, language: language);
}
