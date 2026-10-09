import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../shared/widgets/ui/amount_text.dart';
import '../../../../shared/widgets/ui/app_card.dart';
import '../../../../shared/widgets/ui/icon_badge.dart';
import '../../domain/entities/account.dart';
import '../../domain/entities/account_balance.dart';

IconData accountTypeIcon(AccountType t) => switch (t) {
  AccountType.cash => Icons.payments,
  AccountType.bank => Icons.account_balance,
  AccountType.savings => Icons.savings,
  AccountType.wallet => Icons.account_balance_wallet,
  AccountType.other => Icons.folder,
};

class AccountTile extends StatelessWidget {
  const AccountTile({
    super.key,
    required this.item,
    required this.currencyCode,
    this.onTap,
    this.onEdit,
  });

  final AccountBalance item;
  final String currencyCode;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final account = item.account;
    final theme = Theme.of(context);
    final t = context.tokens;
    return GestureDetector(
      onLongPress: onEdit,
      child: AppCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            IconBadge(
              icon: accountTypeIcon(account.type),
              color: Color(account.colorValue),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    account.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall,
                  ),
                  Text(
                    account.type.label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: t.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 140),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: AmountText(
                  item.balance,
                  currency: currencyCode,
                  textAlign: TextAlign.end,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: item.balance < 0 ? AppColors.danger : null,
                  ),
                ),
              ),
            ),
            if (onEdit != null)
              IconButton(
                tooltip: 'Edit account',
                visualDensity: VisualDensity.compact,
                icon: Icon(Icons.edit_outlined, color: t.textSecondary),
                onPressed: onEdit,
              ),
          ],
        ),
      ),
    );
  }
}
