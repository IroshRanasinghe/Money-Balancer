import 'package:freezed_annotation/freezed_annotation.dart';

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
  }) = _BudgetState;
}
