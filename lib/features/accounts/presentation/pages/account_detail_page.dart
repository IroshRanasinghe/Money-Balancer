import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/constants.dart';
import '../../../../core/config/theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/transaction_tile.dart';
import '../../../settings/presentation/bloc/settings_bloc.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../domain/entities/account_activity.dart';
import '../bloc/account_detail_bloc.dart';
import '../bloc/accounts_bloc.dart';
import '../widgets/account_tile.dart';
import '../widgets/transfer_form_sheet.dart';

class AccountDetailPage extends StatelessWidget {
  const AccountDetailPage({super.key, required this.accountId});

  final String accountId;

  @override
  Widget build(BuildContext context) {
    final currency = context.select(
      (SettingsBloc b) => b.state.settings.currency,
    );
    final detailBloc = context.read<AccountDetailBloc>();

    return BlocListener<AccountsBloc, AccountsState>(
      // A transfer was edited or deleted from here: refresh this page.
      listenWhen: (a, b) => a.savedCount != b.savedCount,
      listener: (context, _) =>
          detailBloc.add(AccountDetailLoadRequested(accountId)),
      child: BlocBuilder<AccountDetailBloc, AccountDetailState>(
        builder: (context, state) {
          final balance = state.balance;
          return Scaffold(
            appBar: AppBar(title: Text(balance?.account.name ?? 'Account')),
            body: _body(context, state, currency, detailBloc),
          );
        },
      ),
    );
  }

  Widget _body(
    BuildContext context,
    AccountDetailState state,
    String currency,
    AccountDetailBloc detailBloc,
  ) {
    final balance = state.balance;
    if (state.status == AccountDetailStatus.failure) {
      return EmptyState(
        icon: Icons.error_outline,
        message: state.errorMessage ?? 'Something went wrong.',
        action: TextButton(
          onPressed: () =>
              detailBloc.add(AccountDetailLoadRequested(accountId)),
          child: const Text('Retry'),
        ),
      );
    }
    if (balance == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final theme = Theme.of(context);
    final account = balance.account;
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Color(account.colorValue),
                    child: Icon(
                      accountTypeIcon(account.type),
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(account.name, style: theme.textTheme.titleMedium),
                        Text(
                          account.type.label,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    formatCurrency(balance.balance, currency),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: balance.balance < 0 ? AppColors.danger : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (state.activity.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 48),
            child: EmptyState(icon: Icons.history, message: 'No activity yet.'),
          )
        else
          for (final row in state.activity)
            _row(context, row, currency, detailBloc),
      ],
    );
  }

  Widget _row(
    BuildContext context,
    AccountActivity row,
    String currency,
    AccountDetailBloc detailBloc,
  ) {
    final tx = row.transaction;
    if (tx != null) {
      return TransactionTile(
        key: ValueKey('tx-${tx.id}'),
        transaction: tx,
        currencyCode: currency,
        onTap: () async {
          final changed = await context.push<bool>(
            tx.type == TransactionType.expense
                ? AppRoutes.editExpense
                : AppRoutes.editIncome,
            extra: tx,
          );
          if (changed == true && context.mounted) {
            detailBloc.add(AccountDetailLoadRequested(accountId));
          }
        },
      );
    }
    final transfer = row.transfer!;
    final positive = row.signedAmount >= 0;
    final color = positive ? AppColors.success : AppColors.danger;
    return ListTile(
      key: ValueKey('tr-${transfer.id}'),
      onTap: () {
        final accountsState = context.read<AccountsBloc>().state;
        final accounts = [for (final i in accountsState.items) i.account];
        if (accounts.length < 2) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(accountsState.errorMessage ??
                  'Accounts are still loading')));
          return;
        }
        TransferFormSheet.show(context, accounts: accounts, existing: transfer);
      },
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.15),
        child: Icon(Icons.swap_horiz, color: color),
      ),
      title: Text(row.title),
      subtitle: Text(formatDate(row.date)),
      trailing: Text(
        '${positive ? '+' : '-'}${formatCurrency(row.signedAmount.abs(), currency)}',
        style: TextStyle(fontWeight: FontWeight.bold, color: color),
      ),
    );
  }
}
