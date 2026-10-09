import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../features/transactions/domain/entities/transaction.dart';

/// Formatted money with tabular figures. With [signed] it prefixes +/- and
/// colours by [type] (income success, expense danger); [type] is then required
/// to be meaningful (defaults to expense).
class AmountText extends StatelessWidget {
  const AmountText(
    this.amount, {
    super.key,
    this.currency = 'USD',
    this.style,
    this.signed = false,
    this.type,
    this.textAlign,
  });

  final double amount;
  final String currency;
  final TextStyle? style;
  final bool signed;
  final TransactionType? type;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final base = style ?? Theme.of(context).textTheme.titleSmall;
    final isIncome = type == TransactionType.income;
    var text = formatCurrency(amount, currency);
    Color? color = base?.color;
    if (signed) {
      text = '${isIncome ? '+' : '-'}$text';
      color = isIncome ? AppColors.success : AppColors.danger;
    }
    return Text(
      text,
      textAlign: textAlign,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: base?.copyWith(
        color: color,
        fontWeight: FontWeight.w700,
        fontVariations: const [FontVariation('wght', 700)],
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }
}
