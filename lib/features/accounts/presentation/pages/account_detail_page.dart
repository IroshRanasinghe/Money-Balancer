import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/config/constants.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/transaction_tile.dart';
import '../../../../shared/widgets/ui/amount_text.dart';
import '../../../../shared/widgets/ui/app_card.dart';
import '../../../../shared/widgets/ui/icon_badge.dart';
import '../../../settings/presentation/bloc/settings_bloc.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../domain/entities/account.dart';
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
    final account = balance.account;
    final groups = _groupByDay(state.activity);
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        AppSpacing.sm,
        AppSpacing.gutter,
        AppSpacing.xxl,
      ),
      children: [
        _AccountHero(
          account: account,
          balance: balance.balance,
          currency: currency,
        ),
        const SizedBox(height: AppSpacing.xl),
        if (state.activity.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 32),
            child: EmptyState(icon: Icons.history, message: 'No activity yet.'),
          )
        else
          for (final g in groups) ...[
            _DayHeader(date: g.date, net: g.net, currency: currency),
            AppCard(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                children: [
                  for (var i = 0; i < g.rows.length; i++) ...[
                    if (i > 0)
                      Divider(
                        height: 1,
                        indent: 72,
                        color: context.tokens.border,
                      ),
                    _row(context, g.rows[i], currency, detailBloc),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
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
    final theme = Theme.of(context);
    return InkWell(
      key: ValueKey('tr-${transfer.id}'),
      onTap: () {
        final accountsState = context.read<AccountsBloc>().state;
        final accounts = [for (final i in accountsState.items) i.account];
        if (accounts.length < 2) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                accountsState.errorMessage ?? 'Accounts are still loading',
              ),
            ),
          );
          return;
        }
        TransferFormSheet.show(context, accounts: accounts, existing: transfer);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            IconBadge(icon: Icons.swap_horiz_rounded, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    row.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall,
                  ),
                  Text(
                    formatDate(row.date),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: context.tokens.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                '${positive ? '+' : '-'}${formatCurrency(row.signedAmount.abs(), currency)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: color,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayGroup {
  _DayGroup(this.date);
  final DateTime date;
  final List<AccountActivity> rows = [];
  double get net => rows.fold(0, (sum, r) => sum + r.signedAmount);
}

/// Groups activity (already sorted newest first) by calendar day.
List<_DayGroup> _groupByDay(List<AccountActivity> activity) {
  final groups = <_DayGroup>[];
  for (final row in activity) {
    final d = row.date;
    final day = DateTime(d.year, d.month, d.day);
    if (groups.isEmpty || groups.last.date != day) groups.add(_DayGroup(day));
    groups.last.rows.add(row);
  }
  return groups;
}

class _DayHeader extends StatelessWidget {
  const _DayHeader({
    required this.date,
    required this.net,
    required this.currency,
  });

  final DateTime date;
  final double net;
  final String currency;

  String _label() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final diff = today.difference(date).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return DateFormat('EEE, MMM d').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.tokens;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      child: Row(
        children: [
          Text(_label(), style: theme.textTheme.titleSmall),
          const Spacer(),
          Text(
            '${net >= 0 ? '+' : '-'}${formatCurrency(net.abs(), currency)}',
            style: theme.textTheme.labelSmall?.copyWith(
              color: t.textSecondary,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountHero extends StatelessWidget {
  const _AccountHero({
    required this.account,
    required this.balance,
    required this.currency,
  });

  final Account account;
  final double balance;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final base = Color(account.colorValue);
    final hsl = HSLColor.fromColor(base);
    final dark = hsl
        .withLightness((hsl.lightness * 0.7).clamp(0.0, 1.0))
        .toColor();
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [base, dark],
        ),
        borderRadius: AppRadius.xlAll,
        boxShadow: [
          BoxShadow(
            color: base.withValues(alpha: 0.3),
            blurRadius: 32,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: AppRadius.xlAll,
        child: Stack(
          children: [
            Positioned(
              right: -40,
              top: -40,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.12),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.22),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          accountTypeIcon(account.type),
                          color: Colors.white,
                          size: 22,
                        ),
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
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              account.type.label,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white.withValues(alpha: 0.85),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    'Balance',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                  AmountText(
                    balance,
                    currency: currency,
                    style: theme.textTheme.displaySmall?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
