import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/account_balance.dart';

part 'accounts_state.freezed.dart';

enum AccountsStatus { initial, loading, success, failure }

@freezed
abstract class AccountsState with _$AccountsState {
  const factory AccountsState({
    @Default(AccountsStatus.initial) AccountsStatus status,
    @Default(<AccountBalance>[]) List<AccountBalance> items,
    String? errorMessage,

    /// Incremented on every successful save/delete so sheets can close.
    @Default(0) int savedCount,
  }) = _AccountsState;
}
