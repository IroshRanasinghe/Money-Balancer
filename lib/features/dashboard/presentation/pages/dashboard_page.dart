import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/constants.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/app_shell.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/transaction_tile.dart';
import '../../../../shared/widgets/ui/app_card.dart';
import '../../../../shared/widgets/ui/icon_badge.dart';
import '../../../../shared/widgets/ui/section_header.dart';
import '../../../../shared/widgets/ui/staggered_fade_in.dart';
import '../../../goals/presentation/bloc/goals_bloc.dart';
import '../../../settings/presentation/bloc/settings_bloc.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../domain/entities/dashboard_summary.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import '../widgets/add_transaction_sheet.dart';
import '../widgets/balance_card.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/goal_mini_card.dart';
import '../widgets/quick_actions.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<DashboardBloc>();
    return Scaffold(
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: kNavBarClearance - 24),
        child: FloatingActionButton(
          tooltip: 'Add',
          onPressed: () async {
            final route = await AddTransactionSheet.show(context);
            if (route == null || !context.mounted) return;
            final changed = await context.push<bool>(route);
            if (changed == true && context.mounted) {
              bloc.add(const DashboardLoadRequested());
            }
          },
          child: const Icon(Icons.add_rounded),
        ),
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

  Future<void> _push(BuildContext context, String route) async {
    final bloc = context.read<DashboardBloc>();
    await context.push<bool>(route);
    if (context.mounted) bloc.add(const DashboardLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<DashboardBloc>();
    final goalsBloc = context.read<GoalsBloc>();
    final t = context.tokens;
    final currency = context.select(
      (SettingsBloc b) => b.state.settings.currency,
    );

    return RefreshIndicator(
      onRefresh: () async {
        goalsBloc.add(const GoalsLoadRequested());
        bloc.add(const DashboardLoadRequested());
        await bloc.stream.firstWhere(
          (s) => s.status != DashboardStatus.loading,
          orElse: () => bloc.state,
        );
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.gutter,
          AppSpacing.lg,
          AppSpacing.gutter,
          kNavBarClearance + 56,
        ),
        children: [
          DashboardHeader(onAvatarTap: () => context.go(AppRoutes.settings)),
          const SizedBox(height: AppSpacing.xl),
          BalanceCard(
            balance: summary.totalBalance,
            monthIncome: summary.monthIncome,
            monthExpense: summary.monthExpense,
            currencyCode: currency,
            onTap: () async {
              await context.push(AppRoutes.accounts);
              if (context.mounted) {
                bloc.add(const DashboardLoadRequested());
              }
            },
          ),
          const SizedBox(height: AppSpacing.xl),
          QuickActions(
            onExpense: () => _push(context, AppRoutes.addExpense),
            onIncome: () => _push(context, AppRoutes.addIncome),
            onTransfer: () => _push(context, AppRoutes.accounts),
            onGoals: () => _openGoals(context),
          ),
          const SizedBox(height: AppSpacing.xxl),
          const _GoalsSection(),
          const SizedBox(height: AppSpacing.xxl),
          SectionHeader(
            title: 'Recent transactions',
            actionLabel: 'See all',
            onAction: () => context.go(AppRoutes.transactions),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (summary.recentTransactions.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: EmptyState(
                icon: Icons.receipt_long,
                message:
                    'No transactions yet.\nTap Add to record your first one.',
              ),
            )
          else
            AppCard(
              padding: EdgeInsets.zero,
              child: ClipRRect(
                borderRadius: AppRadius.lgAll,
                child: Material(
                  type: MaterialType.transparency,
                  child: Column(
                    children: [
                      for (
                        var i = 0;
                        i < summary.recentTransactions.length;
                        i++
                      ) ...[
                        if (i > 0)
                          Divider(height: 1, indent: 72, color: t.border),
                        StaggeredFadeIn(
                          index: i,
                          child: TransactionTile(
                            transaction: summary.recentTransactions[i],
                            currencyCode: currency,
                            onTap: () {
                              final tx = summary.recentTransactions[i];
                              _edit(context, tx);
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _edit(BuildContext context, Transaction t) async {
    final bloc = context.read<DashboardBloc>();
    final changed = await context.push<bool>(
      t.type == TransactionType.expense
          ? AppRoutes.editExpense
          : AppRoutes.editIncome,
      extra: t,
    );
    if (changed == true && context.mounted) {
      bloc.add(const DashboardLoadRequested());
    }
  }
}

Future<void> _openGoals(BuildContext context) async {
  final bloc = context.read<GoalsBloc>();
  await context.push(AppRoutes.goals);
  if (context.mounted) bloc.add(const GoalsLoadRequested());
}

class _GoalsSection extends StatelessWidget {
  const _GoalsSection();

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final currency = context.select(
      (SettingsBloc b) => b.state.settings.currency,
    );
    return BlocBuilder<GoalsBloc, GoalsState>(
      builder: (context, state) {
        final incomplete = state.goals
            .where((g) => !g.isCompleted)
            .take(2)
            .toList();
        final empty = incomplete.isEmpty && state.status == GoalsStatus.success;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: 'Savings goals',
              actionLabel: 'See all',
              onAction: () => _openGoals(context),
            ),
            const SizedBox(height: AppSpacing.sm),
            if (empty)
              AppCard(
                onTap: () => _openGoals(context),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    const IconBadge(
                      icon: Icons.flag_outlined,
                      color: Color(0xFF7C3AED),
                      size: 40,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Start a savings goal',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, color: t.textSecondary),
                  ],
                ),
              )
            else if (incomplete.isNotEmpty)
              SizedBox(
                height: 120,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  itemCount: incomplete.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (context, i) => GoalMiniCard(
                    goal: incomplete[i],
                    currencyCode: currency,
                    onTap: () => _openGoals(context),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
