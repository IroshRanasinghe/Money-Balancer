import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';

/// Remembers which budget alerts were already sent so each fires once.
abstract class BudgetAlertRepository {
  Future<Either<Failure, bool>> wasSent(String key);

  Future<Either<Failure, void>> markSent(String key);
}
