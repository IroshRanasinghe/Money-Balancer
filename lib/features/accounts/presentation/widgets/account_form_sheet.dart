import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/ui/sheet_scaffold.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/account.dart';
import '../bloc/accounts_bloc.dart';
import 'account_tile.dart';

const _swatches = <int>[
  0xFF2563EB,
  0xFF0F172A,
  0xFF7C3AED,
  0xFF059669,
  0xFFDC2626,
  0xFFD97706,
];

class AccountFormSheet extends StatefulWidget {
  const AccountFormSheet({super.key, this.existing});

  final Account? existing;

  /// Shows the sheet; it receives the caller's [AccountsBloc].
  static Future<void> show(BuildContext context, {Account? existing}) {
    final bloc = context.read<AccountsBloc>();
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: AccountFormSheet(existing: existing),
      ),
    );
  }

  @override
  State<AccountFormSheet> createState() => _AccountFormSheetState();
}

class _AccountFormSheetState extends State<AccountFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _opening;
  late AccountType _type;
  late int _color;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    final a = widget.existing;
    _name = TextEditingController(text: a?.name ?? '');
    _opening = TextEditingController(
      text: a == null || a.openingBalance == 0
          ? ''
          : a.openingBalance.toString(),
    );
    _type = a?.type ?? AccountType.bank;
    _color = a?.colorValue ?? _swatches.first;
  }

  @override
  void dispose() {
    _name.dispose();
    _opening.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitted = true);
    context.read<AccountsBloc>().add(
      AccountSaveRequested(
        id: widget.existing?.id,
        createdAt: widget.existing?.createdAt,
        name: _name.text,
        type: _type,
        openingBalanceText: _opening.text,
        colorValue: _color,
      ),
    );
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete this account?'),
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
        AccountDeleteRequested(widget.existing!.id),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.existing != null;
    final theme = Theme.of(context);
    return BlocListener<AccountsBloc, AccountsState>(
      // A free-plan limit also closes the sheet; the page opens the paywall.
      listenWhen: (a, b) =>
          a.savedCount != b.savedCount || a.paywallCount != b.paywallCount,
      listener: (context, state) {
        if (_submitted) Navigator.pop(context);
      },
      child: SheetScaffold(
        title: editing ? 'Edit account' : 'Add account',
        actions: [
          Expanded(
            child: FilledButton(
              onPressed: _save,
              child: const Text('Save account'),
            ),
          ),
        ],
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _name,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (v) =>
                    (v ?? '').trim().isEmpty ? 'Enter an account name' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<AccountType>(
                initialValue: _type,
                decoration: const InputDecoration(labelText: 'Type'),
                items: [
                  for (final t in AccountType.values)
                    DropdownMenuItem(
                      value: t,
                      child: Row(
                        children: [
                          Icon(accountTypeIcon(t), size: 20),
                          const SizedBox(width: 12),
                          Text(t.label),
                        ],
                      ),
                    ),
                ],
                onChanged: (t) => setState(() => _type = t ?? _type),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _opening,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                decoration: const InputDecoration(labelText: 'Opening balance'),
                validator: (v) => parseSignedAmount(v ?? '') == null
                    ? 'Enter a valid amount'
                    : null,
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
              BlocBuilder<AccountsBloc, AccountsState>(
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
