import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/ui/sheet_scaffold.dart';
import '../../domain/entities/savings_goal.dart';
import '../bloc/goals_bloc.dart';
import 'goal_card.dart';

class GoalFormSheet extends StatefulWidget {
  const GoalFormSheet({super.key, this.existing});

  final SavingsGoal? existing;

  /// Shows the sheet; it receives the caller's [GoalsBloc].
  static Future<void> show(BuildContext context, {SavingsGoal? existing}) {
    final bloc = context.read<GoalsBloc>();
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: GoalFormSheet(existing: existing),
      ),
    );
  }

  @override
  State<GoalFormSheet> createState() => _GoalFormSheetState();
}

class _GoalFormSheetState extends State<GoalFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _target;
  DateTime? _date;
  late int _color;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    final g = widget.existing;
    _name = TextEditingController(text: g?.name ?? '');
    _target = TextEditingController(
      text: g == null ? '' : g.targetAmount.toString(),
    );
    _date = g?.targetDate;
    _color = g?.colorValue ?? goalSwatches.first;
  }

  @override
  void dispose() {
    _name.dispose();
    _target.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final current = _date;
    final picked = await showDatePicker(
      context: context,
      initialDate: current != null && !current.isBefore(today)
          ? current
          : today,
      firstDate: today,
      lastDate: DateTime(now.year + 50),
    );
    if (picked != null && mounted) setState(() => _date = picked);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitted = true);
    context.read<GoalsBloc>().add(
      GoalSaveRequested(
        id: widget.existing?.id,
        name: _name.text,
        targetText: _target.text,
        targetDate: _date,
        colorValue: _color,
      ),
    );
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete this goal?'),
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
    if (confirmed == true && mounted) {
      setState(() => _submitted = true);
      context.read<GoalsBloc>().add(GoalDeleteRequested(widget.existing!.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.existing != null;
    final theme = Theme.of(context);
    final date = _date;
    return BlocListener<GoalsBloc, GoalsState>(
      // A free-plan limit also closes the sheet; the page opens the paywall.
      listenWhen: (a, b) =>
          a.savedCount != b.savedCount || a.paywallCount != b.paywallCount,
      listener: (context, state) {
        if (_submitted) Navigator.pop(context);
      },
      child: Form(
        key: _formKey,
        child: SheetScaffold(
          title: editing ? 'Edit goal' : 'Add goal',
          actions: [
            Expanded(
              child: FilledButton(
                onPressed: _save,
                child: const Text('Save goal'),
              ),
            ),
          ],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Tracks progress only — doesn't move money between accounts.",
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _name,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (v) =>
                    (v ?? '').trim().isEmpty ? 'Enter a goal name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _target,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(labelText: 'Target amount'),
                validator: (v) => parseAmount(v ?? '') == null
                    ? 'Enter a target greater than 0'
                    : null,
              ),
              const SizedBox(height: 12),
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Target date (optional)',
                    suffixIcon: date == null
                        ? const Icon(Icons.calendar_today_outlined)
                        : IconButton(
                            tooltip: 'Clear date',
                            icon: const Icon(Icons.clear),
                            onPressed: () => setState(() => _date = null),
                          ),
                  ),
                  child: Text(date == null ? 'No date' : formatDate(date)),
                ),
              ),
              const SizedBox(height: 16),
              Text('Colour', style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                children: [
                  for (final value in goalSwatches)
                    GestureDetector(
                      onTap: () => setState(() => _color = value),
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: Color(value),
                        child: _color == value
                            ? const Icon(
                                Icons.check,
                                size: 18,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ),
                ],
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
              if (editing)
                TextButton(
                  onPressed: _delete,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.danger,
                  ),
                  child: const Text('Delete'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
