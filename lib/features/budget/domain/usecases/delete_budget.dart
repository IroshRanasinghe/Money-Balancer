import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/budget_repository.dart';

class DeleteBudget {
  const DeleteBudget(this._repository);

  final BudgetRepository _repository;

  Future<Either<Failure, void>> call(String id) =>
      _repository.deleteBudget(id);
}
