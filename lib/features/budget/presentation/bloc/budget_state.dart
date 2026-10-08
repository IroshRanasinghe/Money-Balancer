import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/premium/premium_feature.dart';
import '../../domain/entities/budget_progress.dart';

part 'budget_state.freezed.dart';

enum BudgetListStatus { initial, loading, success, failure }

@freezed
abstract class BudgetState with _$BudgetState {
  const factory BudgetState({
    required int month,
    required int year,
    @Default(BudgetListStatus.initial) BudgetListStatus status,
    @Default(<BudgetProgress>[]) List<BudgetProgress> items,
    String? errorMessage,

    /// Incremented when a save hits a free-plan limit, so the page can open
    /// the paywall for [paywallFeature].
    @Default(0) int paywallCount,
    PremiumFeature? paywallFeature,
  }) = _BudgetState;
}
