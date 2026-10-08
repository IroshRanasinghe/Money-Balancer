import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/premium_status.dart';
import '../repositories/premium_repository.dart';

class RestorePurchases {
  const RestorePurchases(this._repository);

  final PremiumRepository _repository;

  Future<Either<Failure, PremiumStatus>> call() =>
      _repository.restorePurchases();
}
