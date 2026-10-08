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
import '../../domain/entities/dashboard_summary.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import '../widgets/add_transaction_sheet.dart';
import '../widgets/balance_card.dart';
import '../widgets/summary_card.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<DashboardBloc>();
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Add'),
        onPressed: () async {
          final route = await AddTransactionSheet.show(context);
          if (route == null || !context.mounted) return;
          final changed = await context.push<bool>(route);
          if (changed == true && context.mounted) {
            bloc.add(const DashboardLoadRequested());
          }
        },
      ),
      body: SafeArea(
        child: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            final Widget content;
            if (state.summary == null &&
                state.status != DashboardStatus.failure) {
              content = const Center(
                key: ValueKey('loading'),
                child: CircularProgressIndicator(),
              );
            } else if (state.summary == null) {
              content = EmptyState(
                key: const ValueKey('failure'),
                icon: Icons.error_outline,
                message: state.errorMessage ?? 'Something went wrong.',
                action: TextButton(
                  onPressed: () => bloc.add(const DashboardLoadRequested()),
                  child: const Text('Retry'),
                ),
              );
            } else {
              content = _Content(
                key: const ValueKey('content'),
                summary: state.summary!,
              );
            }
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: content,
            );
          },
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({super.key, required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<DashboardBloc>();
    final theme = Theme.of(context);
    final currency =
        context.select((SettingsBloc b) => b.state.settings.currency);
    final now = DateTime.now();

    return RefreshIndicator(
      onRefresh: () async {
        bloc.add(const DashboardLoadRequested());
        await bloc.stream.firstWhere(
          (s) => s.status != DashboardStatus.loading,
          orElse: () => bloc.state,
        );
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Money Balance',
            style: theme.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            formatMonthYear(now.month, now.year),
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          BalanceCard(
            balance: summary.totalBalance,
            currencyCode: currency,
            onTap: () async {
              await context.push(AppRoutes.accounts);
              if (context.mounted) {
                bloc.add(const DashboardLoadRequested());
              }
            },
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SummaryCard(
                  label: 'Income this month',
                  amount: summary.monthIncome,
                  currencyCode: currency,
                  icon: Icons.arrow_downward,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SummaryCard(
                  label: 'Expenses this month',
                  amount: summary.monthExpense,
                  currencyCode: currency,
                  icon: Icons.arrow_upward,
                  color: AppColors.danger,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Recent transactions',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              TextButton(
                onPressed: () => context.go(AppRoutes.transactions),
                child: const Text('See all'),
              ),
            ],
          ),
          if (summary.recentTransactions.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: EmptyState(
                icon: Icons.receipt_long,
                message: 'No transactions yet.\nTap Add to record your first one.',
              ),
            )
          else
            for (final t in summary.recentTransactions)
              TransactionTile(
                transaction: t,
                currencyCode: currency,
                onTap: () async {
                  final changed = await context.push<bool>(
                    t.type == TransactionType.expense
                        ? AppRoutes.editExpense
                        : AppRoutes.editIncome,
                    extra: t,
                  );
                  if (changed == true && context.mounted) {
                    bloc.add(const DashboardLoadRequested());
                  }
                },
              ),
        ],
      ),
    );
  }
}
