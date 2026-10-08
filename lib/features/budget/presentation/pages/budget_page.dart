import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/month_selector.dart';
import '../../../settings/presentation/bloc/settings_bloc.dart';
import '../bloc/budget_bloc.dart';
import '../widgets/budget_form_sheet.dart';
import '../widgets/budget_progress_card.dart';

class BudgetPage extends StatelessWidget {
  const BudgetPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currency =
        context.select((SettingsBloc b) => b.state.settings.currency);
    final bloc = context.read<BudgetBloc>();

    return BlocListener<BudgetBloc, BudgetState>(
      listenWhen: (a, b) =>
          a.errorMessage != b.errorMessage &&
          b.errorMessage != null &&
          b.status != BudgetListStatus.failure,
      listener: (context, state) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(state.errorMessage!)));
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Budgets')),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => BudgetFormSheet.show(context),
          icon: const Icon(Icons.add),
          label: const Text('Add budget'),
        ),
        body: Column(
          children: [
            BlocBuilder<BudgetBloc, BudgetState>(
              buildWhen: (a, b) => a.month != b.month || a.year != b.year,
              builder: (context, state) => MonthSelector(
                month: state.month,
                year: state.year,
                onShift: (d) => bloc.add(BudgetMonthShifted(d)),
              ),
            ),
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
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
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
    final value = limit > 0 ? (spent / limit).clamp(0.0, 1.0) : 0.0;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total budget', style: theme.textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(
              '${formatCurrency(spent, currency)} of '
              '${formatCurrency(limit, currency)}',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(value: value, minHeight: 10),
            ),
          ],
        ),
      ),
    );
  }
}
