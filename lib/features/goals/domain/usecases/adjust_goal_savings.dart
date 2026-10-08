import 'dart:math' as math;

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/savings_goal.dart';
import '../repositories/goal_repository.dart';

class AdjustGoalSavings {
  const AdjustGoalSavings(this._repository);

  final GoalRepository _repository;

  /// Adds [delta] (negative to withdraw) to the goal's saved amount, never
  /// below 0. Never creates transactions. Returns the updated goal.
  Future<Either<Failure, SavingsGoal>> call(String id, double delta) async {
    final result = await _repository.getGoals();
    return result.fold((failure) async => Left(failure), (goals) async {
      final index = goals.indexWhere((g) => g.id == id);
      if (index < 0) return const Left(NotFoundFailure());
      final updated = goals[index].copyWith(
        savedAmount: math.max(0, goals[index].savedAmount + delta),
      );
      final saved = await _repository.saveGoal(updated);
      return saved.map((_) => updated);
    });
  }
}
