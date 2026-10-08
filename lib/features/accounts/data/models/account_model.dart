import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/account.dart';

part 'account_model.g.dart';

@JsonSerializable()
class AccountModel {
  const AccountModel({
    required this.id,
    required this.name,
    required this.type,
    required this.openingBalance,
    required this.colorValue,
    required this.createdAt,
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) =>
      _$AccountModelFromJson(json);

  factory AccountModel.fromEntity(Account a) => AccountModel(
    id: a.id,
    name: a.name,
    type: a.type,
    openingBalance: a.openingBalance,
    colorValue: a.colorValue,
    createdAt: a.createdAt,
  );

  final String id;
  final String name;
  final AccountType type;
  final double openingBalance;
  final int colorValue;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => _$AccountModelToJson(this);

  Account toEntity() => Account(
    id: id,
    name: name,
    type: type,
    openingBalance: openingBalance,
    colorValue: colorValue,
    createdAt: createdAt,
  );
}
