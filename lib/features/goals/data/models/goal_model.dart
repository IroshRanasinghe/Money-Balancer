import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/savings_goal.dart';

part 'goal_model.g.dart';

@JsonSerializable()
class GoalModel {
  const GoalModel({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.savedAmount,
    required this.targetDate,
    required this.colorValue,
    required this.createdAt,
  });

  factory GoalModel.fromJson(Map<String, dynamic> json) =>
      _$GoalModelFromJson(json);

  factory GoalModel.fromEntity(SavingsGoal g) => GoalModel(
    id: g.id,
    name: g.name,
    targetAmount: g.targetAmount,
    savedAmount: g.savedAmount,
    targetDate: g.targetDate,
    colorValue: g.colorValue,
    createdAt: g.createdAt,
  );

  final String id;
  final String name;
  final double targetAmount;
  final double savedAmount;
  final DateTime? targetDate;
  final int colorValue;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => _$GoalModelToJson(this);

  SavingsGoal toEntity() => SavingsGoal(
    id: id,
    name: name,
    targetAmount: targetAmount,
    savedAmount: savedAmount,
    targetDate: targetDate,
    colorValue: colorValue,
    createdAt: createdAt,
  );
}
