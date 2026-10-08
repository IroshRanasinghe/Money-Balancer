import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/account_repository.dart';

class DeleteTransfer {
  const DeleteTransfer(this._repository);

  final AccountRepository _repository;

  Future<Either<Failure, void>> call(String id) =>
      _repository.deleteTransfer(id);
}
