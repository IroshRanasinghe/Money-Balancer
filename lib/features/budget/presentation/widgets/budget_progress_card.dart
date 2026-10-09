import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/category_icon.dart';
import '../../../../shared/widgets/ui/app_card.dart';
import '../../../../shared/widgets/ui/status_pill.dart';
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

  String get _pillText => switch (item.status) {
    BudgetStatus.onTrack => 'On track',
    BudgetStatus.warning => 'Warning',
    BudgetStatus.exceeded => 'Over',
  };

  String get _statusText => switch (item.status) {
    BudgetStatus.onTrack || BudgetStatus.warning =>
      '${formatCurrency(item.remaining, currencyCode)} left',
    BudgetStatus.exceeded =>
      'Over by ${formatCurrency(-item.remaining, currencyCode)}',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.tokens;
    final color = _color;
    final budget = item.budget;
    final animate = !MediaQuery.disableAnimationsOf(context);
    final figures = theme.textTheme.bodySmall?.copyWith(
      color: t.textSecondary,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    return Opacity(
      opacity: budget.isActive ? 1 : 0.5,
      child: AppCard(
        onTap: onTap,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CategoryIcon(category: budget.category),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    budget.category,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                const SizedBox(width: 8),
                if (!budget.isActive)
                  StatusPill(label: 'Inactive', color: t.textSecondary)
                else
                  StatusPill(label: _pillText, color: color),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: TweenAnimationBuilder<double>(
                tween: Tween(
                  begin: animate ? 0 : item.progress,
                  end: item.progress,
                ),
                duration: animate
                    ? const Duration(milliseconds: 350)
                    : Duration.zero,
                curve: Curves.easeOutCubic,
                builder: (context, value, _) => LinearProgressIndicator(
                  value: value,
                  minHeight: 10,
                  color: color,
                  backgroundColor: color.withValues(alpha: 0.15),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${formatCurrency(item.spent, currencyCode)} / '
                    '${formatCurrency(budget.limit, currencyCode)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: figures,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    _statusText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: figures?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
