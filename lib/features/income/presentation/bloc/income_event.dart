import 'package:equatable/equatable.dart';

import '../../../../shared/widgets/transaction_form.dart';

sealed class IncomeEvent extends Equatable {
  const IncomeEvent();

  @override
  List<Object?> get props => [];
}

class IncomeSubmitted extends IncomeEvent {
  const IncomeSubmitted(this.data);
  final TransactionFormData data;
}

class IncomeDeleteRequested extends IncomeEvent {
  const IncomeDeleteRequested();
}
