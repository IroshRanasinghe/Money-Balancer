import 'package:equatable/equatable.dart';

import '../../../../shared/widgets/transaction_form.dart';

sealed class ExpenseEvent extends Equatable {
  const ExpenseEvent();

  @override
  List<Object?> get props => [];
}

class ExpenseSubmitted extends ExpenseEvent {
  const ExpenseSubmitted(this.data);
  final TransactionFormData data;
}

class ExpenseDeleteRequested extends ExpenseEvent {
  const ExpenseDeleteRequested();
}
