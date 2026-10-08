import 'package:flutter/material.dart';

import '../../../../core/config/theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/category_icon.dart';
import '../../../transactions/domain/entities/transaction.dart';
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
    final isExpense = rule.type == TransactionType.expense;
    final color = isExpense ? AppColors.danger : AppColors.success;
    final String status;
    if (!rule.isActive) {
      status = 'Paused';
    } else if (rule.isFinished) {
      status = 'Ended';
    } else {
      status = 'Next ${formatDate(rule.nextDue)}';
    }
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.15),
        child: Icon(categoryIcon(rule.category), color: color),
      ),
      title: Text(rule.category),
      subtitle: Text('${rule.frequency.label} · $status'),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '${isExpense ? '-' : '+'}${formatCurrency(rule.amount, currencyCode)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isExpense ? null : AppColors.success,
            ),
          ),
          Switch(value: rule.isActive, onChanged: onToggle),
        ],
      ),
    );
  }
}
