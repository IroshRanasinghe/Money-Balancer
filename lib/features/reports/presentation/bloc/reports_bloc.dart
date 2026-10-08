import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/extensions.dart';
import '../../domain/usecases/get_report.dart';
import 'reports_event.dart';
import 'reports_state.dart';

export 'reports_event.dart';
export 'reports_state.dart';

class ReportsBloc extends Bloc<ReportsEvent, ReportsState> {
  ReportsBloc(this._getReport, {DateTime? now})
      : super(() {
          final d = now ?? DateTime.now();
          return ReportsState(month: d.month, year: d.year);
        }()) {
    on<ReportsLoadRequested>((e, emit) => _load(emit));
    on<ReportsMonthShifted>((e, emit) {
      final next = DateTime(state.year, state.month).addMonths(e.delta);
      emit(state.copyWith(month: next.month, year: next.year, report: null));
      return _load(emit);
    });
  }

  final GetReport _getReport;

  Future<void> _load(Emitter<ReportsState> emit) async {
    emit(state.copyWith(status: ReportsStatus.loading, errorMessage: null));
    final result = await _getReport(month: state.month, year: state.year);
    result.fold(
      (failure) => emit(state.copyWith(
          status: ReportsStatus.failure, errorMessage: failure.message)),
      (report) => emit(state.copyWith(
          status: ReportsStatus.success, report: report, errorMessage: null)),
    );
  }
}
