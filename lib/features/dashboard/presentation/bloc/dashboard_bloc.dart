import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_dashboard_summary.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc(this._getDashboardSummary) : super(const DashboardState()) {
    on<DashboardLoadRequested>(_onLoadRequested);
  }

  final GetDashboardSummary _getDashboardSummary;

  Future<void> _onLoadRequested(
    DashboardLoadRequested event,
    Emitter<DashboardState> emit,
  ) async {
    emit(state.copyWith(status: DashboardStatus.loading, errorMessage: null));
    final result = await _getDashboardSummary(DateTime.now());
    result.fold(
      (failure) => emit(state.copyWith(
        status: DashboardStatus.failure,
        errorMessage: failure.message,
      )),
      (summary) => emit(state.copyWith(
        status: DashboardStatus.success,
        summary: summary,
        errorMessage: null,
      )),
    );
  }
}
