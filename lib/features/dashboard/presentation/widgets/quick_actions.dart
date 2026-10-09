import 'package:flutter/material.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../shared/widgets/ui/icon_badge.dart';
import '../../../../shared/widgets/ui/pressable_scale.dart';
import '../../../../core/theme/app_colors.dart';

/// Row of four equal quick-action buttons.
class QuickActions extends StatelessWidget {
  const QuickActions({
    super.key,
    required this.onExpense,
    required this.onIncome,
    required this.onTransfer,
    required this.onGoals,
  });

  final VoidCallback onExpense;
  final VoidCallback onIncome;
  final VoidCallback onTransfer;
  final VoidCallback onGoals;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Action(
          icon: Icons.arrow_upward_rounded,
          color: AppColors.danger,
          label: 'Expense',
          onTap: onExpense,
        ),
        _Action(
          icon: Icons.arrow_downward_rounded,
          color: AppColors.success,
          label: 'Income',
          onTap: onIncome,
        ),
        _Action(
          icon: Icons.swap_horiz_rounded,
          color: AppColors.primary,
          label: 'Transfer',
          onTap: onTransfer,
        ),
        _Action(
          icon: Icons.flag_rounded,
          color: AppColors.violet,
          label: 'Goals',
          onTap: onGoals,
        ),
      ],
    );
  }
}

class _Action extends StatelessWidget {
  const _Action({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Expanded(
      child: PressableScale(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: t.surface,
                borderRadius: BorderRadius.circular(20),
                border: t.isDark ? Border.all(color: t.border) : null,
                boxShadow: t.cardShadow,
              ),
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: IconBadge(icon: icon, color: color, size: 52),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ],
        ),
      ),
    );
  }
}
