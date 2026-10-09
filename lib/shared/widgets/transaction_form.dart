import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../core/config/constants.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../features/accounts/domain/entities/account.dart';
import '../../features/cards/domain/entities/bank_card.dart';
import '../../features/settings/presentation/bloc/settings_bloc.dart';
import '../../features/transactions/domain/entities/transaction.dart';
import 'category_icon.dart';
import 'ui/app_card.dart';
import 'ui/settings_group.dart';
import 'ui/sheet_scaffold.dart';
import 'ui/status_pill.dart';

class TransactionFormData {
  const TransactionFormData({
    required this.amountText,
    required this.category,
    required this.date,
    this.paymentMethod,
    this.notes,
    this.cardId,
    this.cardLast4,
    this.accountId,
  });

  final String amountText;
  final String? category;
  final DateTime date;
  final String? paymentMethod;
  final String? notes;
  final String? cardId;
  final String? cardLast4;
  final String? accountId;
}

class TransactionForm extends StatefulWidget {
  const TransactionForm({
    super.key,
    required this.type,
    required this.categories,
    required this.showPaymentMethod,
    this.initial,
    required this.isSubmitting,
    required this.submitLabel,
    required this.onSubmit,
    this.cards = const [],
    this.onAddCard,
    this.cardsLoading = false,
    this.accounts = const [],
    this.accountsLoading = false,
  });

  /// Shown as a coloured pill above the amount.
  final TransactionType type;
  final List<String> categories;
  final bool showPaymentMethod;
  final Transaction? initial;
  final bool isSubmitting;
  final String submitLabel;
  final ValueChanged<TransactionFormData> onSubmit;
  final List<BankCard> cards;
  final VoidCallback? onAddCard;

  /// True while the saved cards are still loading; hides the card picker.
  final bool cardsLoading;
  final List<Account> accounts;

  /// True while accounts are still loading; hides the account picker.
  final bool accountsLoading;

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
  String? _accountId;
  bool _categoryError = false;
  bool _amountError = false;

