import 'package:hive/hive.dart';

import '../../../features/transactions/data/models/transaction_model.dart';
import '../../config/constants.dart';

class TransactionModelAdapter extends TypeAdapter<TransactionModel> {
  @override
  final int typeId = HiveTypeIds.transaction;

  @override
  TransactionModel read(BinaryReader reader) =>
      TransactionModel.fromJson(Map<String, dynamic>.from(reader.readMap()));

  @override
  void write(BinaryWriter writer, TransactionModel obj) =>
      writer.writeMap(obj.toJson());
}
