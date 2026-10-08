import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/account.dart';
import '../repositories/account_repository.dart';

class GetAccounts {
  const GetAccounts(this._repository);

  final AccountRepository _repository;

  Future<Either<Failure, List<Account>>> call() => _repository.getAccounts();
}
