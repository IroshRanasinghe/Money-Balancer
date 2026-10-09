import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/constants.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/app_shell.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/transaction_tile.dart';
import '../../../../shared/widgets/ui/amount_text.dart';
import '../../../../shared/widgets/ui/app_card.dart';
import '../../../../shared/widgets/ui/sheet_scaffold.dart';
import '../../../../shared/widgets/ui/staggered_fade_in.dart';
import '../../../settings/presentation/bloc/settings_bloc.dart';
import '../../domain/entities/transaction.dart';
import '../bloc/transaction_bloc.dart';
import '../widgets/transaction_groups.dart';

class TransactionListPage extends StatelessWidget {
  const TransactionListPage({super.key});

  static const _sortLabels = {
    TransactionSort.newest: 'Newest first',
    TransactionSort.oldest: 'Oldest first',
    TransactionSort.highest: 'Highest amount',
    TransactionSort.lowest: 'Lowest amount',
  };

  Future<void> _showSort(BuildContext context) async {
    final bloc = context.read<TransactionBloc>();
    final picked = await showModalBottomSheet<TransactionSort>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => SheetScaffold(
        title: 'Sort by',
        child: Column(
          children: [
            for (final entry in _sortLabels.entries)
              ListTile(
                leading: Icon(
                  bloc.state.sort == entry.key
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: bloc.state.sort == entry.key
                      ? Theme.of(ctx).colorScheme.primary
                      : ctx.tokens.textSecondary,
                ),
                title: Text(entry.value),
                onTap: () => Navigator.pop(ctx, entry.key),
              ),
          ],
        ),
      ),
    );
    if (picked != null) bloc.add(TransactionSortChanged(picked));
  }

  @override
  Widget build(BuildContext context) {
    final currency = context.select(
      (SettingsBloc b) => b.state.settings.currency,
    );

    return BlocListener<TransactionBloc, TransactionState>(
      listenWhen: (a, b) =>
          a.errorMessage != b.errorMessage &&
          b.errorMessage != null &&
          b.status != TransactionListStatus.failure,
      listener: (context, state) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Transactions'),
          actions: [
            IconButton(
              icon: const Icon(Icons.swap_vert_rounded),
              tooltip: 'Sort',
              onPressed: () => _showSort(context),
            ),
            const SizedBox(width: 8),
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
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.gutter,
                AppSpacing.sm,
                AppSpacing.gutter,
                0,
              ),
              child: SizedBox(
                width: double.infinity,
                child: SegmentedButton<TransactionType?>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(value: null, label: Text('All')),
                    ButtonSegment(
                      value: TransactionType.expense,
                      label: Text('Expenses'),
                    ),
                    ButtonSegment(
                      value: TransactionType.income,
                      label: Text('Income'),
                    ),
                  ],
                  selected: {state.typeFilter},
                  onSelectionChanged: (s) =>
                      bloc.add(TransactionTypeFilterChanged(s.first)),
                ),
              ),
            ),
            SizedBox(
              height: 52,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.gutter,
                  vertical: AppSpacing.sm,
                ),
                children: [
                  ChoiceChip(
                    label: const Text('All categories'),
                    selected: state.categoryFilter == null,
                    onSelected: (_) =>
                        bloc.add(const TransactionCategoryFilterChanged(null)),
                  ),
                  for (final c in categories) ...[
                    const SizedBox(width: AppSpacing.sm),
                    ChoiceChip(
                      label: Text(c),
                      selected: state.categoryFilter == c,
                      onSelected: (_) =>
                          bloc.add(TransactionCategoryFilterChanged(c)),
                    ),
                  ],
                ],
              ),
            ),
          ],
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
        if (state.status == TransactionListStatus.loading &&
            state.all.isEmpty) {
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
          final filtered =
              state.typeFilter != null || state.categoryFilter != null;
          if (filtered && state.all.isNotEmpty) {
            return const EmptyState(
              icon: Icons.filter_alt_off,
              message: 'No matching transactions',
            );
          }
          return const EmptyState(
            icon: Icons.receipt_long,
            message: 'No transactions yet',
          );
        }
        final byDate =
            state.sort == TransactionSort.newest ||
            state.sort == TransactionSort.oldest;
        final now = DateTime.now();
        // Amount sorts are not chronological, so day headers would be
        // meaningless: show a single flat card instead.
        final groups = byDate ? groupTransactionsByDay(visible) : null;
        return RefreshIndicator(
          onRefresh: () async {
            bloc.add(const TransactionsLoadRequested());
            await bloc.stream.firstWhere(
              (s) => s.status != TransactionListStatus.loading,
              orElse: () => bloc.state,
            );
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.gutter,
              AppSpacing.sm,
              AppSpacing.gutter,
              kNavBarClearance,
            ),
            children: [
              if (groups == null)
                _TransactionsCard(items: visible, currency: currency)
              else
                for (var i = 0; i < groups.length; i++)
                  StaggeredFadeIn(
                    index: i,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _DayHeader(
                            label: groups[i].label(now),
                            net: groups[i].net,
                            currency: currency,
                          ),
                          _TransactionsCard(
                            items: groups[i].items,
                            currency: currency,
                          ),
                        ],
                      ),
                    ),
                  ),
            ],
          ),
        );
      },
    );
  }
}

class _DayHeader extends StatelessWidget {
  const _DayHeader({
    required this.label,
    required this.net,
    required this.currency,
  });

  final String label;
  final double net;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.tokens;
    final small = theme.textTheme.labelSmall;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.titleSmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          AmountText(
            net.abs(),
            currency: currency,
            signed: true,
            type: net >= 0 ? TransactionType.income : TransactionType.expense,
            style: small?.copyWith(color: t.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _TransactionsCard extends StatelessWidget {
  const _TransactionsCard({required this.items, required this.currency});

  final List<Transaction> items;
  final String currency;

  Future<bool> _confirmDelete(BuildContext context, Transaction t) async {
    final bloc = context.read<TransactionBloc>();
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
    // The list is rebuilt from bloc state after the delete, so never let
    // Dismissible remove the item itself.
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final bloc = context.read<TransactionBloc>();
    return AppCard(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: AppRadius.lgAll,
        child: Material(
          type: MaterialType.transparency,
          child: Column(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                if (i > 0) Divider(height: 1, indent: 72, color: t.border),
                Dismissible(
                  key: ValueKey(items[i].id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: t.danger,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(
                      Icons.delete_rounded,
                      color: Colors.white,
                    ),
                  ),
                  confirmDismiss: (_) => _confirmDelete(context, items[i]),
                  child: ColoredBox(
                    color: t.surface,
                    child: TransactionTile(
                    transaction: items[i],
                    currencyCode: currency,
                    onTap: () async {
                      final tx = items[i];
                      final changed = await context.push<bool>(
                        tx.type == TransactionType.expense
                            ? AppRoutes.editExpense
                            : AppRoutes.editIncome,
                        extra: tx,
                      );
                      if (changed == true && context.mounted) {
                        bloc.add(const TransactionsLoadRequested());
                      }
                    },
                  ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
