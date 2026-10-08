import 'package:hive/hive.dart';

import '../../../features/accounts/data/models/account_model.dart';
import '../../config/constants.dart';

class AccountModelAdapter extends TypeAdapter<AccountModel> {
  @override
  final int typeId = HiveTypeIds.account;

  @override
  AccountModel read(BinaryReader reader) =>
      AccountModel.fromJson(Map<String, dynamic>.from(reader.readMap()));

  @override
  void write(BinaryWriter writer, AccountModel obj) =>
      writer.writeMap(obj.toJson());
}
