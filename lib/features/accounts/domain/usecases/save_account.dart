import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/account.dart';
import '../repositories/account_repository.dart';

class SaveAccount {
  const SaveAccount(this._repository);

  final AccountRepository _repository;

  Future<Either<Failure, void>> call(Account account) =>
      _repository.saveAccount(account);
}
