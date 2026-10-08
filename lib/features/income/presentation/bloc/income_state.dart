import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../shared/form_submission_status.dart';

part 'income_state.freezed.dart';

@freezed
abstract class IncomeState with _$IncomeState {
  const factory IncomeState({
    @Default(FormSubmissionStatus.initial) FormSubmissionStatus status,
    String? errorMessage,
  }) = _IncomeState;
}
