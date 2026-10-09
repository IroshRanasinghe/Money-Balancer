import 'package:flutter/material.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/ui/pressable_scale.dart';
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
    this.onReveal,
  });

  final CardSpending item;
  final String currencyCode;
  final VoidCallback? onTap;
  final VoidCallback? onReveal;

  @override
  Widget build(BuildContext context) => PressableScale(
    onTap: onTap,
    child: BankCardFace(
      card: item.card,
      spent: item.spent,
      currencyCode: currencyCode,
      onReveal: onReveal,
    ),
  );
}

/// The visual credit-card artwork (aspect ratio 1.586). Shared by the list
/// tile and the live preview in the card form.
class BankCardFace extends StatelessWidget {
  const BankCardFace({
    super.key,
    required this.card,
    required this.spent,
    required this.currencyCode,
    this.onReveal,
  });

  final BankCard card;
  final double spent;
  final String currencyCode;
  final VoidCallback? onReveal;

  @override
  Widget build(BuildContext context) {
    final base = Color(card.colorValue);
    final hsl = HSLColor.fromColor(base);
    final dark = hsl
        .withLightness((hsl.lightness * 0.6).clamp(0.0, 1.0))
        .toColor();
    final theme = Theme.of(context);
    const white = Colors.white;
    final small = theme.textTheme.labelSmall?.copyWith(
      color: Colors.white.withValues(alpha: 0.78),
    );
    final expired = card.isExpiredAt(DateTime.now());
    final mm = card.expiryMonth.toString().padLeft(2, '0');
    final yy = (card.expiryYear % 100).toString().padLeft(2, '0');
    const tabular = [FontFeature.tabularFigures()];

    return AspectRatio(
      aspectRatio: 1.586,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [base, dark],
          ),
          boxShadow: [
            BoxShadow(
              color: base.withValues(alpha: 0.30),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Diagonal sheen.
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      stops: const [0.0, 0.45, 0.6, 1.0],
                      colors: [
                        Colors.white.withValues(alpha: 0.14),
                        Colors.white.withValues(alpha: 0.0),
                        Colors.white.withValues(alpha: 0.05),
                        Colors.white.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(right: -50, top: -50, child: _circle(170, 0.10)),
              Positioned(left: -40, bottom: -70, child: _circle(150, 0.08)),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _Chip(),
                        const Spacer(),
                        if (expired) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              'Expired',
                              style: small?.copyWith(color: white),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Flexible(
                          child: Text(
                            cardNetworkLabel(card.network),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: white,
                              fontWeight: FontWeight.w800,
                              fontStyle: FontStyle.italic,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: FittedBox(
                            alignment: Alignment.centerLeft,
                            fit: BoxFit.scaleDown,
                            child: Text(
                              '••••  ${card.last4}',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: white,
                                letterSpacing: 4,
                                fontFeatures: tabular,
                              ),
                            ),
                          ),
                        ),
                        if (onReveal != null)
                          IconButton(
                            tooltip: 'Show card number',
                            visualDensity: VisualDensity.compact,
                            color: white,
                            icon: const Icon(Icons.visibility_outlined),
                            onPressed: onReveal,
                          ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                card.nickname.isEmpty
                                    ? 'Nickname'
                                    : card.nickname,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: white,
                                ),
                              ),
                              Text(
                                [
                                  if (card.bankName.isNotEmpty) card.bankName,
                                  cardTypeLabel(card.type),
                                ].join(' · '),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: small,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('Expires $mm/$yy', style: small),
                            Text('This month', style: small),
                            Text(
                              formatCurrency(spent, currencyCode),
                              maxLines: 1,
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: white,
                                fontFeatures: tabular,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _circle(double size, double alpha) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white.withValues(alpha: alpha),
    ),
  );
}

class _Chip extends StatelessWidget {
  const _Chip();

  @override
  Widget build(BuildContext context) => Container(
    width: 40,
    height: 30,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(7),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFDE68A), Color(0xFFD9A441)],
      ),
    ),
    child: CustomPaint(painter: _ChipLines()),
  );
}

class _ChipLines extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0x55854D0E)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      p,
    );
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      p,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
