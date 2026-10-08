import 'package:freezed_annotation/freezed_annotation.dart';

part 'report_data.freezed.dart';

@freezed
abstract class MonthlyTotal with _$MonthlyTotal {
  const factory MonthlyTotal({
    required int month,
    required int year,
    required double income,
    required double expense,
  }) = _MonthlyTotal;
}

@freezed
abstract class ReportData with _$ReportData {
  const ReportData._();

  const factory ReportData({
    required int month,
    required int year,
    required double totalIncome,
    required double totalExpense,

    /// Expense totals per category for the month, largest first.
    required Map<String, double> expenseByCategory,

    /// Oldest → newest, ending with the selected month.
    required List<MonthlyTotal> trend,
  }) = _ReportData;

  double get net => totalIncome - totalExpense;

  /// Null when there is no income (rate undefined).
  double? get savingsRate => totalIncome > 0 ? net / totalIncome : null;
}
