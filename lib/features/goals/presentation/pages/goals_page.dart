import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../shared/premium_gate.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/ui/icon_badge.dart';
import '../../../../shared/widgets/ui/sheet_scaffold.dart';
import '../../../../shared/widgets/ui/staggered_fade_in.dart';
import '../../../settings/presentation/bloc/settings_bloc.dart';
import '../../domain/entities/savings_goal.dart';
import '../bloc/goals_bloc.dart';
import '../widgets/goal_amount_sheet.dart';
import '../widgets/goal_card.dart';
import '../widgets/goal_form_sheet.dart';

class GoalsPage extends StatelessWidget {
  const GoalsPage({super.key});

  Future<void> _showActions(BuildContext context, SavingsGoal goal) {
    final bloc = context.read<GoalsBloc>();
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => SheetScaffold(
        title: goal.name,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ActionTile(
              icon: Icons.add_circle_outline_rounded,
              color: sheetContext.tokens.success,
              label: 'Add money',
              onTap: () {
                Navigator.pop(sheetContext);
                GoalAmountSheet.show(context, goal: goal, withdraw: false);
              },
            ),
            _ActionTile(
              icon: Icons.remove_circle_outline_rounded,
              color: sheetContext.tokens.warning,
              label: 'Withdraw',
              onTap: () {
                Navigator.pop(sheetContext);
                GoalAmountSheet.show(context, goal: goal, withdraw: true);
              },
            ),
            _ActionTile(
              icon: Icons.edit_outlined,
              color: Theme.of(sheetContext).colorScheme.primary,
              label: 'Edit',
              onTap: () {
                Navigator.pop(sheetContext);
                // Edit against the latest stored goal.
                final fresh = bloc.state.goals.firstWhere(
                  (g) => g.id == goal.id,
                  orElse: () => goal,
                );
                GoalFormSheet.show(context, existing: fresh);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currency = context.select(
      (SettingsBloc b) => b.state.settings.currency,
    );
    final bloc = context.read<GoalsBloc>();

    return MultiBlocListener(
      listeners: [
        BlocListener<GoalsBloc, GoalsState>(
          listenWhen: (a, b) =>
              a.errorMessage != b.errorMessage &&
              b.errorMessage != null &&
              b.status != GoalsStatus.failure,
          listener: (context, state) => ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!))),
        ),
        BlocListener<GoalsBloc, GoalsState>(
          listenWhen: (a, b) =>
              a.infoMessage != b.infoMessage && b.infoMessage != null,
          listener: (context, state) => ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.infoMessage!))),
        ),
        BlocListener<GoalsBloc, GoalsState>(
          listenWhen: (a, b) => a.paywallCount != b.paywallCount,
          listener: (context, state) =>
              openPaywall(context, state.paywallFeature!),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(title: const Text('Savings goals')),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => GoalFormSheet.show(context),
          icon: const Icon(Icons.add),
          label: const Text('Add goal'),
        ),
        body: BlocBuilder<GoalsBloc, GoalsState>(
          builder: (context, state) {
            if (state.status == GoalsStatus.loading && state.goals.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.status == GoalsStatus.failure) {
              return EmptyState(
                icon: Icons.error_outline,
                message: state.errorMessage ?? 'Something went wrong.',
                action: TextButton(
                  onPressed: () => bloc.add(const GoalsLoadRequested()),
                  child: const Text('Retry'),
                ),
              );
            }
            if (state.goals.isEmpty) {
              return const EmptyState(
                icon: Icons.flag_outlined,
                message:
                    'No goals yet.\nTap Add goal to start saving for something.',
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
              itemCount: state.goals.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final goal = state.goals[i];
                return StaggeredFadeIn(
                  key: ValueKey(goal.id),
                  index: i,
                  child: GoalCard(
                    goal: goal,
                    currencyCode: currency,
                    onTap: () => _showActions(context, goal),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: IconBadge(icon: icon, color: color, size: 40),
    title: Text(label, style: Theme.of(context).textTheme.titleSmall),
    onTap: onTap,
  );
}
