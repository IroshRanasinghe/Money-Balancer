import 'package:json_annotation/json_annotation.dart';

import '../../../transactions/domain/entities/transaction.dart';
import '../../domain/entities/recurring_rule.dart';

part 'recurring_rule_model.g.dart';

@JsonSerializable()
class RecurringRuleModel {
  const RecurringRuleModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.category,
    this.paymentMethod,
    this.notes,
    this.accountId,
    required this.frequency,
    required this.startDate,
    this.endDate,
    required this.generatedCount,
    required this.isActive,
    required this.createdAt,
  });

  factory RecurringRuleModel.fromJson(Map<String, dynamic> json) =>
      _$RecurringRuleModelFromJson(json);

  factory RecurringRuleModel.fromEntity(RecurringRule r) => RecurringRuleModel(
    id: r.id,
    type: r.type,
    amount: r.amount,
    category: r.category,
    paymentMethod: r.paymentMethod,
    notes: r.notes,
    accountId: r.accountId,
    frequency: r.frequency,
    startDate: r.startDate,
    endDate: r.endDate,
    generatedCount: r.generatedCount,
    isActive: r.isActive,
    createdAt: r.createdAt,
  );

  final String id;
  final TransactionType type;
  final double amount;
  final String category;
  final String? paymentMethod;
  final String? notes;
  final String? accountId;
  final RecurrenceFrequency frequency;
  final DateTime startDate;
  final DateTime? endDate;
  final int generatedCount;
  final bool isActive;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => _$RecurringRuleModelToJson(this);

  RecurringRule toEntity() => RecurringRule(
    id: id,
    type: type,
    amount: amount,
    category: category,
    paymentMethod: paymentMethod,
    notes: notes,
    accountId: accountId,
    frequency: frequency,
    startDate: startDate,
    endDate: endDate,
    generatedCount: generatedCount,
    isActive: isActive,
    createdAt: createdAt,
  );
}
