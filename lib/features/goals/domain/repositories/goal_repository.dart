import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/savings_goal.dart';

abstract class GoalRepository {
  /// Incomplete first, then by `targetDate` ascending (none last), then
  /// `createdAt`.
  Future<Either<Failure, List<SavingsGoal>>> getGoals();

  /// Insert or update by id.
  Future<Either<Failure, void>> saveGoal(SavingsGoal goal);

  /// Fails with [NotFoundFailure] if absent.
  Future<Either<Failure, void>> deleteGoal(String id);
}
