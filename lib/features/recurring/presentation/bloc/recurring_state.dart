import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../premium/domain/entities/premium_feature.dart';
import '../../domain/entities/recurring_rule.dart';

part 'recurring_state.freezed.dart';

enum RecurringStatus { initial, loading, success, failure }

@freezed
abstract class RecurringState with _$RecurringState {
  const factory RecurringState({
    @Default(RecurringStatus.initial) RecurringStatus status,
    @Default(<RecurringRule>[]) List<RecurringRule> rules,
    String? errorMessage,
    String? infoMessage,

    /// Incremented on every successful save/delete so sheets can close.
    @Default(0) int savedCount,

    /// Incremented when a save hits a free-plan limit, so the page can open
    /// the paywall for [paywallFeature].
    @Default(0) int paywallCount,
    PremiumFeature? paywallFeature,
  }) = _RecurringState;
}
