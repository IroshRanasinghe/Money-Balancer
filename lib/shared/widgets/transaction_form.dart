import 'package:flutter/material.dart';

import '../../core/utils/formatters.dart';
import '../../core/config/constants.dart';
import '../../features/transactions/domain/entities/transaction.dart';
import 'category_icon.dart';

class TransactionFormData {
  const TransactionFormData({
    required this.amountText,
    required this.category,
    required this.date,
    this.paymentMethod,
    this.notes,
  });

  final String amountText;
  final String? category;
  final DateTime date;
  final String? paymentMethod;
  final String? notes;
}

class TransactionForm extends StatefulWidget {
  const TransactionForm({
    super.key,
    required this.categories,
    required this.showPaymentMethod,
    this.initial,
    required this.isSubmitting,
    required this.submitLabel,
    required this.onSubmit,
  });

  final List<String> categories;
  final bool showPaymentMethod;
  final Transaction? initial;
  final bool isSubmitting;
  final String submitLabel;
  final ValueChanged<TransactionFormData> onSubmit;

  @override
  State<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _notesController;
  late DateTime _date;
  String? _category;
  late String _paymentMethod;
  bool _categoryError = false;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _amountController = TextEditingController(
      text: initial?.amount.toString() ?? '',
    );
    _notesController = TextEditingController(text: initial?.notes ?? '');
    _date = initial?.date ?? DateTime.now();
    _category = initial?.category;
    _paymentMethod = initial?.paymentMethod ?? PaymentMethods.all.first;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
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
      // Keep the time-of-day of the existing value.
      _date = DateTime(
        picked.year,
        picked.month,
        picked.day,
        _date.hour,
        _date.minute,
      );
    });
  }

  void _submit() {
    final valid = _formKey.currentState!.validate();
    setState(() => _categoryError = _category == null);
    if (!valid || _category == null) return;
    final notes = _notesController.text.trim();
    widget.onSubmit(
      TransactionFormData(
        amountText: _amountController.text,
        category: _category,
        date: _date,
        paymentMethod: widget.showPaymentMethod ? _paymentMethod : null,
        notes: notes.isEmpty ? null : notes,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _amountController,
            autofocus: widget.initial == null,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            decoration: const InputDecoration(
              labelText: 'Amount',
              prefixIcon: Icon(Icons.attach_money),
            ),
            validator: (v) => parseAmount(v ?? '') == null
                ? 'Enter an amount greater than 0'
                : null,
          ),
          const SizedBox(height: 24),
          Text('Category', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final category in widget.categories)
                ChoiceChip(
                  avatar: Icon(categoryIcon(category), size: 18),
                  label: Text(category),
                  selected: _category == category,
                  onSelected: (_) => setState(() {
                    _category = category;
                    _categoryError = false;
                  }),
                ),
            ],
          ),
          if (_categoryError)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Select a category',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.calendar_today),
            title: const Text('Date'),
            subtitle: Text(formatDate(_date)),
            onTap: _pickDate,
          ),
          if (widget.showPaymentMethod) ...[
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _paymentMethod,
              decoration: const InputDecoration(labelText: 'Payment method'),
              items: [
                for (final method in PaymentMethods.all)
                  DropdownMenuItem(value: method, child: Text(method)),
              ],
              onChanged: (v) {
                if (v != null) setState(() => _paymentMethod = v);
              },
            ),
          ],
          const SizedBox(height: 16),
          TextFormField(
            controller: _notesController,
            maxLength: 200,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Notes (optional)'),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: widget.isSubmitting ? null : _submit,
              child: widget.isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(widget.submitLabel),
            ),
          ),
        ],
      ),
    );
  }
}
