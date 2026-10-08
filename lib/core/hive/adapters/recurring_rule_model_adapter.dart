import 'package:hive/hive.dart';

import '../../../features/recurring/data/models/recurring_rule_model.dart';
import '../../config/constants.dart';

class RecurringRuleModelAdapter extends TypeAdapter<RecurringRuleModel> {
  @override
  final int typeId = HiveTypeIds.recurring;

  @override
  RecurringRuleModel read(BinaryReader reader) => RecurringRuleModel.fromJson(
    Map<String, dynamic>.from(reader.readMap()),
  );

  @override
  void write(BinaryWriter writer, RecurringRuleModel obj) =>
      writer.writeMap(obj.toJson());
}
