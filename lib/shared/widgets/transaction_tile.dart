import 'package:flutter/material.dart';

import '../../core/config/theme.dart';
import '../../core/utils/formatters.dart';
import '../../features/transactions/domain/entities/transaction.dart';
import 'category_icon.dart';

class TransactionTile extends StatelessWidget {
  const TransactionTile({
    super.key,
    required this.transaction,
    required this.currencyCode,
    this.onTap,
  });

  final Transaction transaction;
  final String currencyCode;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = transaction;
    final isExpense = t.type == TransactionType.expense;
    final color = isExpense ? AppColors.danger : AppColors.success;
    final method = t.paymentMethod == 'Card' && t.cardLast4 != null
        ? 'Card •••• ${t.cardLast4}'
        : t.paymentMethod;
    final dateLine = method == null || method.isEmpty
        ? formatDate(t.date)
        : '${formatDate(t.date)} · $method';
    final notes = t.notes;

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.15),
        child: Icon(categoryIcon(t.category), color: color),
      ),
      title: Text(t.category),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(dateLine),
          if (notes != null && notes.isNotEmpty)
            Text(notes, maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
      trailing: Text(
        '${isExpense ? '-' : '+'}${formatCurrency(t.amount, currencyCode)}',
        style: TextStyle(fontWeight: FontWeight.bold, color: color),
      ),
    );
  }
}
