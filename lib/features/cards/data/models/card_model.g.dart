// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CardModel _$CardModelFromJson(Map<String, dynamic> json) => CardModel(
  id: json['id'] as String,
  nickname: json['nickname'] as String,
  bankName: json['bankName'] as String,
  type: $enumDecode(_$CardTypeEnumMap, json['type']),
  network: $enumDecode(_$CardNetworkEnumMap, json['network']),
  last4: json['last4'] as String,
  expiryMonth: (json['expiryMonth'] as num).toInt(),
  expiryYear: (json['expiryYear'] as num).toInt(),
  colorValue: (json['colorValue'] as num).toInt(),
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$CardModelToJson(CardModel instance) => <String, dynamic>{
  'id': instance.id,
  'nickname': instance.nickname,
  'bankName': instance.bankName,
  'type': _$CardTypeEnumMap[instance.type]!,
  'network': _$CardNetworkEnumMap[instance.network]!,
  'last4': instance.last4,
  'expiryMonth': instance.expiryMonth,
  'expiryYear': instance.expiryYear,
  'colorValue': instance.colorValue,
  'createdAt': instance.createdAt.toIso8601String(),
};

const _$CardTypeEnumMap = {CardType.debit: 'debit', CardType.credit: 'credit'};

const _$CardNetworkEnumMap = {
  CardNetwork.visa: 'visa',
  CardNetwork.mastercard: 'mastercard',
  CardNetwork.amex: 'amex',
  CardNetwork.other: 'other',
};
