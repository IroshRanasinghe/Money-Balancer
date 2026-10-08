import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/premium_status.dart';
import '../repositories/premium_repository.dart';

class PurchasePremium {
  const PurchasePremium(this._repository);

  final PremiumRepository _repository;

  Future<Either<Failure, PremiumStatus>> call(String packageId) =>
      _repository.purchase(packageId);
}
