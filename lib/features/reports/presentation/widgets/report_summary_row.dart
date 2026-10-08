import 'package:flutter/material.dart';

import '../../../../core/config/theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/report_data.dart';

class ReportSummaryRow extends StatelessWidget {
  const ReportSummaryRow({
    super.key,
    required this.report,
    required this.currencyCode,
  });

  final ReportData report;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    final rate = report.savingsRate;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                label: 'Income',
                amount: formatCurrency(report.totalIncome, currencyCode),
                color: AppColors.success,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _SummaryCard(
                label: 'Expenses',
                amount: formatCurrency(report.totalExpense, currencyCode),
                color: AppColors.danger,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _SummaryCard(
                label: 'Net',
                amount: formatCurrency(report.net, currencyCode),
                color: report.net < 0 ? AppColors.danger : AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Savings rate: ${rate == null ? '—' : '${(rate * 100).round()}%'}',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.amount,
    required this.color,
  });

  final String label;
  final String amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: theme.textTheme.labelMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                amount,
                style: theme.textTheme.titleSmall
                    ?.copyWith(color: color, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
