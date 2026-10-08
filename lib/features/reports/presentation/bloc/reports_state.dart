import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/report_data.dart';

part 'reports_state.freezed.dart';

enum ReportsStatus { initial, loading, success, failure }

@freezed
abstract class ReportsState with _$ReportsState {
  const factory ReportsState({
    required int month,
    required int year,
    @Default(ReportsStatus.initial) ReportsStatus status,
    ReportData? report,
    String? errorMessage,
  }) = _ReportsState;
}
