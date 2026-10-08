import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../shared/form_submission_status.dart';

part 'expense_state.freezed.dart';

@freezed
abstract class ExpenseState with _$ExpenseState {
  const factory ExpenseState({
    @Default(FormSubmissionStatus.initial) FormSubmissionStatus status,
    String? errorMessage,
  }) = _ExpenseState;
}
