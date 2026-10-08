import 'package:hive/hive.dart';

import '../../../../core/error/exceptions.dart';
import '../models/app_settings_model.dart';

abstract class SettingsLocalDataSource {
  /// Null when nothing has been saved yet.
  AppSettingsModel? getSettings();

  Future<void> saveSettings(AppSettingsModel model);
}

class HiveSettingsLocalDataSource implements SettingsLocalDataSource {
  HiveSettingsLocalDataSource(this._box);

  static const settingsKey = 'current';

  final Box<AppSettingsModel> _box;

  @override
  AppSettingsModel? getSettings() {
    try {
      return _box.get(settingsKey);
    } catch (e) {
      throw CacheException('Failed to read settings: $e');
    }
  }

  @override
  Future<void> saveSettings(AppSettingsModel model) async {
    try {
      await _box.put(settingsKey, model);
    } catch (e) {
      throw CacheException('Failed to save settings: $e');
    }
  }
}
