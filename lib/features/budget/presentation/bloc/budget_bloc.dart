import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/budget.dart';
import '../../domain/usecases/delete_budget.dart';
import '../../domain/usecases/get_budget_progress.dart';
import '../../domain/usecases/save_budget.dart';
import 'budget_event.dart';
import 'budget_state.dart';

export 'budget_event.dart';
export 'budget_state.dart';

class BudgetBloc extends Bloc<BudgetEvent, BudgetState> {
  BudgetBloc(
    this._getBudgetProgress,
    this._saveBudget,
    this._deleteBudget,
    this._uuid, {
    DateTime? now,
  }) : super(BudgetState(
          month: (now ?? DateTime.now()).month,
          year: (now ?? DateTime.now()).year,
        )) {
    on<BudgetLoadRequested>((e, emit) => _load(emit));
    on<BudgetMonthShifted>(_onMonthShifted);
    on<BudgetSaveRequested>(_onSave);
    on<BudgetDeleteRequested>(_onDelete);
  }

  final GetBudgetProgress _getBudgetProgress;
  final SaveBudget _saveBudget;
  final DeleteBudget _deleteBudget;
  final Uuid _uuid;

  Future<void> _load(Emitter<BudgetState> emit) async {
    emit(state.copyWith(status: BudgetListStatus.loading, errorMessage: null));
    final result =
        await _getBudgetProgress(month: state.month, year: state.year);
    result.fold(
      (failure) => emit(state.copyWith(
        status: BudgetListStatus.failure,
        errorMessage: failure.message,
      )),
      (items) => emit(state.copyWith(
        status: BudgetListStatus.success,
        items: items,
        errorMessage: null,
      )),
    );
  }

  Future<void> _onMonthShifted(
      BudgetMonthShifted event, Emitter<BudgetState> emit) async {
    final d = DateTime(state.year, state.month).addMonths(event.delta);
    emit(state.copyWith(month: d.month, year: d.year, errorMessage: null));
    await _load(emit);
  }

  Future<void> _onSave(
      BudgetSaveRequested event, Emitter<BudgetState> emit) async {
    emit(state.copyWith(errorMessage: null));
    final limit = parseAmount(event.limitText);
    if (limit == null) {
      emit(state.copyWith(errorMessage: 'Enter a limit greater than 0'));
      return;
    }
    final result = await _saveBudget(Budget(
      id: event.id ?? _uuid.v4(),
      category: event.category,
      limit: limit,
      month: state.month,
      year: state.year,
      isActive: event.isActive,
    ));
    await result.fold(
      (failure) async => emit(state.copyWith(errorMessage: failure.message)),
      (_) => _load(emit),
    );
  }

  Future<void> _onDelete(
      BudgetDeleteRequested event, Emitter<BudgetState> emit) async {
    emit(state.copyWith(errorMessage: null));
    final result = await _deleteBudget(event.id);
    await result.fold(
      (failure) async => emit(state.copyWith(errorMessage: failure.message)),
      (_) => _load(emit),
    );
  }
}
