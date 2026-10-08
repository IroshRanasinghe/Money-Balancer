import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_account_activity.dart';
import '../../domain/usecases/get_account_balances.dart';
import 'account_detail_event.dart';
import 'account_detail_state.dart';

export 'account_detail_event.dart';
export 'account_detail_state.dart';

class AccountDetailBloc extends Bloc<AccountDetailEvent, AccountDetailState> {
  AccountDetailBloc(this._getAccountBalances, this._getAccountActivity)
    : super(const AccountDetailState()) {
    on<AccountDetailLoadRequested>(_onLoad);
  }

  final GetAccountBalances _getAccountBalances;
  final GetAccountActivity _getAccountActivity;

  Future<void> _onLoad(
    AccountDetailLoadRequested event,
    Emitter<AccountDetailState> emit,
  ) async {
    emit(
      state.copyWith(status: AccountDetailStatus.loading, errorMessage: null),
    );
    final balances = await _getAccountBalances();
    final activity = await _getAccountActivity(event.accountId);
    balances.fold(
      (failure) => emit(
        state.copyWith(
          status: AccountDetailStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (items) {
        final match = items.where((b) => b.account.id == event.accountId);
        if (match.isEmpty) {
          emit(
            state.copyWith(
              status: AccountDetailStatus.failure,
              errorMessage: 'Account not found.',
            ),
          );
          return;
        }
        activity.fold(
          (failure) => emit(
            state.copyWith(
              status: AccountDetailStatus.failure,
              errorMessage: failure.message,
            ),
          ),
          (rows) => emit(
            state.copyWith(
              status: AccountDetailStatus.success,
              balance: match.first,
              activity: rows,
              errorMessage: null,
            ),
          ),
        );
      },
    );
  }
}
