import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../premium/domain/entities/premium_feature.dart';
import '../../../premium/domain/usecases/check_premium_access.dart';
import '../entities/budget.dart';
import '../repositories/budget_repository.dart';

class SaveBudget {
  const SaveBudget(this._repository, this._checkPremium);

  final BudgetRepository _repository;
  final CheckPremiumAccess _checkPremium;

  Future<Either<Failure, void>> call(Budget budget) async {
    final existing = await _repository.getBudgets(
      month: budget.month,
      year: budget.year,
    );
    return existing.fold((failure) async => Left(failure), (budgets) async {
      if (!budgets.any((b) => b.id == budget.id)) {
        final allowed = await _checkPremium(
          PremiumFeature.budgets,
          currentCount: budgets.length,
        );
        if (allowed.isLeft()) return allowed;
      }
      return _repository.saveBudget(budget);
    });
  }
}
