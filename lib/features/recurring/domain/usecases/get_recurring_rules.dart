import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/recurring_rule.dart';
import '../repositories/recurring_repository.dart';

class GetRecurringRules {
  const GetRecurringRules(this._repository);

  final RecurringRepository _repository;

  Future<Either<Failure, List<RecurringRule>>> call() =>
      _repository.getRules();
}
