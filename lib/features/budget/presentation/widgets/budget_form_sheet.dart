import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/config/constants.dart';
import '../../../../core/config/theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/budget_progress.dart';
import '../bloc/budget_bloc.dart';

class BudgetFormSheet extends StatefulWidget {
  const BudgetFormSheet({super.key, this.existing});

  final BudgetProgress? existing;

  /// Shows the sheet; it receives the caller's [BudgetBloc].
  static Future<void> show(BuildContext context, {BudgetProgress? existing}) {
    final bloc = context.read<BudgetBloc>();
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: BudgetFormSheet(existing: existing),
      ),
    );
  }

  @override
  State<BudgetFormSheet> createState() => _BudgetFormSheetState();
}

class _BudgetFormSheetState extends State<BudgetFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _limit;
  late String _category;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    final b = widget.existing?.budget;
    _limit = TextEditingController(text: b == null ? '' : b.limit.toString());
    _category = b?.category ?? AppCategories.expense.first;
    _isActive = b?.isActive ?? true;
  }

  @override
  void dispose() {
    _limit.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    context.read<BudgetBloc>().add(BudgetSaveRequested(
          id: widget.existing?.budget.id,
          category: _category,
          limitText: _limit.text,
          isActive: _isActive,
        ));
    Navigator.pop(context);
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete budget?'),
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
      context
          .read<BudgetBloc>()
          .add(BudgetDeleteRequested(widget.existing!.budget.id));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.existing != null;
    return Padding(
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
                editing ? 'Edit budget' : 'Add budget',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: const InputDecoration(labelText: 'Category'),
                items: [
                  for (final c in AppCategories.expense)
                    DropdownMenuItem(value: c, child: Text(c)),
                ],
                onChanged: (c) => setState(() => _category = c ?? _category),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _limit,
                decoration: const InputDecoration(labelText: 'Monthly limit'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (v) => parseAmount(v ?? '') == null
                    ? 'Enter a limit greater than 0'
                    : null,
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Active'),
                value: _isActive,
                onChanged: (v) => setState(() => _isActive = v),
              ),
              const SizedBox(height: 8),
              FilledButton(onPressed: _save, child: const Text('Save budget')),
              if (editing)
                TextButton(
                  onPressed: _delete,
                  style:
                      TextButton.styleFrom(foregroundColor: AppColors.danger),
                  child: const Text('Delete'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
