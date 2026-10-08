import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/transaction_repository.dart';

class DeleteTransaction {
  const DeleteTransaction(this._repository);

  final TransactionRepository _repository;

  Future<Either<Failure, void>> call(String id) => _repository.deleteTransaction(id);
}
