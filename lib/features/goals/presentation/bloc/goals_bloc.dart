import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/savings_goal.dart';
import '../../domain/usecases/adjust_goal_savings.dart';
import '../../domain/usecases/delete_goal.dart';
import '../../domain/usecases/get_goals.dart';
import '../../domain/usecases/save_goal.dart';
import 'goals_event.dart';
import 'goals_state.dart';

export 'goals_event.dart';
export 'goals_state.dart';

class GoalsBloc extends Bloc<GoalsEvent, GoalsState> {
  GoalsBloc(
    this._getGoals,
    this._saveGoal,
    this._deleteGoal,
    this._adjustSavings,
    this._uuid,
  ) : super(const GoalsState()) {
    on<GoalsLoadRequested>((e, emit) => _load(emit));
    on<GoalSaveRequested>(_onSave);
    on<GoalDeleteRequested>(_onDelete);
    on<GoalSavingsAdjusted>(_onAdjust);
  }

  final GetGoals _getGoals;
  final SaveGoal _saveGoal;
  final DeleteGoal _deleteGoal;
  final AdjustGoalSavings _adjustSavings;
  final Uuid _uuid;

  Future<void> _load(Emitter<GoalsState> emit) async {
    emit(state.copyWith(status: GoalsStatus.loading, errorMessage: null));
    final result = await _getGoals();
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: GoalsStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (goals) => emit(
        state.copyWith(
          status: GoalsStatus.success,
          goals: goals,
          errorMessage: null,
        ),
      ),
    );
  }

  GoalsState _failed(Failure failure) => failure is PremiumRequiredFailure
      ? state.copyWith(
          paywallCount: state.paywallCount + 1,
          paywallFeature: failure.feature,
        )
      : state.copyWith(errorMessage: failure.message);

  /// On success bump [GoalsState.savedCount] and reload; on failure report.
  Future<void> _finish(
    Either<Failure, void> result,
    Emitter<GoalsState> emit,
  ) async {
    await result.fold((failure) async => emit(_failed(failure)), (_) async {
      emit(state.copyWith(savedCount: state.savedCount + 1));
      await _load(emit);
    });
  }

  SavingsGoal? _find(String id) {
    for (final g in state.goals) {
      if (g.id == id) return g;
    }
    return null;
  }

  Future<void> _onSave(
    GoalSaveRequested event,
    Emitter<GoalsState> emit,
  ) async {
    emit(state.copyWith(errorMessage: null, infoMessage: null));
    final name = event.name.trim();
    if (name.isEmpty) {
      emit(state.copyWith(errorMessage: 'Enter a goal name'));
      return;
    }
    final target = parseAmount(event.targetText);
    if (target == null) {
      emit(state.copyWith(errorMessage: 'Enter a target greater than 0'));
      return;
    }
    final id = event.id;
    final existing = id == null ? null : _find(id);
    if (id != null && existing == null) {
      emit(state.copyWith(errorMessage: const NotFoundFailure().message));
      return;
    }
    final date = event.targetDate;
    // Only a new or changed date must be in the future, so a goal whose date
    // has passed can still be edited.
    if (date != null && date != existing?.targetDate) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      if (date.isBefore(today)) {
        emit(state.copyWith(errorMessage: 'Choose a date in the future'));
        return;
      }
    }
    final result = await _saveGoal(
      SavingsGoal(
        id: id ?? _uuid.v4(),
        name: name,
        targetAmount: target,
        savedAmount: existing?.savedAmount ?? 0,
        targetDate: date,
        colorValue: event.colorValue,
        createdAt: existing?.createdAt ?? DateTime.now(),
      ),
    );
    await _finish(result, emit);
  }

  Future<void> _onDelete(
    GoalDeleteRequested event,
    Emitter<GoalsState> emit,
  ) async {
    emit(state.copyWith(errorMessage: null, infoMessage: null));
    await _finish(await _deleteGoal(event.id), emit);
  }

  Future<void> _onAdjust(
    GoalSavingsAdjusted event,
    Emitter<GoalsState> emit,
  ) async {
    emit(state.copyWith(errorMessage: null, infoMessage: null));
    final amount = parseAmount(event.amountText);
    if (amount == null) {
      emit(state.copyWith(errorMessage: 'Enter an amount greater than 0'));
      return;
    }
    final wasCompleted = _find(event.id)?.isCompleted ?? false;
    final result = await _adjustSavings(
      event.id,
      event.withdraw ? -amount : amount,
    );
    await result.fold((failure) async => emit(_failed(failure)), (goal) async {
      emit(
        state.copyWith(
          savedCount: state.savedCount + 1,
          infoMessage: !wasCompleted && goal.isCompleted
              ? 'Goal reached: ${goal.name} 🎉'
              : null,
        ),
      );
      await _load(emit);
    });
  }
}
