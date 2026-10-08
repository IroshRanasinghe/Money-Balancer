import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/account.dart';
import '../../domain/entities/transfer.dart';
import '../../domain/usecases/delete_account.dart';
import '../../domain/usecases/delete_transfer.dart';
import '../../domain/usecases/get_account_balances.dart';
import '../../domain/usecases/save_account.dart';
import '../../domain/usecases/save_transfer.dart';
import 'accounts_event.dart';
import 'accounts_state.dart';

export 'accounts_event.dart';
export 'accounts_state.dart';

class AccountsBloc extends Bloc<AccountsEvent, AccountsState> {
  AccountsBloc(
    this._getAccountBalances,
    this._saveAccount,
    this._deleteAccount,
    this._saveTransfer,
    this._deleteTransfer,
    this._uuid,
  ) : super(const AccountsState()) {
    on<AccountsLoadRequested>((e, emit) => _load(emit));
    on<AccountSaveRequested>(_onSaveAccount);
    on<AccountDeleteRequested>(_onDeleteAccount);
    on<TransferSaveRequested>(_onSaveTransfer);
    on<TransferDeleteRequested>(_onDeleteTransfer);
  }

  final GetAccountBalances _getAccountBalances;
  final SaveAccount _saveAccount;
  final DeleteAccount _deleteAccount;
  final SaveTransfer _saveTransfer;
  final DeleteTransfer _deleteTransfer;
  final Uuid _uuid;

  Future<void> _load(Emitter<AccountsState> emit) async {
    emit(state.copyWith(status: AccountsStatus.loading, errorMessage: null));
    final result = await _getAccountBalances();
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: AccountsStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (items) => emit(
        state.copyWith(
          status: AccountsStatus.success,
          items: items,
          errorMessage: null,
        ),
      ),
    );
  }

  /// On success bump [AccountsState.savedCount] and reload; on failure report.
  Future<void> _finish(
    Either<Failure, void> result,
    Emitter<AccountsState> emit,
  ) async {
    await result.fold(
      (failure) async => emit(state.copyWith(errorMessage: failure.message)),
      (_) async {
        emit(state.copyWith(savedCount: state.savedCount + 1));
        await _load(emit);
      },
    );
  }

  Future<void> _onSaveAccount(
    AccountSaveRequested event,
    Emitter<AccountsState> emit,
  ) async {
    emit(state.copyWith(errorMessage: null));
    final name = event.name.trim();
    if (name.isEmpty) {
      emit(state.copyWith(errorMessage: 'Enter an account name'));
      return;
    }
    final opening = parseSignedAmount(event.openingBalanceText);
    if (opening == null) {
      emit(state.copyWith(errorMessage: 'Enter a valid amount'));
      return;
    }
    final result = await _saveAccount(
      Account(
        id: event.id ?? _uuid.v4(),
        name: name,
        type: event.type,
        openingBalance: opening,
        colorValue: event.colorValue,
        createdAt: event.createdAt ?? DateTime.now(),
      ),
    );
    await _finish(result, emit);
  }

  Future<void> _onDeleteAccount(
    AccountDeleteRequested event,
    Emitter<AccountsState> emit,
  ) async {
    emit(state.copyWith(errorMessage: null));
    await _finish(await _deleteAccount(event.id), emit);
  }

  Future<void> _onSaveTransfer(
    TransferSaveRequested event,
    Emitter<AccountsState> emit,
  ) async {
    emit(state.copyWith(errorMessage: null));
    final from = event.fromAccountId;
    final to = event.toAccountId;
    if (from == null || to == null) {
      emit(state.copyWith(errorMessage: 'Choose both accounts'));
      return;
    }
    if (from == to) {
      emit(state.copyWith(errorMessage: 'Choose two different accounts'));
      return;
    }
    final amount = parseAmount(event.amountText);
    if (amount == null) {
      emit(state.copyWith(errorMessage: 'Enter an amount greater than 0'));
      return;
    }
    final notes = event.notes?.trim();
    final result = await _saveTransfer(
      Transfer(
        id: event.id ?? _uuid.v4(),
        fromAccountId: from,
        toAccountId: to,
        amount: amount,
        date: event.date,
        notes: notes == null || notes.isEmpty ? null : notes,
        createdAt: event.createdAt ?? DateTime.now(),
      ),
    );
    await _finish(result, emit);
  }

  Future<void> _onDeleteTransfer(
    TransferDeleteRequested event,
    Emitter<AccountsState> emit,
  ) async {
    emit(state.copyWith(errorMessage: null));
    await _finish(await _deleteTransfer(event.id), emit);
  }
}
