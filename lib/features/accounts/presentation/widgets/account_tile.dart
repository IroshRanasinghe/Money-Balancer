import 'package:flutter/material.dart';

import '../../../../core/config/theme.dart';
import '../../../../core/utils/formatters.dart';
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
    return Card(
      child: ListTile(
        onTap: onTap,
        onLongPress: onEdit,
        leading: CircleAvatar(
          backgroundColor: Color(account.colorValue),
          child: Icon(accountTypeIcon(account.type), color: Colors.white),
        ),
        title: Text(account.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(account.type.label),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              formatCurrency(item.balance, currencyCode),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: item.balance < 0 ? AppColors.danger : null,
              ),
            ),
            if (onEdit != null)
              IconButton(
                tooltip: 'Edit account',
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.edit_outlined),
                onPressed: onEdit,
              ),
          ],
        ),
      ),
    );
  }
}
