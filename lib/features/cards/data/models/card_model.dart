import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/bank_card.dart';

part 'card_model.g.dart';

@JsonSerializable()
class CardModel {
  const CardModel({
    required this.id,
    required this.nickname,
    required this.bankName,
    required this.type,
    required this.network,
    required this.last4,
    required this.expiryMonth,
    required this.expiryYear,
    required this.colorValue,
    required this.createdAt,
  });

  factory CardModel.fromJson(Map<String, dynamic> json) =>
      _$CardModelFromJson(json);

  factory CardModel.fromEntity(BankCard c) => CardModel(
        id: c.id,
        nickname: c.nickname,
        bankName: c.bankName,
        type: c.type,
        network: c.network,
        last4: c.last4,
        expiryMonth: c.expiryMonth,
        expiryYear: c.expiryYear,
        colorValue: c.colorValue,
        createdAt: c.createdAt,
      );

  final String id;
  final String nickname;
  final String bankName;
  final CardType type;
  final CardNetwork network;
  final String last4;
  final int expiryMonth;
  final int expiryYear;
  final int colorValue;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => _$CardModelToJson(this);

  BankCard toEntity() => BankCard(
        id: id,
        nickname: nickname,
        bankName: bankName,
        type: type,
        network: network,
        last4: last4,
        expiryMonth: expiryMonth,
        expiryYear: expiryYear,
        colorValue: colorValue,
        createdAt: createdAt,
      );
}
