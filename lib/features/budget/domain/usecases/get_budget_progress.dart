import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/domain/repositories/transaction_repository.dart';
import '../entities/budget_progress.dart';
import '../repositories/budget_repository.dart';

class GetBudgetProgress {
  const GetBudgetProgress(this._budgets, this._transactions);

  final BudgetRepository _budgets;
  final TransactionRepository _transactions;

  /// Budgets of the month with the month's spending in their category,
  /// highest usage first.
  Future<Either<Failure, List<BudgetProgress>>> call({
    required int month,
    required int year,
  }) async {
    final budgetsResult = await _budgets.getBudgets(month: month, year: year);
    return budgetsResult.fold(
      (failure) async => Left(failure),
      (budgets) async {
        final txResult = await _transactions.getTransactions();
        return txResult.map((txs) {
          final spentByCategory = <String, double>{};
          for (final t in txs) {
            if (t.type == TransactionType.expense &&
                t.date.year == year &&
                t.date.month == month) {
              spentByCategory.update(t.category, (v) => v + t.amount,
                  ifAbsent: () => t.amount);
            }
          }
          return budgets
              .map((b) => BudgetProgress(
                  budget: b, spent: spentByCategory[b.category] ?? 0))
              .toList()
            ..sort((a, b) => b.ratio.compareTo(a.ratio));
        });
      },
    );
  }
}
