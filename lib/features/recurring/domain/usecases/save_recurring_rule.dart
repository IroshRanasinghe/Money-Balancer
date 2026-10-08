import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/recurring_rule.dart';
import '../repositories/recurring_repository.dart';

class SaveRecurringRule {
  const SaveRecurringRule(this._repository);

  final RecurringRepository _repository;

  Future<Either<Failure, void>> call(RecurringRule rule) =>
      _repository.saveRule(rule);
}
