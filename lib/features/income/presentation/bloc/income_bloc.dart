import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/form_submission_status.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/domain/usecases/delete_transaction.dart';
import '../../../transactions/domain/usecases/update_transaction.dart';
import '../../domain/usecases/add_income.dart';
import 'income_event.dart';
import 'income_state.dart';

export 'income_event.dart';
export 'income_state.dart';

class IncomeBloc extends Bloc<IncomeEvent, IncomeState> {
  IncomeBloc(
    this._addIncome,
    this._updateTransaction,
    this._deleteTransaction, {
    this.initial,
  }) : super(const IncomeState()) {
    on<IncomeSubmitted>(_onSubmitted);
    on<IncomeDeleteRequested>(_onDeleteRequested);
  }

  final AddIncome _addIncome;
  final UpdateTransaction _updateTransaction;
  final DeleteTransaction _deleteTransaction;
  final Transaction? initial;

  Future<void> _onSubmitted(
    IncomeSubmitted event,
    Emitter<IncomeState> emit,
  ) async {
    final data = event.data;
    final amount = parseAmount(data.amountText);
    if (amount == null) {
      emit(
        state.copyWith(
          status: FormSubmissionStatus.failure,
          errorMessage: const ValidationFailure(
            'Enter a valid amount greater than 0 (e.g. 1234.50)',
          ).message,
        ),
      );
      return;
    }
    final category = data.category;
    if (category == null) {
      emit(
        state.copyWith(
          status: FormSubmissionStatus.failure,
          errorMessage: const ValidationFailure('Select a category').message,
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        status: FormSubmissionStatus.submitting,
        errorMessage: null,
      ),
    );
    final current = initial;
    final result = current == null
        ? await _addIncome(
            amount: amount,
            category: category,
            date: data.date,
            notes: data.notes,
          )
        : await _updateTransaction(
            current.copyWith(
              amount: amount,
              category: category,
              date: data.date,
              notes: data.notes,
            ),
          );
    _emitResult(result, emit);
  }

  Future<void> _onDeleteRequested(
    IncomeDeleteRequested event,
    Emitter<IncomeState> emit,
  ) async {
    final current = initial;
    if (current == null) return;
    emit(
      state.copyWith(
        status: FormSubmissionStatus.submitting,
        errorMessage: null,
      ),
    );
    _emitResult(await _deleteTransaction(current.id), emit);
  }

  void _emitResult(Either<Failure, void> result, Emitter<IncomeState> emit) {
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: FormSubmissionStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (_) => emit(state.copyWith(status: FormSubmissionStatus.success)),
    );
  }
}
