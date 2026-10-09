import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/ui/sheet_scaffold.dart';
import '../../../settings/presentation/bloc/settings_bloc.dart';
import '../../domain/card_number.dart';
import '../../domain/entities/bank_card.dart';
import '../bloc/cards_bloc.dart';
import 'bank_card_tile.dart';

const _swatches = <int>[
  0xFF2563EB,
  0xFF0F172A,
  0xFF7C3AED,
  0xFF059669,
  0xFFDC2626,
  0xFFD97706,
];

class CardFormSheet extends StatefulWidget {
  const CardFormSheet({super.key, this.existing});

  final BankCard? existing;

  /// Shows the sheet; it receives the caller's [CardsBloc].
  static Future<void> show(BuildContext context, {BankCard? existing}) {
    final bloc = context.read<CardsBloc>();
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: CardFormSheet(existing: existing),
      ),
    );
  }

  @override
  State<CardFormSheet> createState() => _CardFormSheetState();
}

class _CardFormSheetState extends State<CardFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nickname;
  late final TextEditingController _bankName;
  late final TextEditingController _cardNumber;
  late CardType _type;
  late CardNetwork _network;
  late int _month;
  late int _year;
  late int _color;
  String? _expiryError;
  bool _networkChosenManually = false;

  @override
  void initState() {
    super.initState();
    final c = widget.existing;
    final now = DateTime.now();
    _nickname = TextEditingController(text: c?.nickname ?? '');
    _bankName = TextEditingController(text: c?.bankName ?? '');
    _cardNumber = TextEditingController();
    _type = c?.type ?? CardType.debit;
    _network = c?.network ?? CardNetwork.visa;
    _month = c?.expiryMonth ?? now.month;
    _year = c?.expiryYear ?? now.year;
    _color = c?.colorValue ?? _swatches.first;
  }

  @override
  void dispose() {
    _nickname.dispose();
    _bankName.dispose();
    _cardNumber.dispose();
    super.dispose();
  }

  bool _expiryValid() {
    final now = DateTime.now();
    return _month >= 1 &&
        _month <= 12 &&
        _year >= now.year &&
        _year <= now.year + 20 &&
        DateTime(_year, _month + 1).isAfter(now);
  }

  void _save() {
    final valid = _formKey.currentState!.validate();
    final expiryOk = _expiryValid();
    setState(
      () => _expiryError = expiryOk ? null : 'Enter a valid expiry date',
    );
    if (!valid || !expiryOk) return;
    context.read<CardsBloc>().add(
      CardSaveRequested(
        id: widget.existing?.id,
        createdAt: widget.existing?.createdAt,
        nickname: _nickname.text,
        bankName: _bankName.text,
        type: _type,
        network: _network,
        cardNumber: digitsOnly(_cardNumber.text),
        existingLast4: widget.existing?.last4,
        expiryMonth: _month,
        expiryYear: _year,
        colorValue: _color,
      ),
    );
    Navigator.pop(context);
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete this card?'),
        content: Text(
          'Expenses already linked keep showing ••••${widget.existing!.last4}.',
        ),
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
      context.read<CardsBloc>().add(CardDeleteRequested(widget.existing!.id));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.existing != null;
    final theme = Theme.of(context);
    final currency = context.select(
      (SettingsBloc b) => b.state.settings.currency,
    );
    final thisYear = DateTime.now().year;
    final years = <int>{
      for (var y = thisYear; y <= thisYear + 20; y++) y,
      _year,
    }.toList()..sort();
    return SheetScaffold(
      title: editing ? 'Edit card' : 'Add card',
      actions: [
        Expanded(
          child: FilledButton(onPressed: _save, child: const Text('Save card')),
        ),
      ],
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListenableBuilder(
              listenable: Listenable.merge([_nickname, _bankName, _cardNumber]),
              builder: (context, _) {
                final digits = digitsOnly(_cardNumber.text);
                final last4 = digits.length >= 4
                    ? digits.substring(digits.length - 4)
                    : (widget.existing?.last4 ?? '0000');
                return BankCardFace(
                  card: BankCard(
                    id: widget.existing?.id ?? 'preview',
                    nickname: _nickname.text.trim(),
                    bankName: _bankName.text.trim(),
                    type: _type,
                    network: _network,
                    last4: last4,
                    expiryMonth: _month,
                    expiryYear: _year,
                    colorValue: _color,
                    createdAt: widget.existing?.createdAt ?? DateTime.now(),
                  ),
                  spent: 0,
                  currencyCode: currency,
                );
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nickname,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Nickname'),
              validator: (v) =>
                  (v ?? '').trim().isEmpty ? 'Enter a card nickname' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _bankName,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Bank name (optional)',
              ),
            ),
            const SizedBox(height: 12),
            SegmentedButton<CardType>(
              segments: const [
                ButtonSegment(value: CardType.debit, label: Text('Debit')),
                ButtonSegment(value: CardType.credit, label: Text('Credit')),
              ],
              selected: {_type},
              onSelectionChanged: (s) => setState(() => _type = s.first),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<CardNetwork>(
              initialValue: _network,
              decoration: const InputDecoration(labelText: 'Network'),
              items: [
                for (final n in CardNetwork.values)
                  DropdownMenuItem(value: n, child: Text(cardNetworkLabel(n))),
              ],
              onChanged: (n) => setState(() {
                _network = n ?? _network;
                _networkChosenManually = true;
              }),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _cardNumber,
              keyboardType: TextInputType.number,
              autofillHints: const [AutofillHints.creditCardNumber],
              inputFormatters: [_CardNumberFormatter()],
              decoration: InputDecoration(
                labelText: 'Card number',
                hintText: editing
                    ? 'Leave blank to keep •••• ${widget.existing!.last4}'
                    : null,
              ),
              onChanged: (v) {
                if (_networkChosenManually) return;
                final detected = detectNetwork(digitsOnly(v));
                if (detected != CardNetwork.other && detected != _network) {
                  setState(() => _network = detected);
                }
              },
              validator: (v) {
                final digits = digitsOnly(v ?? '');
                if (editing && digits.isEmpty) return null;
                return isValidCardNumber(digits)
                    ? null
                    : 'Enter a valid card number';
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    initialValue: _month,
                    decoration: const InputDecoration(
                      labelText: 'Expiry month',
                    ),
                    items: [
                      for (var m = 1; m <= 12; m++)
                        DropdownMenuItem(
                          value: m,
                          child: Text(m.toString().padLeft(2, '0')),
                        ),
                    ],
                    onChanged: (m) => setState(() => _month = m ?? _month),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    initialValue: _year,
                    decoration: const InputDecoration(labelText: 'Expiry year'),
                    items: [
                      for (final y in years)
                        DropdownMenuItem(value: y, child: Text('$y')),
                    ],
                    onChanged: (y) => setState(() => _year = y ?? _year),
                  ),
                ),
              ],
            ),
            if (_expiryError != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _expiryError!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Text('Colour', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final value in _swatches)
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
            if (editing)
              TextButton(
                onPressed: _delete,
                style: TextButton.styleFrom(foregroundColor: AppColors.danger),
                child: const Text('Delete'),
              ),
          ],
        ),
      ),
    );
  }
}

/// Keeps digits only (max 19), groups them as the user types and keeps the
/// caret after the same digit. Backspacing over a space removes the digit
/// before it.
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    final end = newValue.selection.end.clamp(0, text.length);
    var digits = digitsOnly(text);
    var before = digitsOnly(text.substring(0, end)).length;
    final deletedSeparator =
        text.length < oldValue.text.length &&
        digits == digitsOnly(oldValue.text);
    if (deletedSeparator && before > 0) {
      digits = digits.replaceRange(before - 1, before, '');
      before--;
    }
    if (digits.length > 19) digits = digits.substring(0, 19);
    if (before > digits.length) before = digits.length;
    final formatted = formatCardNumber(digits);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(
        offset: caretOffsetForDigitCount(formatted, before),
      ),
    );
  }
}
