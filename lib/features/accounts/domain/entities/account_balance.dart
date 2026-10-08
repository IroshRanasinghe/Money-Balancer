import 'package:freezed_annotation/freezed_annotation.dart';

import 'account.dart';

part 'account_balance.freezed.dart';

@freezed
abstract class AccountBalance with _$AccountBalance {
  const factory AccountBalance({
    required Account account,
    required double balance,
  }) = _AccountBalance;
}
