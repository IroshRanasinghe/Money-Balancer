import 'dart:math' as math;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'savings_goal.freezed.dart';

@freezed
abstract class SavingsGoal with _$SavingsGoal {
  const SavingsGoal._();

  const factory SavingsGoal({
    required String id,
    required String name,
    required double targetAmount,
    @Default(0) double savedAmount,
    DateTime? targetDate,
    required int colorValue,
    required DateTime createdAt,
  }) = _SavingsGoal;

  /// savedAmount / targetAmount clamped to 0..1 (0 when the target is not
  /// positive).
  double get progress =>
      targetAmount <= 0 ? 0 : (savedAmount / targetAmount).clamp(0.0, 1.0);

  bool get isCompleted => savedAmount >= targetAmount;

  double get remaining => math.max(0, targetAmount - savedAmount);

  /// Amount to save per month to reach the goal by [targetDate]; null when
  /// there is no target date or the goal is completed.
  double? monthlyNeeded(DateTime now) {
    final date = targetDate;
    if (date == null || isCompleted) return null;
    var months = (date.year - now.year) * 12 + date.month - now.month;
    if (date.day > now.day) months++;
    return remaining / math.max(1, months);
  }
}
