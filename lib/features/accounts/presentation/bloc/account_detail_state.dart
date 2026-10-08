import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/account_activity.dart';
import '../../domain/entities/account_balance.dart';

part 'account_detail_state.freezed.dart';

enum AccountDetailStatus { initial, loading, success, failure }

@freezed
abstract class AccountDetailState with _$AccountDetailState {
  const factory AccountDetailState({
    @Default(AccountDetailStatus.initial) AccountDetailStatus status,
    AccountBalance? balance,
    @Default(<AccountActivity>[]) List<AccountActivity> activity,
    String? errorMessage,
  }) = _AccountDetailState;
}
