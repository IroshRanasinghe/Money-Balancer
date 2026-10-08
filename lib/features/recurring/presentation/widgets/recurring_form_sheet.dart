import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/config/constants.dart';
import '../../../../core/config/theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../accounts/domain/entities/account.dart';
import '../../../accounts/presentation/bloc/accounts_bloc.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../domain/entities/recurring_rule.dart';
import '../bloc/recurring_bloc.dart';

class RecurringFormSheet extends StatefulWidget {
  const RecurringFormSheet({super.key, this.existing});

  final RecurringRule? existing;

  /// Shows the sheet; it receives the caller's [RecurringBloc] and
  /// [AccountsBloc].
  static Future<void> show(BuildContext context, {RecurringRule? existing}) {
    final recurring = context.read<RecurringBloc>();
    final accounts = context.read<AccountsBloc>();
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: recurring),
          BlocProvider.value(value: accounts),
        ],
        child: RecurringFormSheet(existing: existing),
      ),
    );
  }

  @override
  State<RecurringFormSheet> createState() => _RecurringFormSheetState();
}

class _RecurringFormSheetState extends State<RecurringFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amount;
  late final TextEditingController _notes;
  late TransactionType _type;
  String? _category;
  late RecurrenceFrequency _frequency;
  late DateTime _startDate;
  DateTime? _endDate;
  String? _accountId;
  String? _paymentMethod;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    final r = widget.existing;
    _amount = TextEditingController(text: r?.amount.toString() ?? '');
    _notes = TextEditingController(text: r?.notes ?? '');
    _type = r?.type ?? TransactionType.expense;
    _category = r?.category;
    _frequency = r?.frequency ?? RecurrenceFrequency.monthly;
    final now = DateTime.now();
    _startDate = r?.startDate ?? DateTime(now.year, now.month, now.day);
    _endDate = r?.endDate;
    _accountId = r?.accountId;
    _paymentMethod = r?.paymentMethod;
  }

  @override
  void dispose() {
    _amount.dispose();
    _notes.dispose();
    super.dispose();
  }

  List<String> get _categories => _type == TransactionType.expense
      ? AppCategories.expense
      : AppCategories.income;

  bool get _scheduleLocked => (widget.existing?.generatedCount ?? 0) > 0;

  Future<void> _pickStart() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() => _startDate = DateTime(picked.year, picked.month, picked.day));
  }

  Future<void> _pickEnd() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() => _endDate = DateTime(picked.year, picked.month, picked.day));
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final notes = _notes.text.trim();
    setState(() => _submitted = true);
    context.read<RecurringBloc>().add(
      RecurringSaveRequested(
        id: widget.existing?.id,
        type: _type,
        amountText: _amount.text,
        category: _category,
        frequency: _frequency,
        startDate: _startDate,
        endDate: _endDate,
        paymentMethod: _type == TransactionType.expense
            ? _paymentMethod
            : null,
        notes: notes.isEmpty ? null : notes,
        accountId: _accountId,
      ),
    );
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete this recurring item? Transactions already '
            'added are kept.'),
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
      context.read<RecurringBloc>().add(
        RecurringDeleteRequested(widget.existing!.id),
      );
    }
  }

  Widget _accountPicker(List<Account> accounts) {
    if (accounts.isEmpty) return const SizedBox.shrink();
    final knownIds = {for (final a in accounts) a.id};
    final removed = _accountId != null && !knownIds.contains(_accountId);
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: DropdownButtonFormField<String?>(
        initialValue: _accountId,
        decoration: const InputDecoration(labelText: 'Account'),
        items: [
          const DropdownMenuItem<String?>(
            value: null,
            child: Text('No account'),
          ),
          for (final a in accounts)
            DropdownMenuItem<String?>(value: a.id, child: Text(a.name)),
          if (removed)
            DropdownMenuItem<String?>(
              value: _accountId,
              child: const Text('(removed account)'),
            ),
        ],
        onChanged: (id) => setState(() => _accountId = id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.existing != null;
    final theme = Theme.of(context);
    final accountsLoaded = context.select(
      (AccountsBloc b) => [for (final i in b.state.items) i.account],
    );
    return BlocListener<RecurringBloc, RecurringState>(
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
                  editing ? 'Edit recurring' : 'Add recurring',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                SegmentedButton<TransactionType>(
                  segments: const [
                    ButtonSegment(
                      value: TransactionType.expense,
                      label: Text('Expense'),
                    ),
                    ButtonSegment(
                      value: TransactionType.income,
                      label: Text('Income'),
                    ),
                  ],
                  selected: {_type},
                  onSelectionChanged: (s) => setState(() {
                    _type = s.first;
                    if (!_categories.contains(_category)) _category = null;
                  }),
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
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  key: ValueKey(_type),
                  initialValue: _category,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: [
                    for (final c in _categories)
                      DropdownMenuItem(value: c, child: Text(c)),
                  ],
                  validator: (v) => v == null ? 'Choose a category' : null,
                  onChanged: (v) => setState(() => _category = v),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<RecurrenceFrequency>(
                  initialValue: _frequency,
                  decoration: InputDecoration(
                    labelText: 'Frequency',
                    helperText: _scheduleLocked
                        ? 'Already started — create a new item to change the '
                              'schedule'
                        : null,
                    helperMaxLines: 2,
                  ),
                  items: [
                    for (final f in RecurrenceFrequency.values)
                      DropdownMenuItem(value: f, child: Text(f.label)),
                  ],
                  onChanged: _scheduleLocked
                      ? null
                      : (f) => setState(() => _frequency = f ?? _frequency),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  enabled: !_scheduleLocked,
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('Start date'),
                  subtitle: Text(formatDate(_startDate)),
                  onTap: _scheduleLocked ? null : _pickStart,
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.event_busy),
                  title: const Text('End date (optional)'),
                  subtitle: Text(
                    _endDate == null ? 'No end date' : formatDate(_endDate!),
                  ),
                  trailing: _endDate == null
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.clear),
                          tooltip: 'Clear end date',
                          onPressed: () => setState(() => _endDate = null),
                        ),
                  onTap: _pickEnd,
                ),
                _accountPicker(accountsLoaded),
                if (_type == TransactionType.expense) ...[
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String?>(
                    initialValue: _paymentMethod,
                    decoration: const InputDecoration(
                      labelText: 'Payment method (optional)',
                    ),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('None'),
                      ),
                      for (final m in PaymentMethods.all)
                        DropdownMenuItem<String?>(value: m, child: Text(m)),
                    ],
                    onChanged: (v) => setState(() => _paymentMethod = v),
                  ),
                ],
                const SizedBox(height: 12),
                TextFormField(
                  controller: _notes,
                  maxLength: 200,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Notes (optional)',
                  ),
                ),
                BlocBuilder<RecurringBloc, RecurringState>(
                  buildWhen: (a, b) => a.errorMessage != b.errorMessage,
                  builder: (context, state) =>
                      _submitted && state.errorMessage != null
                      ? Padding(
                          padding: const EdgeInsets.only(top: 4),
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
                FilledButton(onPressed: _save, child: const Text('Save')),
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
