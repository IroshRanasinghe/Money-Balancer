// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BudgetModel _$BudgetModelFromJson(Map<String, dynamic> json) => BudgetModel(
  id: json['id'] as String,
  category: json['category'] as String,
  limit: (json['limit'] as num).toDouble(),
  month: (json['month'] as num).toInt(),
  year: (json['year'] as num).toInt(),
  isActive: json['isActive'] as bool,
);

Map<String, dynamic> _$BudgetModelToJson(BudgetModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'category': instance.category,
      'limit': instance.limit,
      'month': instance.month,
      'year': instance.year,
      'isActive': instance.isActive,
    };
