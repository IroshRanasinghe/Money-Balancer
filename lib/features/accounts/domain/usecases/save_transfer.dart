import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/transfer.dart';
import '../repositories/account_repository.dart';

class SaveTransfer {
  const SaveTransfer(this._repository);

  final AccountRepository _repository;

  Future<Either<Failure, void>> call(Transfer transfer) =>
      _repository.saveTransfer(transfer);
}
