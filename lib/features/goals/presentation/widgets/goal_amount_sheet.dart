import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/formatters.dart';
import '../../domain/entities/savings_goal.dart';
import '../bloc/goals_bloc.dart';

class GoalAmountSheet extends StatefulWidget {
  const GoalAmountSheet({super.key, required this.goal, required this.withdraw});

  final SavingsGoal goal;
  final bool withdraw;

  /// Shows the sheet; it receives the caller's [GoalsBloc].
  static Future<void> show(
    BuildContext context, {
    required SavingsGoal goal,
    required bool withdraw,
  }) {
    final bloc = context.read<GoalsBloc>();
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: GoalAmountSheet(goal: goal, withdraw: withdraw),
      ),
    );
  }

  @override
  State<GoalAmountSheet> createState() => _GoalAmountSheetState();
}

class _GoalAmountSheetState extends State<GoalAmountSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amount = TextEditingController();
  bool _submitted = false;

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitted = true);
    context.read<GoalsBloc>().add(
      GoalSavingsAdjusted(
        id: widget.goal.id,
        amountText: _amount.text,
        withdraw: widget.withdraw,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = widget.withdraw ? 'Withdraw' : 'Add money';
    return BlocListener<GoalsBloc, GoalsState>(
      listenWhen: (a, b) => a.savedCount != b.savedCount,
      listener: (context, state) {
        if (_submitted) Navigator.pop(context);
      },
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          16 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '$label — ${widget.goal.name}',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _amount,
                  autofocus: true,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(labelText: 'Amount'),
                  validator: (v) => parseAmount(v ?? '') == null
                      ? 'Enter an amount greater than 0'
                      : null,
                ),
                BlocBuilder<GoalsBloc, GoalsState>(
                  buildWhen: (a, b) => a.errorMessage != b.errorMessage,
                  builder: (context, state) =>
                      _submitted && state.errorMessage != null
                      ? Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(
                            state.errorMessage!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.error,
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                const SizedBox(height: 16),
                FilledButton(onPressed: _submit, child: Text(label)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
