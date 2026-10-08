import 'package:hive_flutter/hive_flutter.dart';

import '../../features/settings/data/models/app_settings_model.dart';
import '../config/constants.dart';
import 'adapters/app_settings_model_adapter.dart';

class HiveSetup {
  const HiveSetup._();

  /// Registers every adapter, then opens every box. Call before DI.
  static Future<void> init() async {
    await Hive.initFlutter();

    Hive.registerAdapter(AppSettingsModelAdapter());

    await Hive.openBox<AppSettingsModel>(HiveBoxes.settings);
  }
}
