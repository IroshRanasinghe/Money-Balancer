import 'package:hive/hive.dart';

import '../../../features/budget/data/models/budget_model.dart';
import '../../config/constants.dart';

class BudgetModelAdapter extends TypeAdapter<BudgetModel> {
  @override
  final int typeId = HiveTypeIds.budget;

  @override
  BudgetModel read(BinaryReader reader) =>
      BudgetModel.fromJson(Map<String, dynamic>.from(reader.readMap()));

  @override
  void write(BinaryWriter writer, BudgetModel obj) =>
      writer.writeMap(obj.toJson());
}
