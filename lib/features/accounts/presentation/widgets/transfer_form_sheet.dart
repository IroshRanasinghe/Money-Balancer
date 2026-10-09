import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/account.dart';
import '../../domain/entities/transfer.dart';
import '../bloc/accounts_bloc.dart';

class TransferFormSheet extends StatefulWidget {
  const TransferFormSheet({super.key, required this.accounts, this.existing});

  final List<Account> accounts;
  final Transfer? existing;

  /// Shows the sheet; it receives the caller's [AccountsBloc].
  static Future<void> show(
    BuildContext context, {
    required List<Account> accounts,
    Transfer? existing,
  }) {
    final bloc = context.read<AccountsBloc>();
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: TransferFormSheet(accounts: accounts, existing: existing),
      ),
    );
  }

  @override
  State<TransferFormSheet> createState() => _TransferFormSheetState();
}

class _TransferFormSheetState extends State<TransferFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amount;
  late final TextEditingController _notes;
  String? _from;
  String? _to;
  late DateTime _date;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    final t = widget.existing;
    _amount = TextEditingController(text: t?.amount.toString() ?? '');
    _notes = TextEditingController(text: t?.notes ?? '');
    _from =
        t?.fromAccountId ??
        (widget.accounts.isNotEmpty ? widget.accounts[0].id : null);
    _to =
        t?.toAccountId ??
        (widget.accounts.length > 1 ? widget.accounts[1].id : null);
    _date = t?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _amount.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date.isAfter(now) ? now : _date,
      firstDate: DateTime(2000),
      lastDate: now,
    );
    if (picked == null) return;
    setState(() {
      _date = DateTime(
        picked.year,
        picked.month,
        picked.day,
        _date.hour,
        _date.minute,
      );
    });
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitted = true);
    context.read<AccountsBloc>().add(
      TransferSaveRequested(
        id: widget.existing?.id,
        createdAt: widget.existing?.createdAt,
        fromAccountId: _from,
        toAccountId: _to,
        amountText: _amount.text,
        date: _date,
        notes: _notes.text,
      ),
    );
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete this transfer?'),
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
      context.read<AccountsBloc>().add(
        TransferDeleteRequested(widget.existing!.id),
      );
    }
  }

  List<DropdownMenuItem<String?>> _items() => [
    for (final a in widget.accounts)
      DropdownMenuItem<String?>(value: a.id, child: Text(a.name)),
  ];

  @override
  Widget build(BuildContext context) {
    final editing = widget.existing != null;
    final theme = Theme.of(context);
    return BlocListener<AccountsBloc, AccountsState>(
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
                  editing ? 'Edit transfer' : 'Transfer',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String?>(
                  initialValue: _from,
                  decoration: const InputDecoration(labelText: 'From'),
                  items: _items(),
                  onChanged: (v) => setState(() => _from = v),
                  validator: (v) => v == null ? 'Choose both accounts' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String?>(
                  initialValue: _to,
                  decoration: const InputDecoration(labelText: 'To'),
                  items: _items(),
                  onChanged: (v) => setState(() => _to = v),
                  validator: (v) {
                    if (v == null) return 'Choose both accounts';
                    if (v == _from) return 'Choose two different accounts';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _amount,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(labelText: 'Amount'),
                  validator: (v) => parseAmount(v ?? '') == null
                      ? 'Enter an amount greater than 0'
                      : null,
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('Date'),
                  subtitle: Text(formatDate(_date)),
                  onTap: _pickDate,
                ),
                TextFormField(
                  controller: _notes,
                  maxLength: 200,
                  decoration: const InputDecoration(
                    labelText: 'Notes (optional)',
                  ),
                ),
                BlocBuilder<AccountsBloc, AccountsState>(
                  buildWhen: (a, b) => a.errorMessage != b.errorMessage,
                  builder: (context, state) =>
                      _submitted && state.errorMessage != null
                      ? Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            state.errorMessage!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.error,
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: _save,
                  child: const Text('Save transfer'),
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
      ),
    );
  }
}
