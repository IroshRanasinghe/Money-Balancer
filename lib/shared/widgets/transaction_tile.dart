import 'package:flutter/material.dart';

import '../../core/theme/app_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../features/transactions/domain/entities/transaction.dart';
import 'category_icon.dart';
import 'ui/amount_text.dart';

class TransactionTile extends StatelessWidget {
  const TransactionTile({
    super.key,
    required this.transaction,
    required this.currencyCode,
    this.onTap,
    this.showDate = true,
  });

  final Transaction transaction;
  final String currencyCode;
  final VoidCallback? onTap;

  /// Hide the date when a day header already shows it.
  final bool showDate;

  @override
  Widget build(BuildContext context) {
    final t = transaction;
    final theme = Theme.of(context);
    final tokens = context.tokens;
    final method = t.paymentMethod == 'Card' && t.cardLast4 != null
        ? 'Card •••• ${t.cardLast4}'
        : t.paymentMethod;
    final notes = t.notes;
    final subtitle = [
      if (method != null && method.isNotEmpty) method,
      if (notes != null && notes.isNotEmpty) notes,
    ].join(' · ');
    final secondary = theme.textTheme.bodySmall?.copyWith(
      color: tokens.textSecondary,
    );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            CategoryIcon(category: t.category),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          t.category,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall,
                        ),
                      ),
                      if (t.recurringId != null) ...[
                        const SizedBox(width: 4),
                        Icon(
                          Icons.repeat_rounded,
                          size: 14,
                          color: tokens.textSecondary,
                        ),
                      ],
                    ],
                  ),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: secondary,
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                AmountText(
                  t.amount,
                  currency: currencyCode,
                  signed: true,
                  type: t.type,
                  style: theme.textTheme.titleSmall,
                ),
                if (showDate)
                  Text(
                    formatDate(t.date),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: tokens.textSecondary,
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
