import 'package:equatable/equatable.dart';

import '../../../transactions/domain/entities/transaction.dart';
import '../../domain/entities/recurring_rule.dart';

sealed class RecurringEvent extends Equatable {
  const RecurringEvent();

  @override
  List<Object?> get props => [];
}

class RecurringLoadRequested extends RecurringEvent {
  const RecurringLoadRequested();
}

class RecurringSaveRequested extends RecurringEvent {
  const RecurringSaveRequested({
    this.id,
    required this.type,
    required this.amountText,
    required this.category,
    required this.frequency,
    required this.startDate,
    this.endDate,
    this.paymentMethod,
    this.notes,
    this.accountId,
  });

  /// Null for a new rule.
  final String? id;
  final TransactionType type;
  final String amountText;
  final String? category;
  final RecurrenceFrequency frequency;
  final DateTime startDate;
  final DateTime? endDate;
  final String? paymentMethod;
  final String? notes;
  final String? accountId;

  @override
  List<Object?> get props => [
    id,
    type,
    amountText,
    category,
    frequency,
    startDate,
    endDate,
    paymentMethod,
    notes,
    accountId,
  ];
}

class RecurringActiveToggled extends RecurringEvent {
  const RecurringActiveToggled(this.id, this.isActive);

  final String id;
  final bool isActive;

  @override
  List<Object?> get props => [id, isActive];
}

class RecurringDeleteRequested extends RecurringEvent {
  const RecurringDeleteRequested(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}
