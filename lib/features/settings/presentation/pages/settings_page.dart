import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/constants.dart';
import '../../../../core/config/theme.dart';
import '../../../../core/premium/premium_feature.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/premium_gate.dart';
import '../../../backup/presentation/bloc/backup_bloc.dart';
import '../../../premium/presentation/bloc/premium_bloc.dart';
import '../bloc/settings_bloc.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) => MultiBlocListener(
        listeners: [
          BlocListener<SettingsBloc, SettingsState>(
            listenWhen: (a, b) =>
                a.errorMessage != b.errorMessage && b.errorMessage != null,
            listener: (context, state) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(state.errorMessage!)));
            },
          ),
          BlocListener<BackupBloc, BackupState>(
            listenWhen: (a, b) =>
                a.status == BackupStatus.working &&
                b.status != BackupStatus.working &&
                b.message != null,
            listener: (context, state) {
              if (state.message != null) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(state.message!)));
              }
            },
          ),
          BlocListener<BackupBloc, BackupState>(
            listenWhen: (a, b) => a.paywallCount != b.paywallCount,
            listener: (context, state) =>
                openPaywall(context, state.paywallFeature!),
          ),
          BlocListener<BackupBloc, BackupState>(
            listenWhen: (a, b) => a.restoredCount != b.restoredCount,
            listener: (context, state) => context
                .read<SettingsBloc>()
                .add(const SettingsLoadRequested()),
          ),
        ],
        child: Scaffold(
          appBar: AppBar(title: const Text('Settings')),
          body: BlocBuilder<SettingsBloc, SettingsState>(
            builder: (context, state) {
              final bloc = context.read<SettingsBloc>();
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const _PremiumCard(),
                  const SizedBox(height: 12),
                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          title: const Text('Currency'),
                          trailing: DropdownButton<String>(
                            value: state.settings.currency,
                            items: [
                              for (final code in SupportedCurrencies.codes)
                                DropdownMenuItem(value: code, child: Text(code)),
                            ],
                            onChanged: (value) {
                              if (value != null) bloc.add(CurrencyChanged(value));
                            },
                          ),
                        ),
                        SwitchListTile(
                          title: const Text('Dark mode'),
                          value: state.settings.darkMode,
                          onChanged: (value) => bloc.add(DarkModeToggled(value)),
                        ),
                        const _BudgetAlertsTile(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.account_balance_wallet),
                          title: const Text('Accounts'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.push(AppRoutes.accounts),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.credit_card),
                          title: const Text('My cards'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.push(AppRoutes.cards),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.event_repeat),
                          title: const Text('Recurring'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.push(AppRoutes.recurring),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const _DataCard(),
                ],
              );
            },
          ),
        ),
      );
}

class _PremiumCard extends StatelessWidget {
  const _PremiumCard();

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<PremiumBloc, PremiumState>(
        buildWhen: (a, b) => a.status != b.status,
        builder: (context, state) {
          final status = state.status;
          final expires = status.expiresAt;
          return Card(
            child: ListTile(
              leading:
                  const Icon(Icons.workspace_premium, color: AppColors.warning),
              title: Text(status.isPremium ? 'Premium' : 'Go Premium'),
              subtitle: Text(status.isPremium
                  ? (expires == null
                      ? 'Active'
                      : 'Active until ${formatDate(expires)}')
                  : 'Unlimited accounts, budgets, goals and more'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(AppRoutes.premium),
            ),
          );
        },
      );
}

class _BudgetAlertsTile extends StatelessWidget {
  const _BudgetAlertsTile();

  @override
  Widget build(BuildContext context) {
    final isPremium =
        context.select((PremiumBloc b) => b.state.status.isPremium);
    final enabled = context
        .select((SettingsBloc b) => b.state.settings.budgetAlertsEnabled);
    return SwitchListTile(
      title: Row(
        children: [
          const Flexible(child: Text('Budget alerts')),
          if (!isPremium) ...[
            const SizedBox(width: 8),
            const _ProChip(),
          ],
        ],
      ),
      subtitle: const Text('Notify me at 80% and 100% of a budget'),
      value: isPremium && enabled,
      onChanged: (value) {
        if (!isPremium) {
          openPaywall(context, PremiumFeature.budgetAlerts);
          return;
        }
        context.read<SettingsBloc>().add(BudgetAlertsToggled(value));
      },
    );
  }
}

class _ProChip extends StatelessWidget {
  const _ProChip();

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.warning.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'PRO',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.warning,
                fontWeight: FontWeight.w700,
              ),
        ),
      );
}

class _DataCard extends StatelessWidget {
  const _DataCard();

  Future<void> _confirmRestore(BuildContext context) async {
    final bloc = context.read<BackupBloc>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Restore from backup?'),
        content: const Text(
            "This replaces all data on this device with the backup. This can't be undone."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
                foregroundColor: Theme.of(ctx).colorScheme.error),
            child: const Text('Restore'),
          ),
        ],
      ),
    );
    if (confirmed == true) bloc.add(const BackupRestoreRequested());
  }

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<BackupBloc, BackupState>(
        buildWhen: (a, b) => (a.status == BackupStatus.working) !=
            (b.status == BackupStatus.working),
        builder: (context, state) {
          final working = state.status == BackupStatus.working;
          final bloc = context.read<BackupBloc>();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 8),
                child: Text('Data',
                    style: Theme.of(context).textTheme.titleSmall),
              ),
              Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    if (working) const LinearProgressIndicator(minHeight: 2),
                    ListTile(
                      enabled: !working,
                      leading: const Icon(Icons.table_chart_outlined),
                      title: const Text('Export transactions (CSV)'),
                      trailing: context.select(
                              (PremiumBloc b) => b.state.status.isPremium)
                          ? null
                          : const _ProChip(),
                      onTap: () => bloc.add(const CsvExportRequested()),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      enabled: !working,
                      leading: const Icon(Icons.backup_outlined),
                      title: const Text('Back up data'),
                      subtitle: const Text('Card numbers are not included'),
                      onTap: () => bloc.add(const BackupExportRequested()),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      enabled: !working,
                      leading: const Icon(Icons.restore),
                      title: const Text('Restore from backup'),
                      onTap: () => _confirmRestore(context),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      );
}
