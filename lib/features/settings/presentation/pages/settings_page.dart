import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/constants.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/premium/premium_feature.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/app_shell.dart';
import '../../../../shared/premium_gate.dart';
import '../../../../shared/widgets/ui/app_card.dart';
import '../../../../shared/widgets/ui/settings_group.dart';
import '../../../../shared/widgets/ui/sheet_scaffold.dart';
import '../../../../shared/widgets/ui/status_pill.dart';
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
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        },
      ),
      BlocListener<BackupBloc, BackupState>(
        listenWhen: (a, b) =>
            a.status == BackupStatus.working &&
            b.status != BackupStatus.working &&
            b.message != null,
        listener: (context, state) {
          if (state.message != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message!)));
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
        listener: (context, state) =>
            context.read<SettingsBloc>().add(const SettingsLoadRequested()),
      ),
    ],
    child: Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          final bloc = context.read<SettingsBloc>();
          final t = context.tokens;
          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.gutter,
              AppSpacing.sm,
              AppSpacing.gutter,
              kNavBarClearance,
            ),
            children: [
              const _PremiumCard(),
              const SizedBox(height: AppSpacing.xxl),
              SettingsGroup(
                title: 'Preferences',
                children: [
                  SettingsTile(
                    icon: Icons.attach_money_rounded,
                    iconColor: AppColors.primary,
                    title: 'Currency',
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          state.settings.currency,
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(color: t.textSecondary),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: t.textSecondary,
                        ),
                      ],
                    ),
                    onTap: () => _pickCurrency(
                      context,
                      state.settings.currency,
                      (code) => bloc.add(CurrencyChanged(code)),
                    ),
                  ),
                  SettingsTile(
                    icon: Icons.dark_mode_rounded,
                    iconColor: AppColors.indigo,
                    title: 'Dark mode',
                    trailing: Switch(
                      value: state.settings.darkMode,
                      onChanged: (value) => bloc.add(DarkModeToggled(value)),
                    ),
                  ),
                  const _BudgetAlertsTile(),
                ],
              ),
              const SizedBox(height: AppSpacing.xxl),
              SettingsGroup(
                title: 'Money',
                children: [
                  SettingsTile(
                    icon: Icons.account_balance_wallet_rounded,
                    iconColor: AppColors.success,
                    title: 'Accounts',
                    onTap: () => context.push(AppRoutes.accounts),
                  ),
                  SettingsTile(
                    icon: Icons.credit_card_rounded,
                    iconColor: AppColors.violet,
                    title: 'My cards',
                    onTap: () => context.push(AppRoutes.cards),
                  ),
                  SettingsTile(
                    icon: Icons.event_repeat_rounded,
                    iconColor: AppColors.warning,
                    title: 'Recurring',
                    onTap: () => context.push(AppRoutes.recurring),
                  ),
                  SettingsTile(
                    icon: Icons.flag_rounded,
                    iconColor: AppColors.danger,
                    title: 'Savings goals',
                    onTap: () => context.push(AppRoutes.goals),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xxl),
              const _DataCard(),
              const SizedBox(height: AppSpacing.xxl),
              Center(
                child: Text(
                  'Money Balance',
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(color: t.textSecondary),
                ),
              ),
            ],
          );
        },
      ),
    ),
  );
}

Future<void> _pickCurrency(
  BuildContext context,
  String current,
  ValueChanged<String> onSelected,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => SheetScaffold(
      title: 'Currency',
      child: RadioGroup<String>(
        groupValue: current,
        onChanged: (value) {
          if (value == null) return;
          Navigator.pop(ctx);
          onSelected(value);
        },
        child: Column(
          children: [
            for (final code in SupportedCurrencies.codes)
              RadioListTile<String>(
                value: code,
                title: Text(code),
                contentPadding: EdgeInsets.zero,
              ),
          ],
        ),
      ),
    ),
  );
}

