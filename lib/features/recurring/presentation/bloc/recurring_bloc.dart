import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/recurring_rule.dart';
import '../../domain/usecases/delete_recurring_rule.dart';
import '../../domain/usecases/get_recurring_rules.dart';
import '../../domain/usecases/process_due_recurring.dart';
import '../../domain/usecases/save_recurring_rule.dart';
import 'recurring_event.dart';
import 'recurring_state.dart';

export 'recurring_event.dart';
export 'recurring_state.dart';

class RecurringBloc extends Bloc<RecurringEvent, RecurringState> {
  RecurringBloc(
    this._getRules,
    this._saveRule,
    this._deleteRule,
    this._processDue,
    this._uuid,
  ) : super(const RecurringState()) {
    on<RecurringLoadRequested>((e, emit) => _onLoad(emit));
    on<RecurringSaveRequested>(_onSave);
    on<RecurringActiveToggled>(_onToggle);
    on<RecurringDeleteRequested>(_onDelete);
  }

  final GetRecurringRules _getRules;
  final SaveRecurringRule _saveRule;
  final DeleteRecurringRule _deleteRule;
  final ProcessDueRecurring _processDue;
  final Uuid _uuid;

  Future<void> _onLoad(Emitter<RecurringState> emit) async {
    emit(state.copyWith(errorMessage: null, infoMessage: null));
    await _load(emit);
  }

  Future<void> _load(Emitter<RecurringState> emit) async {
    emit(state.copyWith(status: RecurringStatus.loading));
    final result = await _getRules();
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: RecurringStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (rules) => emit(
        state.copyWith(
          status: RecurringStatus.success,
          rules: rules,
        ),
      ),
    );
  }

  /// Generates anything now due, reports how many were added, then reloads.
  Future<void> _processAndReload(Emitter<RecurringState> emit) async {
    final processed = await _processDue(DateTime.now());
    processed.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (n) {
        if (n > 0) {
          emit(
            state.copyWith(
              infoMessage: 'Added $n transaction${n == 1 ? '' : 's'}',
            ),
          );
        }
      },
    );
    await _load(emit);
  }

  Future<void> _onSave(
    RecurringSaveRequested event,
    Emitter<RecurringState> emit,
  ) async {
    emit(state.copyWith(errorMessage: null, infoMessage: null));
    final amount = parseAmount(event.amountText);
    if (amount == null) {
      emit(state.copyWith(errorMessage: 'Enter an amount greater than 0'));
      return;
    }
    final category = event.category;
    if (category == null) {
      emit(state.copyWith(errorMessage: 'Choose a category'));
      return;
    }
    final end = event.endDate;
    if (end != null && end.isBefore(event.startDate)) {
      emit(
        state.copyWith(errorMessage: 'End date must be after the start date'),
      );
      return;
    }
    RecurringRule? existing;
    if (event.id != null) {
      final fresh = await _freshRule(event.id!, emit);
      if (fresh == null) return;
      existing = fresh;
    }
    final prior = existing;
    final started = prior != null && prior.generatedCount > 0;
    if (!started) {
      final now = DateTime.now();
      final limit = DateTime(now.year - 1, now.month, now.day);
      if (event.startDate.isBefore(limit)) {
        emit(
          state.copyWith(
            errorMessage: 'Start date can be at most one year ago',
          ),
        );
        return;
      }
    }
    final notes = event.notes?.trim();
    final rule = RecurringRule(
      id: existing?.id ?? event.id ?? _uuid.v4(),
      type: event.type,
      amount: amount,
      category: category,
      paymentMethod: event.paymentMethod,
      notes: notes == null || notes.isEmpty ? null : notes,
      accountId: event.accountId,
      frequency: prior != null && started ? prior.frequency : event.frequency,
      startDate: prior != null && started ? prior.startDate : event.startDate,
      endDate: end,
      generatedCount: existing?.generatedCount ?? 0,
      isActive: existing?.isActive ?? true,
      createdAt: existing?.createdAt ?? DateTime.now(),
    );
    final result = await _saveRule(rule);
    await _afterWrite(result, emit, processDue: rule.isActive);
  }

  Future<void> _onToggle(
    RecurringActiveToggled event,
    Emitter<RecurringState> emit,
  ) async {
    emit(state.copyWith(errorMessage: null, infoMessage: null));
    final existing = await _freshRule(event.id, emit);
    if (existing == null) return;
    final result = await _saveRule(existing.copyWith(isActive: event.isActive));
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (_) {},
    );
    if (result.isLeft()) return;
    if (event.isActive) {
      await _processAndReload(emit);
    } else {
      await _load(emit);
    }
  }

  /// Reads the rule straight from storage so a concurrent handler's
  /// `generatedCount` is never overwritten. Emits an error and returns null on
  /// failure or when the rule no longer exists.
  Future<RecurringRule?> _freshRule(
    String id,
    Emitter<RecurringState> emit,
  ) async {
    final result = await _getRules();
    final failure = result.fold<Failure?>((f) => f, (_) => null);
    if (failure != null) {
      emit(state.copyWith(errorMessage: failure.message));
      return null;
    }
    final rules = result.getOrElse(() => const <RecurringRule>[]);
    for (final r in rules) {
      if (r.id == id) return r;
    }
    emit(state.copyWith(errorMessage: const NotFoundFailure().message));
    return null;
  }

  Future<void> _onDelete(
    RecurringDeleteRequested event,
    Emitter<RecurringState> emit,
  ) async {
    emit(state.copyWith(errorMessage: null, infoMessage: null));
    final result = await _deleteRule(event.id);
    await _afterWrite(result, emit, processDue: false);
  }

  RecurringState _failed(Failure failure) => failure is PremiumRequiredFailure
      ? state.copyWith(
          paywallCount: state.paywallCount + 1,
          paywallFeature: failure.feature,
        )
      : state.copyWith(errorMessage: failure.message);

  /// On success bump [RecurringState.savedCount], optionally generate due
  /// items, and reload; on failure report.
  Future<void> _afterWrite(
    Either<Failure, void> result,
    Emitter<RecurringState> emit, {
    required bool processDue,
  }) async {
    final failure = result.fold<Failure?>((f) => f, (_) => null);
    if (failure != null) {
      emit(_failed(failure));
      return;
    }
    emit(state.copyWith(savedCount: state.savedCount + 1));
    if (processDue) {
      await _processAndReload(emit);
    } else {
      await _load(emit);
    }
  }
}
