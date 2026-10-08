import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/constants.dart';
import '../../../../shared/form_submission_status.dart';
import '../../../../shared/widgets/transaction_form.dart';
import '../../../accounts/presentation/bloc/accounts_bloc.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../bloc/income_bloc.dart';

class IncomeFormPage extends StatelessWidget {
  const IncomeFormPage({super.key, this.initial});

  final Transaction? initial;

  Future<void> _confirmDelete(BuildContext context) async {
    final bloc = context.read<IncomeBloc>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete this income?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) bloc.add(const IncomeDeleteRequested());
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = initial != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Income' : 'Add Income'),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Delete',
              onPressed: () => _confirmDelete(context),
            ),
        ],
      ),
      body: BlocConsumer<IncomeBloc, IncomeState>(
        listener: (context, state) {
          if (state.status == FormSubmissionStatus.success) {
            context.pop(true);
          } else if (state.status == FormSubmissionStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Something went wrong.'),
              ),
            );
          }
        },
        builder: (context, state) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: BlocBuilder<AccountsBloc, AccountsState>(
            buildWhen: (a, b) =>
                a.status != b.status || !listEquals(a.items, b.items),
            builder: (context, accountsState) => TransactionForm(
              categories: AppCategories.income,
              showPaymentMethod: false,
              initial: initial,
              isSubmitting: state.status == FormSubmissionStatus.submitting,
              submitLabel: isEditing ? 'Update income' : 'Save income',
              accountsLoading: accountsState.status == AccountsStatus.initial ||
                  accountsState.status == AccountsStatus.loading,
              accounts: [for (final i in accountsState.items) i.account],
              onSubmit: (data) =>
                  context.read<IncomeBloc>().add(IncomeSubmitted(data)),
            ),
          ),
        ),
      ),
    );
  }
}
