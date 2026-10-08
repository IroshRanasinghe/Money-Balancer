import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/premium_gate.dart';
import '../../../../shared/widgets/empty_state.dart';
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
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.add_circle_outline),
              title: const Text('Add money'),
              onTap: () {
                Navigator.pop(sheetContext);
                GoalAmountSheet.show(context, goal: goal, withdraw: false);
              },
            ),
            ListTile(
              leading: const Icon(Icons.remove_circle_outline),
              title: const Text('Withdraw'),
              onTap: () {
                Navigator.pop(sheetContext);
                GoalAmountSheet.show(context, goal: goal, withdraw: true);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Edit'),
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
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
              itemCount: state.goals.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final goal = state.goals[i];
                return GoalCard(
                  key: ValueKey(goal.id),
                  goal: goal,
                  currencyCode: currency,
                  onTap: () => _showActions(context, goal),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
