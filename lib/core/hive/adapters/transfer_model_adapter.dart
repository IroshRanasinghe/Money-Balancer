import 'package:hive/hive.dart';

import '../../../features/accounts/data/models/transfer_model.dart';
import '../../config/constants.dart';

class TransferModelAdapter extends TypeAdapter<TransferModel> {
  @override
  final int typeId = HiveTypeIds.transfer;

  @override
  TransferModel read(BinaryReader reader) =>
      TransferModel.fromJson(Map<String, dynamic>.from(reader.readMap()));

  @override
  void write(BinaryWriter writer, TransferModel obj) =>
      writer.writeMap(obj.toJson());
}
