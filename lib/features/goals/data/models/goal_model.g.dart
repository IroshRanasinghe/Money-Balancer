// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GoalModel _$GoalModelFromJson(Map<String, dynamic> json) => GoalModel(
  id: json['id'] as String,
  name: json['name'] as String,
  targetAmount: (json['targetAmount'] as num).toDouble(),
  savedAmount: (json['savedAmount'] as num).toDouble(),
  targetDate: json['targetDate'] == null
      ? null
      : DateTime.parse(json['targetDate'] as String),
  colorValue: (json['colorValue'] as num).toInt(),
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$GoalModelToJson(GoalModel instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'targetAmount': instance.targetAmount,
  'savedAmount': instance.savedAmount,
  'targetDate': instance.targetDate?.toIso8601String(),
  'colorValue': instance.colorValue,
  'createdAt': instance.createdAt.toIso8601String(),
};
