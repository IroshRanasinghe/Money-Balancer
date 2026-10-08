import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/savings_goal.dart';
import '../repositories/goal_repository.dart';

class GetGoals {
  const GetGoals(this._repository);

  final GoalRepository _repository;

  Future<Either<Failure, List<SavingsGoal>>> call() =>
      _repository.getGoals();
}
