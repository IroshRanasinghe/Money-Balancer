import 'package:flutter/material.dart';

import '../../../../core/utils/formatters.dart';
import '../../domain/entities/bank_card.dart';
import '../../domain/entities/card_spending.dart';

String cardNetworkLabel(CardNetwork n) => switch (n) {
      CardNetwork.visa => 'VISA',
      CardNetwork.mastercard => 'MASTERCARD',
      CardNetwork.amex => 'AMEX',
      CardNetwork.other => 'CARD',
    };

String cardTypeLabel(CardType t) => switch (t) {
      CardType.debit => 'Debit',
      CardType.credit => 'Credit',
    };

class BankCardTile extends StatelessWidget {
  const BankCardTile({
    super.key,
    required this.item,
    required this.currencyCode,
    this.onTap,
  });

  final CardSpending item;
  final String currencyCode;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = item.card;
    final base = Color(card.colorValue);
    final dark = HSLColor.fromColor(base)
        .withLightness(
            (HSLColor.fromColor(base).lightness * 0.6).clamp(0.0, 1.0))
        .toColor();
    final theme = Theme.of(context);
    const white = Colors.white;
    final small = theme.textTheme.bodySmall?.copyWith(color: Colors.white70);
    final expired = card.isExpiredAt(DateTime.now());
    final mm = card.expiryMonth.toString().padLeft(2, '0');
    final yy = (card.expiryYear % 100).toString().padLeft(2, '0');

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [base, dark],
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      cardNetworkLabel(card.network),
                      style: theme.textTheme.titleSmall?.copyWith(
                          color: white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1),
                    ),
                    const Spacer(),
                    if (expired) ...[
                      const Chip(
                        label: Text('Expired'),
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(cardTypeLabel(card.type), style: small),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  card.nickname,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge
                      ?.copyWith(color: white, fontWeight: FontWeight.bold),
                ),
                if (card.bankName.isNotEmpty)
                  Text(card.bankName,
                      maxLines: 1, overflow: TextOverflow.ellipsis, style: small),
                const SizedBox(height: 12),
                Text(
                  '•••• ${card.last4}',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(color: white, letterSpacing: 2),
                ),
                const SizedBox(height: 4),
                Text('Expires $mm/$yy', style: small),
                const SizedBox(height: 12),
                Text(
                  'This month: ${formatCurrency(item.spent, currencyCode)}',
                  style: theme.textTheme.titleSmall
                      ?.copyWith(color: white, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
