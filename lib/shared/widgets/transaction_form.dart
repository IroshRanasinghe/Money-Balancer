import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../core/utils/formatters.dart';
import '../../core/config/constants.dart';
import '../../features/cards/domain/entities/bank_card.dart';
import '../../features/settings/presentation/bloc/settings_bloc.dart';
import '../../features/transactions/domain/entities/transaction.dart';
import 'category_icon.dart';

class TransactionFormData {
  const TransactionFormData({
    required this.amountText,
    required this.category,
    required this.date,
    this.paymentMethod,
    this.notes,
    this.cardId,
    this.cardLast4,
  });

  final String amountText;
  final String? category;
  final DateTime date;
  final String? paymentMethod;
  final String? notes;
  final String? cardId;
  final String? cardLast4;
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
    this.cards = const [],
    this.onAddCard,
  });

  final List<String> categories;
  final bool showPaymentMethod;
  final Transaction? initial;
  final bool isSubmitting;
  final String submitLabel;
  final ValueChanged<TransactionFormData> onSubmit;
  final List<BankCard> cards;
  final VoidCallback? onAddCard;

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
  String? _cardId;
  String? _cardLast4;
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
    _cardId = initial?.cardId;
    _cardLast4 = initial?.cardLast4;
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
    final isCard = widget.showPaymentMethod && _paymentMethod == 'Card';
    widget.onSubmit(
      TransactionFormData(
        amountText: _amountController.text,
        category: _category,
        date: _date,
        paymentMethod: widget.showPaymentMethod ? _paymentMethod : null,
        notes: notes.isEmpty ? null : notes,
        cardId: isCard ? _cardId : null,
        cardLast4: isCard ? _cardLast4 : null,
      ),
    );
  }

  Widget _buildCardPicker() {
    if (widget.cards.isEmpty && _cardId == null) {
      return Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          onPressed: widget.onAddCard,
          icon: const Icon(Icons.add_card),
          label: const Text('Add a card'),
        ),
      );
    }
    final knownIds = {for (final c in widget.cards) c.id};
    final removed = _cardId != null && !knownIds.contains(_cardId);
    return DropdownButtonFormField<String?>(
      initialValue: _cardId,
      decoration: const InputDecoration(labelText: 'Which card?'),
      items: [
        const DropdownMenuItem<String?>(
          value: null,
          child: Text('No specific card'),
        ),
        for (final c in widget.cards)
          DropdownMenuItem<String?>(
            value: c.id,
            child: Text('${c.nickname} •••• ${c.last4}'),
          ),
        if (removed)
          DropdownMenuItem<String?>(
            value: _cardId,
            child: Text('•••• ${widget.initial?.cardLast4 ?? _cardLast4} (removed)'),
          ),
      ],
      onChanged: (id) => setState(() {
        _cardId = id;
        if (id == null) {
          _cardLast4 = null;
        } else {
          final match = widget.cards.where((c) => c.id == id);
          _cardLast4 =
              match.isNotEmpty ? match.first.last4 : widget.initial?.cardLast4;
        }
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currency =
        context.select((SettingsBloc b) => b.state.settings.currency);
    final symbol = NumberFormat.simpleCurrency(name: currency).currencySymbol;
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
            decoration: InputDecoration(
              labelText: 'Amount',
              prefixText: '$symbol ',
            ),
            validator: (v) => parseAmount(v ?? '') == null
                ? 'Enter a valid amount greater than 0 (e.g. 1234.50)'
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
            if (_paymentMethod == 'Card') ...[
              const SizedBox(height: 12),
              _buildCardPicker(),
            ],
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
