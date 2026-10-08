import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/recurring_rule.dart';

abstract class RecurringRepository {
  /// Oldest `createdAt` first.
  Future<Either<Failure, List<RecurringRule>>> getRules();

  /// Insert or update by id.
  Future<Either<Failure, void>> saveRule(RecurringRule rule);

  /// Fails with [NotFoundFailure] if absent.
  Future<Either<Failure, void>> deleteRule(String id);
}
