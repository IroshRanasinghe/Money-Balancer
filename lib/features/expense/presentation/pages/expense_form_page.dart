import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/constants.dart';
import '../../../../shared/form_submission_status.dart';
import '../../../../shared/widgets/transaction_form.dart';
import '../../../accounts/presentation/bloc/accounts_bloc.dart';
import '../../../cards/presentation/bloc/cards_bloc.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../bloc/expense_bloc.dart';

class ExpenseFormPage extends StatelessWidget {
  const ExpenseFormPage({super.key, this.initial});

  final Transaction? initial;

  Future<void> _confirmDelete(BuildContext context) async {
    final bloc = context.read<ExpenseBloc>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete this expense?'),
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
    if (confirmed == true) bloc.add(const ExpenseDeleteRequested());
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = initial != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Expense' : 'Add Expense'),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Delete',
              onPressed: () => _confirmDelete(context),
            ),
        ],
      ),
      body: BlocConsumer<ExpenseBloc, ExpenseState>(
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
        builder: (context, state) => BlocBuilder<AccountsBloc, AccountsState>(
            buildWhen: (a, b) =>
                a.status != b.status || !listEquals(a.items, b.items),
            builder: (context, accountsState) =>
                BlocBuilder<CardsBloc, CardsState>(
                  buildWhen: (a, b) =>
                      a.status != b.status || !listEquals(a.items, b.items),
                  builder: (context, cardsState) => TransactionForm(
                    type: TransactionType.expense,
                    accountsLoading:
                        accountsState.status == AccountsStatus.initial ||
                        accountsState.status == AccountsStatus.loading,
                    accounts: [for (final i in accountsState.items) i.account],
                    categories: AppCategories.expense,
                    showPaymentMethod: true,
                    initial: initial,
                    isSubmitting:
                        state.status == FormSubmissionStatus.submitting,
                    submitLabel: isEditing ? 'Update expense' : 'Save expense',
                    cardsLoading:
                        cardsState.status == CardsStatus.initial ||
                        cardsState.status == CardsStatus.loading,
                    cards: [for (final i in cardsState.items) i.card],
                    onAddCard: () async {
                      final cardsBloc = context.read<CardsBloc>();
                      await context.push(AppRoutes.cards);
                      if (context.mounted) {
                        cardsBloc.add(const CardsLoadRequested());
                      }
                    },
                    onSubmit: (data) =>
                        context.read<ExpenseBloc>().add(ExpenseSubmitted(data)),
                  ),
                ),
          ),
      ),
    );
  }
}
