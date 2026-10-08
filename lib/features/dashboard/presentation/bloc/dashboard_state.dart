import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/dashboard_summary.dart';

part 'dashboard_state.freezed.dart';

enum DashboardStatus { initial, loading, success, failure }

@freezed
abstract class DashboardState with _$DashboardState {
  const factory DashboardState({
    @Default(DashboardStatus.initial) DashboardStatus status,
    DashboardSummary? summary,
    String? errorMessage,
  }) = _DashboardState;
}
