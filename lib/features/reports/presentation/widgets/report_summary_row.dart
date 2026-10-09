import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../shared/widgets/ui/amount_text.dart';
import '../../../../shared/widgets/ui/app_card.dart';
import '../../../../shared/widgets/ui/icon_badge.dart';
import '../../../../shared/widgets/ui/status_pill.dart';
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
    final rateColor = rate == null
        ? context.tokens.textSecondary
        : (rate < 0 ? AppColors.danger : AppColors.success);
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'Income',
                icon: Icons.south_west_rounded,
                amount: report.totalIncome,
                currency: currencyCode,
                color: AppColors.success,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StatCard(
                label: 'Expenses',
                icon: Icons.north_east_rounded,
                amount: report.totalExpense,
                currency: currencyCode,
                color: AppColors.danger,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StatCard(
                label: 'Net',
                icon: Icons.account_balance_wallet_rounded,
                amount: report.net,
                currency: currencyCode,
                color: report.net < 0 ? AppColors.danger : AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        StatusPill(
          label:
              'Savings rate: ${rate == null ? '—' : '${(rate * 100).round()}%'}',
          color: rateColor,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.icon,
    required this.amount,
    required this.currency,
    required this.color,
  });

  final String label;
  final IconData icon;
  final double amount;
  final String currency;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconBadge(icon: icon, color: color, size: 36),
          const SizedBox(height: 10),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelMedium?.copyWith(
              color: context.tokens.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: AmountText(
              amount,
              currency: currency,
              style: theme.textTheme.titleSmall?.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}
