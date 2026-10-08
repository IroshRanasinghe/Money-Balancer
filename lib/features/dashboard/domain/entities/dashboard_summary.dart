import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../transactions/domain/entities/transaction.dart';

part 'dashboard_summary.freezed.dart';

@freezed
abstract class DashboardSummary with _$DashboardSummary {
  const factory DashboardSummary({
    required double totalBalance,
    required double monthIncome,
    required double monthExpense,
    required List<Transaction> recentTransactions,
  }) = _DashboardSummary;
}
