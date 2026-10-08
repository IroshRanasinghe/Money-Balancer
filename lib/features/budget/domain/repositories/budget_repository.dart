import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/budget.dart';

abstract class BudgetRepository {
  Future<Either<Failure, List<Budget>>> getBudgets(
      {required int month, required int year});

  /// Insert or update by id. Fails with [ValidationFailure] when a different
  /// budget already exists for the same category, month and year.
  Future<Either<Failure, void>> saveBudget(Budget budget);

  /// Fails with [NotFoundFailure] if absent.
  Future<Either<Failure, void>> deleteBudget(String id);
}
