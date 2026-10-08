import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/extensions.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/domain/repositories/transaction_repository.dart';
import '../entities/report_data.dart';

class GetReport {
  const GetReport(this._repository);

  static const trendMonths = 6;

  final TransactionRepository _repository;

  Future<Either<Failure, ReportData>> call(
      {required int month, required int year}) async {
    final result = await _repository.getTransactions();
    return result.map((txs) {
      final selected = DateTime(year, month);
      final trend = [
        for (var i = trendMonths - 1; i >= 0; i--) selected.addMonths(-i),
      ].map((m) {
        var income = 0.0, expense = 0.0;
        for (final t in txs) {
          if (t.date.year == m.year && t.date.month == m.month) {
            if (t.type == TransactionType.income) {
              income += t.amount;
            } else {
              expense += t.amount;
            }
          }
        }
        return MonthlyTotal(
            month: m.month, year: m.year, income: income, expense: expense);
      }).toList();

      final byCategory = <String, double>{};
      for (final t in txs) {
        if (t.type == TransactionType.expense &&
            t.date.year == year &&
            t.date.month == month) {
          byCategory.update(t.category, (v) => v + t.amount,
              ifAbsent: () => t.amount);
        }
      }
      final sorted = byCategory.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      final current = trend.last;
      return ReportData(
        month: month,
        year: year,
        totalIncome: current.income,
        totalExpense: current.expense,
        expenseByCategory: Map.fromEntries(sorted),
        trend: trend,
      );
    });
  }
}
