import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/premium/premium_feature.dart';
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

    /// Incremented when a save hits a free-plan limit, so the page can open
    /// the paywall for [paywallFeature].
    @Default(0) int paywallCount,
    PremiumFeature? paywallFeature,
  }) = _AccountsState;
}
