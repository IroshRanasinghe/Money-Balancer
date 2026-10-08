// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppSettingsModel _$AppSettingsModelFromJson(Map<String, dynamic> json) =>
    AppSettingsModel(
      currency: json['currency'] as String,
      darkMode: json['darkMode'] as bool,
      language: json['language'] as String,
    );

Map<String, dynamic> _$AppSettingsModelToJson(AppSettingsModel instance) =>
    <String, dynamic>{
      'currency': instance.currency,
      'darkMode': instance.darkMode,
      'language': instance.language,
    };
