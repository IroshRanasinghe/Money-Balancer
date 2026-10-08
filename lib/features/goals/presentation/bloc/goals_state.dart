import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/premium/premium_feature.dart';
import '../../domain/entities/savings_goal.dart';

part 'goals_state.freezed.dart';

enum GoalsStatus { initial, loading, success, failure }

@freezed
abstract class GoalsState with _$GoalsState {
  const factory GoalsState({
    @Default(GoalsStatus.initial) GoalsStatus status,
    @Default(<SavingsGoal>[]) List<SavingsGoal> goals,
    String? errorMessage,
    String? infoMessage,

    /// Incremented on every successful save/delete/adjust so sheets can close.
    @Default(0) int savedCount,

    /// Incremented when a save hits a free-plan limit, so the page can open
    /// the paywall for [paywallFeature].
    @Default(0) int paywallCount,
    PremiumFeature? paywallFeature,
  }) = _GoalsState;
}
