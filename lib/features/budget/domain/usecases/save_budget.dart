import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/budget.dart';
import '../repositories/budget_repository.dart';

class SaveBudget {
  const SaveBudget(this._repository);

  final BudgetRepository _repository;

  Future<Either<Failure, void>> call(Budget budget) =>
      _repository.saveBudget(budget);
}
