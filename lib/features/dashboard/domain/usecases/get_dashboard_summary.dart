import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/extensions.dart';
import '../../../accounts/domain/repositories/account_repository.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/domain/repositories/transaction_repository.dart';
import '../entities/dashboard_summary.dart';

class GetDashboardSummary {
  const GetDashboardSummary(this._repository, this._accounts);

  static const recentCount = 5;

  final TransactionRepository _repository;
  final AccountRepository _accounts;

  /// [now] selects the "current month" for the month totals.
  Future<Either<Failure, DashboardSummary>> call(DateTime now) async {
    final result = await _repository.getTransactions();
    // Transfers net to zero, so only the opening balances are added. If
    // accounts fail to load, fall back to income minus expenses alone.
    final accountsResult = await _accounts.getAccounts();
    final opening = accountsResult.fold(
      (_) => 0.0,
      (accounts) => accounts.fold<double>(0, (s, a) => s + a.openingBalance),
    );
    return result.map((txs) {
      var balance = opening, income = 0.0, expense = 0.0;
      for (final t in txs) {
        final signed = t.type == TransactionType.income ? t.amount : -t.amount;
        balance += signed;
        if (t.date.isSameMonth(now)) {
          if (t.type == TransactionType.income) {
            income += t.amount;
          } else {
            expense += t.amount;
          }
        }
      }
      return DashboardSummary(
        totalBalance: balance,
        monthIncome: income,
        monthExpense: expense,
        recentTransactions: txs.take(recentCount).toList(),
      );
    });
  }
}
