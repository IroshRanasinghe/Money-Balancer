import 'package:equatable/equatable.dart';

import '../../domain/entities/transaction.dart';
import 'transaction_state.dart';

sealed class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object?> get props => [];
}

class TransactionsLoadRequested extends TransactionEvent {
  const TransactionsLoadRequested();
}

class TransactionTypeFilterChanged extends TransactionEvent {
  const TransactionTypeFilterChanged(this.type);
  final TransactionType? type;
  @override
  List<Object?> get props => [type];
}

class TransactionCategoryFilterChanged extends TransactionEvent {
  const TransactionCategoryFilterChanged(this.category);
  final String? category;
  @override
  List<Object?> get props => [category];
}

class TransactionSortChanged extends TransactionEvent {
  const TransactionSortChanged(this.sort);
  final TransactionSort sort;
  @override
  List<Object?> get props => [sort];
}

class TransactionDeleteRequested extends TransactionEvent {
  const TransactionDeleteRequested(this.id);
  final String id;
  @override
  List<Object?> get props => [id];
}