  static const _amountErrorText =
      'Enter a valid amount greater than 0 (e.g. 1234.50)';

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
    _accountId = initial?.accountId;
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
    setState(() {
      _categoryError = _category == null;
      _amountError = parseAmount(_amountController.text) == null;
    });
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
        accountId: _accountId,
      ),
    );
  }

  /// Opens a radio-style sheet; resolves to null when dismissed, otherwise to
  /// a record wrapping the (possibly null) chosen value.
  Future<({T? value})?> _pick<T>({
    required String title,
    required T? current,
    required List<({String label, T? value})> options,
  }) {
    return showModalBottomSheet<({T? value})>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => SheetScaffold(
        title: title,
        child: Column(
          children: [
            for (final o in options)
              ListTile(
                leading: Icon(
                  o.value == current
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: o.value == current
                      ? Theme.of(ctx).colorScheme.primary
                      : ctx.tokens.textSecondary,
                ),
                title: Text(o.label),
                onTap: () => Navigator.pop(ctx, (value: o.value)),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickPaymentMethod() async {
    final r = await _pick<String>(
      title: 'Payment method',
      current: _paymentMethod,
      options: [for (final m in PaymentMethods.all) (label: m, value: m)],
    );
    final v = r?.value;
    if (v != null) setState(() => _paymentMethod = v);
  }

  Future<void> _pickCard() async {
    final knownIds = {for (final c in widget.cards) c.id};
    final removed = _cardId != null && !knownIds.contains(_cardId);
    final r = await _pick<String>(
      title: 'Which card?',
      current: _cardId,
      options: [
        (label: 'No specific card', value: null),
        for (final c in widget.cards)
          (label: '${c.nickname} •••• ${c.last4}', value: c.id),
        if (removed) (label: '•••• $_cardLast4 (removed)', value: _cardId),
      ],
    );
    if (r == null) return;
    final id = r.value;
    setState(() {
      _cardId = id;
      if (id == null) {
        _cardLast4 = null;
      } else {
        final match = widget.cards.where((c) => c.id == id);
        _cardLast4 = match.isNotEmpty
            ? match.first.last4
            : widget.initial?.cardLast4;
      }
    });
  }

  Future<void> _pickAccount() async {
    final knownIds = {for (final a in widget.accounts) a.id};
    final removed = _accountId != null && !knownIds.contains(_accountId);
    final r = await _pick<String>(
      title: 'Account',
      current: _accountId,
      options: [
        (label: 'No account', value: null),
        for (final a in widget.accounts) (label: a.name, value: a.id),
        if (removed) (label: '(removed account)', value: _accountId),
      ],
    );
    if (r != null) setState(() => _accountId = r.value);
  }

  String _cardSubtitle() {
    if (_cardId == null) return 'No specific card';
    final match = widget.cards.where((c) => c.id == _cardId);
    if (match.isNotEmpty) {
      final c = match.first;
      return '${c.nickname} •••• ${c.last4}';
    }
    return '•••• $_cardLast4 (removed)';
  }

  String _accountSubtitle() {
    if (_accountId == null) return 'No account';
    final match = widget.accounts.where((a) => a.id == _accountId);
    return match.isNotEmpty ? match.first.name : '(removed account)';
  }

  Widget _buildAmount(ThemeData theme, String symbol) {
    final t = context.tokens;
    final isExpense = widget.type == TransactionType.expense;
    final tint = isExpense ? t.danger : t.success;
    final amountStyle = theme.textTheme.displaySmall?.copyWith(
      fontFeatures: const [FontFeature.tabularFigures()],
      letterSpacing: -0.5,
    );
    return Column(
      children: [
        StatusPill(label: isExpense ? 'Expense' : 'Income', color: tint),
        const SizedBox(height: AppSpacing.md),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              symbol,
              style: amountStyle?.copyWith(color: t.textSecondary),
            ),
            const SizedBox(width: AppSpacing.sm),
            Flexible(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 240),
                child: IntrinsicWidth(
                  child: TextFormField(
                    controller: _amountController,
                    autofocus: widget.initial == null,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    textAlign: TextAlign.center,
                    style: amountStyle,
                    onChanged: (v) {
                      if (_amountError && parseAmount(v) != null) {
                        setState(() => _amountError = false);
                      }
                    },
                    decoration: InputDecoration(
                      hintText: '0.00',
                      hintStyle: amountStyle?.copyWith(
                        color: t.textSecondary.withValues(alpha: 0.5),
                      ),
                      filled: false,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      // The message is shown below the whole row instead.
                      errorStyle: const TextStyle(fontSize: 0, height: 0),
                    ),
                    validator: (v) =>
                        parseAmount(v ?? '') == null ? _amountErrorText : null,
                  ),
                ),
              ),
            ),
          ],
        ),
        if (_amountError)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              _amountErrorText,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(color: t.danger),
            ),
          ),
      ],
    );
  }

  Widget _buildCategories(ThemeData theme) {
    final t = context.tokens;
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = AppSpacing.sm;
        final width = (constraints.maxWidth - gap * 3) / 4;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final category in widget.categories)
              SizedBox(
                width: width,
                child: Semantics(
                  button: true,
                  selected: _category == category,
                  label: category,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => setState(() {
                      _category = category;
                      _categoryError = false;
                    }),
                    child: AnimatedContainer(
                      duration: MediaQuery.disableAnimationsOf(context)
                          ? Duration.zero
                          : const Duration(milliseconds: 200),
                      curve: Curves.easeOutCubic,
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _category == category
                            ? theme.colorScheme.primary.withValues(alpha: 0.08)
                            : Colors.transparent,
                        borderRadius: AppRadius.mdAll,
                        border: Border.all(
                          color: _category == category
                              ? theme.colorScheme.primary
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CategoryIcon(category: category, size: 40),
                          const SizedBox(height: 6),
                          Text(
                            category,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: _category == category
                                  ? t.textPrimary
                                  : t.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.tokens;
    final currency = context.select(
      (SettingsBloc b) => b.state.settings.currency,
    );
    final symbol = NumberFormat.simpleCurrency(name: currency).currencySymbol;
    final showCards = widget.showPaymentMethod &&
        _paymentMethod == 'Card' &&
        !widget.cardsLoading;
    final showAccounts =
        !widget.accountsLoading && widget.accounts.isNotEmpty;
    final addCard = showCards && widget.cards.isEmpty && _cardId == null;

    return Form(
      key: _formKey,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.gutter,
                AppSpacing.sm,
                AppSpacing.gutter,
                AppSpacing.xl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildAmount(theme, symbol),
                  const SizedBox(height: AppSpacing.xxl),
                  Text('Category', style: theme.textTheme.titleSmall),
                  const SizedBox(height: AppSpacing.md),
                  _buildCategories(theme),
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
                  const SizedBox(height: AppSpacing.xl),
                  AppCard(
                    padding: EdgeInsets.zero,
                    child: ClipRRect(
                      borderRadius: AppRadius.lgAll,
                      child: Column(
                        children: [
                          SettingsTile(
                            icon: Icons.calendar_today_rounded,
                            iconColor: theme.colorScheme.primary,
                            title: 'Date',
                            subtitle: formatDate(_date),
                            onTap: _pickDate,
                          ),
                          if (widget.showPaymentMethod) ...[
                            _divider(t),
                            SettingsTile(
                              icon: Icons.payments_rounded,
                              iconColor: t.success,
                              title: 'Payment method',
                              subtitle: _paymentMethod,
                              onTap: _pickPaymentMethod,
                            ),
                          ],
                          if (showCards) ...[
                            _divider(t),
                            if (addCard)
                              SettingsTile(
                                icon: Icons.add_card_rounded,
                                iconColor: t.warning,
                                title: 'Add a card',
                                onTap: widget.onAddCard,
                              )
                            else
                              SettingsTile(
                                icon: Icons.credit_card_rounded,
                                iconColor: t.warning,
                                title: 'Which card?',
                                subtitle: _cardSubtitle(),
                                onTap: _pickCard,
                              ),
                          ],
                          if (showAccounts) ...[
                            _divider(t),
                            SettingsTile(
                              icon: Icons.account_balance_rounded,
                              iconColor: const Color(0xFF7C3AED),
                              title: 'Account',
                              subtitle: _accountSubtitle(),
                              onTap: _pickAccount,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  TextFormField(
                    controller: _notesController,
                    maxLength: 200,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Notes (optional)',
                    ),
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.gutter,
                AppSpacing.sm,
                AppSpacing.gutter,
                AppSpacing.lg,
              ),
              child: SizedBox(
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider(AppTokens t) =>
      Divider(height: 1, indent: SettingsGroup.dividerInset, color: t.border);
}
