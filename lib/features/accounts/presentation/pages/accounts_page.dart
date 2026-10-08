import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/constants.dart';
import '../../../../core/config/theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../settings/presentation/bloc/settings_bloc.dart';
import '../bloc/accounts_bloc.dart';
import '../widgets/account_form_sheet.dart';
import '../widgets/account_tile.dart';
import '../widgets/transfer_form_sheet.dart';

class AccountsPage extends StatelessWidget {
  const AccountsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currency = context.select(
      (SettingsBloc b) => b.state.settings.currency,
    );
    final bloc = context.read<AccountsBloc>();

    return BlocListener<AccountsBloc, AccountsState>(
      listenWhen: (a, b) =>
          a.errorMessage != b.errorMessage &&
          b.errorMessage != null &&
          b.status != AccountsStatus.failure,
      listener: (context, state) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Accounts'),
          actions: [
            IconButton(
              icon: const Icon(Icons.swap_horiz),
              tooltip: 'Transfer',
              onPressed: () {
                final accounts = [for (final i in bloc.state.items) i.account];
                if (accounts.length < 2) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Add two accounts to make a transfer'),
                    ),
                  );
                  return;
                }
                TransferFormSheet.show(context, accounts: accounts);
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => AccountFormSheet.show(context),
          icon: const Icon(Icons.add),
          label: const Text('Add account'),
        ),
        body: BlocBuilder<AccountsBloc, AccountsState>(
          builder: (context, state) {
            if (state.status == AccountsStatus.loading && state.items.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.status == AccountsStatus.failure) {
              return EmptyState(
                icon: Icons.error_outline,
                message: state.errorMessage ?? 'Something went wrong.',
                action: TextButton(
                  onPressed: () => bloc.add(const AccountsLoadRequested()),
                  child: const Text('Retry'),
                ),
              );
            }
            if (state.items.isEmpty) {
              return const EmptyState(
                icon: Icons.account_balance_wallet_outlined,
                message: 'No accounts yet.\nTap Add account to create one.',
              );
            }
            final total = state.items.fold<double>(
              0,
              (sum, i) => sum + i.balance,
            );
            final theme = Theme.of(context);
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formatCurrency(total, currency),
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: total < 0 ? AppColors.danger : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                for (final item in state.items)
                  AccountTile(
                    key: ValueKey(item.account.id),
                    item: item,
                    currencyCode: currency,
                    onTap: () async {
                      await context.push(
                        AppRoutes.accountDetail,
                        extra: item.account.id,
                      );
                      if (context.mounted) {
                        bloc.add(const AccountsLoadRequested());
                      }
                    },
                    onEdit: () =>
                        AccountFormSheet.show(context, existing: item.account),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
