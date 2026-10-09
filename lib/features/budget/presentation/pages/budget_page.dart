import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_shell.dart';
import '../../../../shared/premium_gate.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/month_selector.dart';
import '../../../../shared/widgets/ui/app_card.dart';
import '../../../settings/presentation/bloc/settings_bloc.dart';
import '../bloc/budget_bloc.dart';
import '../widgets/budget_form_sheet.dart';
import '../widgets/budget_ring.dart';
import '../widgets/budget_progress_card.dart';

class BudgetPage extends StatelessWidget {
  const BudgetPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currency = context.select(
      (SettingsBloc b) => b.state.settings.currency,
    );
    final bloc = context.read<BudgetBloc>();

    return MultiBlocListener(
      listeners: [
        BlocListener<BudgetBloc, BudgetState>(
          listenWhen: (a, b) =>
              a.errorMessage != b.errorMessage &&
              b.errorMessage != null &&
              b.status != BudgetListStatus.failure,
          listener: (context, state) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          },
        ),
        BlocListener<BudgetBloc, BudgetState>(
          listenWhen: (a, b) => a.paywallCount != b.paywallCount,
          listener: (context, state) =>
              openPaywall(context, state.paywallFeature!),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(title: const Text('Budgets')),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: kNavBarClearance - 24),
          child: FloatingActionButton.extended(
            onPressed: () => BudgetFormSheet.show(context),
            icon: const Icon(Icons.add),
            label: const Text('Add budget'),
          ),
        ),
        body: Column(
          children: [
            const SizedBox(height: 4),
            BlocBuilder<BudgetBloc, BudgetState>(
              buildWhen: (a, b) => a.month != b.month || a.year != b.year,
              builder: (context, state) => MonthSelector(
                month: state.month,
                year: state.year,
                onShift: (d) => bloc.add(BudgetMonthShifted(d)),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(child: _Body(currency: currency)),
          ],
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.currency});

  final String currency;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<BudgetBloc>();
    return BlocBuilder<BudgetBloc, BudgetState>(
      builder: (context, state) {
        if (state.status == BudgetListStatus.loading && state.items.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.status == BudgetListStatus.failure) {
          return EmptyState(
            icon: Icons.error_outline,
            message: state.errorMessage ?? 'Something went wrong.',
            action: TextButton(
              onPressed: () => bloc.add(const BudgetLoadRequested()),
              child: const Text('Retry'),
            ),
          );
        }
        if (state.items.isEmpty) {
          return const EmptyState(
            icon: Icons.savings_outlined,
            message: 'No budgets for this month.\nTap Add budget to set one.',
          );
        }
        final active = state.items.where((i) => i.budget.isActive);
        final totalLimit = active.fold<double>(0, (s, i) => s + i.budget.limit);
        final totalSpent = active.fold<double>(0, (s, i) => s + i.spent);
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, kNavBarClearance + 56),
          itemCount: state.items.length + 1,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            if (i == 0) {
              return _SummaryCard(
                spent: totalSpent,
                limit: totalLimit,
                currency: currency,
              );
            }
            final item = state.items[i - 1];
            return BudgetProgressCard(
              key: ValueKey(item.budget.id),
              item: item,
              currencyCode: currency,
              onTap: () => BudgetFormSheet.show(context, existing: item),
            );
          },
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.spent,
    required this.limit,
    required this.currency,
  });

  final double spent;
  final double limit;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.tokens;
    final ratio = limit > 0 ? spent / limit : (spent > 0 ? 1.0 : 0.0);
    final remaining = limit - spent;
    final over = remaining < 0;
    final figures = [const FontFeature.tabularFigures()];
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          BudgetRing(ratio: ratio),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total budget',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: t.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formatCurrency(spent, currency),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontFeatures: figures,
                  ),
                ),
                Text(
                  'of ${formatCurrency(limit, currency)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: t.textSecondary,
                    fontFeatures: figures,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  over
                      ? 'Over by ${formatCurrency(-remaining, currency)}'
                      : '${formatCurrency(remaining, currency)} left',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: over ? AppColors.danger : AppColors.success,
                    fontFeatures: figures,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
