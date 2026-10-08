import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../transactions/domain/entities/transaction.dart';
import '../recurrence.dart';

part 'recurring_rule.freezed.dart';

enum RecurrenceFrequency {
  daily('Daily'),
  weekly('Weekly'),
  monthly('Monthly'),
  yearly('Yearly');

  const RecurrenceFrequency(this.label);

  final String label;
}

@freezed
abstract class RecurringRule with _$RecurringRule {
  const RecurringRule._();

  const factory RecurringRule({
    required String id,
    required TransactionType type,
    required double amount,
    required String category,
    String? paymentMethod,
    String? notes,
    String? accountId,
    required RecurrenceFrequency frequency,

    /// Date-only (midnight local).
    required DateTime startDate,

    /// Date-only (midnight local); null means no end.
    DateTime? endDate,
    @Default(0) int generatedCount,
    @Default(true) bool isActive,
    required DateTime createdAt,
  }) = _RecurringRule;

  DateTime get nextDue => occurrenceAt(startDate, frequency, generatedCount);

  bool get isFinished => endDate != null && nextDue.isAfter(endDate!);
}
