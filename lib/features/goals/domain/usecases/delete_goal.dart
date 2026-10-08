import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/goal_repository.dart';

class DeleteGoal {
  const DeleteGoal(this._repository);

  final GoalRepository _repository;

  Future<Either<Failure, void>> call(String id) => _repository.deleteGoal(id);
}
