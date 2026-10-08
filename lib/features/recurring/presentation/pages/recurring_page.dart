import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/premium_gate.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../settings/presentation/bloc/settings_bloc.dart';
import '../bloc/recurring_bloc.dart';
import '../widgets/recurring_form_sheet.dart';
import '../widgets/recurring_rule_tile.dart';

class RecurringPage extends StatelessWidget {
  const RecurringPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currency = context.select(
      (SettingsBloc b) => b.state.settings.currency,
    );
    final bloc = context.read<RecurringBloc>();

    return MultiBlocListener(
      listeners: [
        BlocListener<RecurringBloc, RecurringState>(
          listenWhen: (a, b) =>
              (a.errorMessage != b.errorMessage && b.errorMessage != null) ||
              (a.infoMessage != b.infoMessage && b.infoMessage != null),
          listener: (context, state) {
            final message = state.errorMessage ?? state.infoMessage;
            if (message == null) return;
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(message)));
          },
        ),
        BlocListener<RecurringBloc, RecurringState>(
          listenWhen: (a, b) => a.paywallCount != b.paywallCount,
          listener: (context, state) =>
              openPaywall(context, state.paywallFeature!),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(title: const Text('Recurring')),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => RecurringFormSheet.show(context),
          icon: const Icon(Icons.add),
          label: const Text('Add recurring'),
        ),
        body: BlocBuilder<RecurringBloc, RecurringState>(
          builder: (context, state) {
            if (state.status == RecurringStatus.loading &&
                state.rules.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.status == RecurringStatus.failure) {
              return EmptyState(
                icon: Icons.error_outline,
                message: state.errorMessage ?? 'Something went wrong.',
                action: TextButton(
                  onPressed: () => bloc.add(const RecurringLoadRequested()),
                  child: const Text('Retry'),
                ),
              );
            }
            if (state.rules.isEmpty) {
              return const EmptyState(
                icon: Icons.event_repeat,
                message:
                    'No recurring items yet.\nTap Add recurring to set one up.',
              );
            }
            return ListView(
              padding: const EdgeInsets.only(bottom: 96),
              children: [
                for (final rule in state.rules)
                  RecurringRuleTile(
                    key: ValueKey(rule.id),
                    rule: rule,
                    currencyCode: currency,
                    onTap: () =>
                        RecurringFormSheet.show(context, existing: rule),
                    onToggle: (v) => bloc.add(RecurringActiveToggled(rule.id, v)),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
