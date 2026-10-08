import 'package:hive/hive.dart';

import '../../../features/cards/data/models/card_model.dart';
import '../../config/constants.dart';

class CardModelAdapter extends TypeAdapter<CardModel> {
  @override
  final int typeId = HiveTypeIds.card;

  @override
  CardModel read(BinaryReader reader) =>
      CardModel.fromJson(Map<String, dynamic>.from(reader.readMap()));

  @override
  void write(BinaryWriter writer, CardModel obj) =>
      writer.writeMap(obj.toJson());
}
