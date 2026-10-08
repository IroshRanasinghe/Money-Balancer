import 'package:flutter/material.dart';

import '../../../../core/config/theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/category_icon.dart';
import '../../domain/entities/budget_progress.dart';

class BudgetProgressCard extends StatelessWidget {
  const BudgetProgressCard({
    super.key,
    required this.item,
    required this.currencyCode,
    this.onTap,
  });

  final BudgetProgress item;
  final String currencyCode;
  final VoidCallback? onTap;

  Color get _color => switch (item.status) {
        BudgetStatus.onTrack => AppColors.success,
        BudgetStatus.warning => AppColors.warning,
        BudgetStatus.exceeded => AppColors.danger,
      };

  String get _statusText => switch (item.status) {
        BudgetStatus.onTrack =>
          '${formatCurrency(item.remaining, currencyCode)} left',
        BudgetStatus.warning =>
          '${(item.ratio * 100).round()}% used — nearing limit',
        BudgetStatus.exceeded =>
          'Over by ${formatCurrency(-item.remaining, currencyCode)}',
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _color;
    final budget = item.budget;
    return Opacity(
      opacity: budget.isActive ? 1 : 0.5,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: color.withValues(alpha: 0.15),
                      child: Icon(categoryIcon(budget.category), color: color),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  budget.category,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ),
                              if (!budget.isActive) ...[
                                const SizedBox(width: 8),
                                const Chip(
                                  label: Text('Inactive'),
                                  visualDensity: VisualDensity.compact,
                                  padding: EdgeInsets.zero,
                                ),
                              ],
                            ],
                          ),
                          Text(
                            '${formatCurrency(item.spent, currencyCode)} of '
                            '${formatCurrency(budget.limit, currencyCode)}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: item.progress),
                    duration: const Duration(milliseconds: 500),
                    builder: (context, value, _) => LinearProgressIndicator(
                      value: value,
                      minHeight: 10,
                      color: color,
                      backgroundColor: color.withValues(alpha: 0.15),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _statusText,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: color, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
