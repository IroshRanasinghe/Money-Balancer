import 'package:freezed_annotation/freezed_annotation.dart';

import 'budget.dart';

part 'budget_progress.freezed.dart';

const kBudgetWarningThreshold = 0.8;

enum BudgetStatus { onTrack, warning, exceeded }

@freezed
abstract class BudgetProgress with _$BudgetProgress {
  const BudgetProgress._();

  const factory BudgetProgress({
    required Budget budget,
    required double spent,
  }) = _BudgetProgress;

  /// spent / limit; never NaN or infinite.
  double get ratio {
    if (budget.limit > 0) return spent / budget.limit;
    return spent > 0 ? 1.0 : 0.0;
  }

  /// 0..1 for progress bars.
  double get progress => ratio.clamp(0.0, 1.0);

  double get remaining => budget.limit - spent;

  BudgetStatus get status {
    if (spent > budget.limit) return BudgetStatus.exceeded;
    if (ratio >= kBudgetWarningThreshold) return BudgetStatus.warning;
    return BudgetStatus.onTrack;
  }
}
