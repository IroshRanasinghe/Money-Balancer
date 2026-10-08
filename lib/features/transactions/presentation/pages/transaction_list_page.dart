import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/constants.dart';
import '../../../../core/config/theme.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/transaction_tile.dart';
import '../../../settings/presentation/bloc/settings_bloc.dart';
import '../../domain/entities/transaction.dart';
import '../bloc/transaction_bloc.dart';

class TransactionListPage extends StatelessWidget {
  const TransactionListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currency =
        context.select((SettingsBloc b) => b.state.settings.currency);
    final bloc = context.read<TransactionBloc>();

    return BlocListener<TransactionBloc, TransactionState>(
      listenWhen: (a, b) =>
          a.errorMessage != b.errorMessage &&
          b.errorMessage != null &&
          b.status != TransactionListStatus.failure,
      listener: (context, state) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(state.errorMessage!)));
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Transactions'),
          actions: [
            PopupMenuButton<TransactionSort>(
              icon: const Icon(Icons.sort),
              onSelected: (s) => bloc.add(TransactionSortChanged(s)),
              itemBuilder: (_) => const [
                PopupMenuItem(
                    value: TransactionSort.newest, child: Text('Newest first')),
                PopupMenuItem(
                    value: TransactionSort.oldest, child: Text('Oldest first')),
                PopupMenuItem(
                    value: TransactionSort.highest,
                    child: Text('Highest amount')),
                PopupMenuItem(
                    value: TransactionSort.lowest, child: Text('Lowest amount')),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            const _Filters(),
            Expanded(child: _Body(currency: currency)),
          ],
        ),
      ),
    );
  }
}

class _Filters extends StatelessWidget {
  const _Filters();

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<TransactionBloc>();
    return BlocBuilder<TransactionBloc, TransactionState>(
      buildWhen: (a, b) =>
          a.typeFilter != b.typeFilter || a.categoryFilter != b.categoryFilter,
      builder: (context, state) {
        final categories = switch (state.typeFilter) {
          TransactionType.expense => AppCategories.expense,
          TransactionType.income => AppCategories.income,
          null => {...AppCategories.expense, ...AppCategories.income}.toList(),
        };
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<TransactionType?>(
                  segments: const [
                    ButtonSegment(value: null, label: Text('All')),
                    ButtonSegment(
                        value: TransactionType.expense, label: Text('Expenses')),
                    ButtonSegment(
                        value: TransactionType.income, label: Text('Income')),
                  ],
                  selected: {state.typeFilter},
                  onSelectionChanged: (s) =>
                      bloc.add(TransactionTypeFilterChanged(s.first)),
                ),
              ),
              DropdownButton<String?>(
                value: state.categoryFilter,
                isExpanded: true,
                items: [
                  const DropdownMenuItem<String?>(
                      value: null, child: Text('All categories')),
                  for (final c in categories)
                    DropdownMenuItem<String?>(value: c, child: Text(c)),
                ],
                onChanged: (c) => bloc.add(TransactionCategoryFilterChanged(c)),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.currency});

  final String currency;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<TransactionBloc>();
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        if (state.status == TransactionListStatus.loading && state.all.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.status == TransactionListStatus.failure) {
          return EmptyState(
            icon: Icons.error_outline,
            message: state.errorMessage ?? 'Something went wrong.',
            action: TextButton(
              onPressed: () => bloc.add(const TransactionsLoadRequested()),
              child: const Text('Retry'),
            ),
          );
        }
        final visible = state.visible;
        if (visible.isEmpty) {
          return const EmptyState(
            icon: Icons.receipt_long,
            message: 'No transactions yet',
          );
        }
        return RefreshIndicator(
          onRefresh: () async {
            bloc.add(const TransactionsLoadRequested());
            await bloc.stream.firstWhere(
                (s) => s.status != TransactionListStatus.loading);
          },
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: visible.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final t = visible[i];
              return Dismissible(
                key: ValueKey(t.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: AppColors.danger,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                confirmDismiss: (_) async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Delete transaction?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true) {
                    bloc.add(TransactionDeleteRequested(t.id));
                  }
                  // The list is rebuilt from bloc state after the delete, so
                  // never let Dismissible remove the item itself.
                  return false;
                },
                child: TransactionTile(
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
                      bloc.add(const TransactionsLoadRequested());
                    }
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}
