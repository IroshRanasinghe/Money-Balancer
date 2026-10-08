import 'package:hive/hive.dart';

import '../../../features/goals/data/models/goal_model.dart';
import '../../config/constants.dart';

class GoalModelAdapter extends TypeAdapter<GoalModel> {
  @override
  final int typeId = HiveTypeIds.goal;

  @override
  GoalModel read(BinaryReader reader) =>
      GoalModel.fromJson(Map<String, dynamic>.from(reader.readMap()));

  @override
  void write(BinaryWriter writer, GoalModel obj) =>
      writer.writeMap(obj.toJson());
}
