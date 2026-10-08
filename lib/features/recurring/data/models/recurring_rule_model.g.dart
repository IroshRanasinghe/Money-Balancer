// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recurring_rule_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecurringRuleModel _$RecurringRuleModelFromJson(Map<String, dynamic> json) =>
    RecurringRuleModel(
      id: json['id'] as String,
      type: $enumDecode(_$TransactionTypeEnumMap, json['type']),
      amount: (json['amount'] as num).toDouble(),
      category: json['category'] as String,
      paymentMethod: json['paymentMethod'] as String?,
      notes: json['notes'] as String?,
      accountId: json['accountId'] as String?,
      frequency: $enumDecode(_$RecurrenceFrequencyEnumMap, json['frequency']),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      generatedCount: (json['generatedCount'] as num).toInt(),
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$RecurringRuleModelToJson(RecurringRuleModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$TransactionTypeEnumMap[instance.type]!,
      'amount': instance.amount,
      'category': instance.category,
      'paymentMethod': instance.paymentMethod,
      'notes': instance.notes,
      'accountId': instance.accountId,
      'frequency': _$RecurrenceFrequencyEnumMap[instance.frequency]!,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'generatedCount': instance.generatedCount,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$TransactionTypeEnumMap = {
  TransactionType.expense: 'expense',
  TransactionType.income: 'income',
};

const _$RecurrenceFrequencyEnumMap = {
  RecurrenceFrequency.daily: 'daily',
  RecurrenceFrequency.weekly: 'weekly',
  RecurrenceFrequency.monthly: 'monthly',
  RecurrenceFrequency.yearly: 'yearly',
};
