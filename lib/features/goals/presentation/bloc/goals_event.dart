import 'package:equatable/equatable.dart';

sealed class GoalsEvent extends Equatable {
  const GoalsEvent();

  @override
  List<Object?> get props => [];
}

class GoalsLoadRequested extends GoalsEvent {
  const GoalsLoadRequested();
}

class GoalSaveRequested extends GoalsEvent {
  const GoalSaveRequested({
    this.id,
    required this.name,
    required this.targetText,
    this.targetDate,
    required this.colorValue,
  });

  /// Null for a new goal.
  final String? id;
  final String name;
  final String targetText;
  final DateTime? targetDate;
  final int colorValue;

  @override
  List<Object?> get props => [id, name, targetText, targetDate, colorValue];
}

class GoalDeleteRequested extends GoalsEvent {
  const GoalDeleteRequested(this.id);
  final String id;

  @override
  List<Object?> get props => [id];
}

class GoalSavingsAdjusted extends GoalsEvent {
  const GoalSavingsAdjusted({
    required this.id,
    required this.amountText,
    required this.withdraw,
  });

  final String id;
  final String amountText;
  final bool withdraw;

  @override
  List<Object?> get props => [id, amountText, withdraw];
}
