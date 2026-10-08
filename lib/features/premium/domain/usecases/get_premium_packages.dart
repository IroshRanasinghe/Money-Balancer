import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/premium_package.dart';
import '../repositories/premium_repository.dart';

class GetPremiumPackages {
  const GetPremiumPackages(this._repository);

  final PremiumRepository _repository;

  Future<Either<Failure, List<PremiumPackage>>> call() =>
      _repository.getPackages();
}
