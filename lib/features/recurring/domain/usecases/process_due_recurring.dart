import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/domain/repositories/transaction_repository.dart';
import '../entities/recurring_rule.dart';
import '../recurrence.dart';
import '../repositories/recurring_repository.dart';

class ProcessDueRecurring {
  const ProcessDueRecurring(this._rules, this._transactions);

  final RecurringRepository _rules;
  final TransactionRepository _transactions;

  static const _maxPerRule = 1000;

  /// Creates every transaction that is due on or before [now]'s date and
  /// returns how many were created. Idempotent: transaction ids are
  /// `<ruleId>_<index>`, so a re-run overwrites rather than duplicates.
  Future<Either<Failure, int>> call(DateTime now) async {
    final today = DateTime(now.year, now.month, now.day);
    final rulesResult = await _rules.getRules();
    return rulesResult.fold(
      (failure) async => Left(failure),
      (rules) => _process(rules, now, today),
    );
  }

  Future<Either<Failure, int>> _process(
    List<RecurringRule> rules,
    DateTime now,
    DateTime today,
  ) async {
    var created = 0;
    for (final rule in rules) {
      if (!rule.isActive) continue;
      var index = rule.generatedCount;
      var iterations = 0;
      while (iterations < _maxPerRule) {
        final occurrence = occurrenceAt(rule.startDate, rule.frequency, index);
        if (occurrence.isAfter(today)) break;
        final end = rule.endDate;
        if (end != null && occurrence.isAfter(end)) break;
        final added = await _transactions.addTransaction(
          Transaction(
            id: '${rule.id}_$index',
            amount: rule.amount,
            category: rule.category,
            date: occurrence,
            type: rule.type,
            paymentMethod: rule.paymentMethod,
            notes: rule.notes,
            accountId: rule.accountId,
            recurringId: rule.id,
            createdAt: now,
          ),
        );
        final addFailure = added.fold<Failure?>((f) => f, (_) => null);
        if (addFailure != null) return Left(addFailure);
        created++;
        index++;
        iterations++;
      }
      if (index != rule.generatedCount) {
        final saved = await _rules.saveRule(
          rule.copyWith(generatedCount: index),
        );
        final saveFailure = saved.fold<Failure?>((f) => f, (_) => null);
        if (saveFailure != null) return Left(saveFailure);
      }
    }
    return Right(created);
  }
}