class _PremiumCard extends StatelessWidget {
  const _PremiumCard();

  @override
  Widget build(BuildContext context) => BlocBuilder<PremiumBloc, PremiumState>(
    buildWhen: (a, b) => a.status != b.status,
    builder: (context, state) {
      final status = state.status;
      final expires = status.expiresAt;
      final t = context.tokens;
      final theme = Theme.of(context);
      return AppCard(
        gradient: t.premiumGradient,
        onTap: () => context.push(AppRoutes.premium),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.workspace_premium_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    status.isPremium ? 'Premium · Active' : 'Go Premium',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    status.isPremium
                        ? (expires == null
                              ? 'Active'
                              : 'Active until ${formatDate(expires)}')
                        : 'Unlimited accounts, budgets, goals and more',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                status.isPremium ? 'Manage' : 'Upgrade',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: AppColors.orange,
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

class _BudgetAlertsTile extends StatelessWidget {
  const _BudgetAlertsTile();

  @override
  Widget build(BuildContext context) {
    final isPremium = context.select(
      (PremiumBloc b) => b.state.status.isPremium,
    );
    final enabled = context.select(
      (SettingsBloc b) => b.state.settings.budgetAlertsEnabled,
    );
    final supported = context.select(
      (SettingsBloc b) => b.state.notificationsSupported,
    );
    final permitted = context.select(
      (SettingsBloc b) => b.state.notificationsPermitted,
    );
    if (!supported) return const SizedBox.shrink();
    return SettingsTile(
      icon: Icons.notifications_active_rounded,
      iconColor: AppColors.warning,
      title: 'Budget alerts',
      subtitle: 'Notify me at 80% and 100% of a budget',
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isPremium) ...[const _ProChip(), const SizedBox(width: 8)],
          Switch(
            value: isPremium && enabled && permitted,
            onChanged: (value) {
              if (!isPremium) {
                openPaywall(context, PremiumFeature.budgetAlerts);
                return;
              }
              context.read<SettingsBloc>().add(BudgetAlertsToggled(value));
            },
          ),
        ],
      ),
    );
  }
}

class _ProChip extends StatelessWidget {
  const _ProChip();

  @override
  Widget build(BuildContext context) =>
      const StatusPill(label: 'PRO', color: AppColors.warning);
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
          "This replaces all data on this device with the backup. This can't be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: const Text('Restore'),
          ),
        ],
      ),
    );
    if (confirmed == true) bloc.add(const BackupRestoreRequested());
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<BackupBloc, BackupState>(
    buildWhen: (a, b) =>
        (a.status == BackupStatus.working) !=
        (b.status == BackupStatus.working),
    builder: (context, state) {
      final working = state.status == BackupStatus.working;
      final bloc = context.read<BackupBloc>();
      final isPremium = context.select(
        (PremiumBloc b) => b.state.status.isPremium,
      );
      return Opacity(
        opacity: working ? 0.6 : 1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (working)
              const Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.sm),
                child: LinearProgressIndicator(minHeight: 2),
              ),
            SettingsGroup(
              title: 'Data',
              children: [
                SettingsTile(
                  icon: Icons.table_chart_rounded,
                  iconColor: AppColors.success,
                  title: 'Export transactions (CSV)',
                  trailing: isPremium ? null : const _ProChip(),
                  onTap: working
                      ? null
                      : () => bloc.add(const CsvExportRequested()),
                ),
                SettingsTile(
                  icon: Icons.backup_rounded,
                  iconColor: AppColors.primary,
                  title: 'Back up data',
                  subtitle: 'Card numbers are not included',
                  onTap: working
                      ? null
                      : () => bloc.add(const BackupExportRequested()),
                ),
                SettingsTile(
                  icon: Icons.restore_rounded,
                  iconColor: AppColors.danger,
                  title: 'Restore from backup',
                  onTap: working ? null : () => _confirmRestore(context),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}
