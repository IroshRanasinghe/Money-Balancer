import 'package:hive/hive.dart';

import '../../../features/settings/data/models/app_settings_model.dart';
import '../../config/constants.dart';

class AppSettingsModelAdapter extends TypeAdapter<AppSettingsModel> {
  @override
  final int typeId = HiveTypeIds.settings;

  @override
  AppSettingsModel read(BinaryReader reader) =>
      AppSettingsModel.fromJson(Map<String, dynamic>.from(reader.readMap()));

  @override
  void write(BinaryWriter writer, AppSettingsModel obj) =>
      writer.writeMap(obj.toJson());
}
