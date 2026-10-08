import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/premium_status.dart';
import '../repositories/premium_repository.dart';

class GetPremiumStatus {
  const GetPremiumStatus(this._repository);

  final PremiumRepository _repository;

  Future<Either<Failure, PremiumStatus>> call() => _repository.getStatus();
}
