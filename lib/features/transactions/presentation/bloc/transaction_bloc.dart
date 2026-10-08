import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/delete_transaction.dart';
import '../../domain/usecases/get_transactions.dart';
import 'transaction_event.dart';
import 'transaction_state.dart';

export 'transaction_event.dart';
export 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  TransactionBloc(this._getTransactions, this._deleteTransaction)
      : super(const TransactionState()) {
    on<TransactionsLoadRequested>(_onLoad);
    on<TransactionTypeFilterChanged>(
      (e, emit) => emit(state.copyWith(
        typeFilter: e.type,
        categoryFilter: null,
        errorMessage: null,
      )),
    );
    on<TransactionCategoryFilterChanged>(
      (e, emit) => emit(
          state.copyWith(categoryFilter: e.category, errorMessage: null)),
    );
    on<TransactionSortChanged>(
      (e, emit) => emit(state.copyWith(sort: e.sort, errorMessage: null)),
    );
    on<TransactionDeleteRequested>(_onDelete);
  }

  final GetTransactions _getTransactions;
  final DeleteTransaction _deleteTransaction;

  Future<void> _onLoad(
      TransactionsLoadRequested event, Emitter<TransactionState> emit) async {
    emit(state.copyWith(
        status: TransactionListStatus.loading, errorMessage: null));
    final result = await _getTransactions();
    result.fold(
      (failure) => emit(state.copyWith(
        status: TransactionListStatus.failure,
        errorMessage: failure.message,
      )),
      (list) => emit(state.copyWith(
        status: TransactionListStatus.success,
        all: list,
        errorMessage: null,
      )),
    );
  }

  Future<void> _onDelete(
      TransactionDeleteRequested event, Emitter<TransactionState> emit) async {
    emit(state.copyWith(errorMessage: null));
    final result = await _deleteTransaction(event.id);
    await result.fold(
      (failure) async => emit(state.copyWith(errorMessage: failure.message)),
      (_) => _onLoad(const TransactionsLoadRequested(), emit),
    );
  }
}
