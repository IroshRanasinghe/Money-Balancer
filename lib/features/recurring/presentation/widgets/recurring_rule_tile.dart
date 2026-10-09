import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../shared/widgets/category_icon.dart';
import '../../../../shared/widgets/ui/amount_text.dart';
import '../../../../shared/widgets/ui/app_card.dart';
import '../../../../shared/widgets/ui/status_pill.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/recurring_rule.dart';

class RecurringRuleTile extends StatelessWidget {
  const RecurringRuleTile({
    super.key,
    required this.rule,
    required this.currencyCode,
    required this.onTap,
    required this.onToggle,
  });

  final RecurringRule rule;
  final String currencyCode;
  final VoidCallback onTap;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.tokens;
    final String status;
    if (!rule.isActive) {
      status = 'Paused';
    } else if (rule.isFinished) {
      status = 'Ended';
    } else {
      status = 'Next ${formatDate(rule.nextDue)}';
    }
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
      child: Row(
        children: [
          CategoryIcon(category: rule.category),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        rule.category,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall,
                      ),
                    ),
                    const SizedBox(width: 8),
                    StatusPill(
                      label: rule.frequency.label,
                      color: AppColors.primary,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  status,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: t.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AmountText(
                rule.amount,
                currency: currencyCode,
                signed: true,
                type: rule.type,
                style: theme.textTheme.titleSmall,
              ),
              Switch(value: rule.isActive, onChanged: onToggle),
            ],
          ),
        ],
      ),
    );
  }
}
