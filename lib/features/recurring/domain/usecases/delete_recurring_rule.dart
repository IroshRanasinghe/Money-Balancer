import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/recurring_repository.dart';

/// Deletes the rule only; transactions already created are kept.
class DeleteRecurringRule {
  const DeleteRecurringRule(this._repository);

  final RecurringRepository _repository;

  Future<Either<Failure, void>> call(String id) => _repository.deleteRule(id);
}
