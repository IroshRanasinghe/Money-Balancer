import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

class AddTransaction {
  const AddTransaction(this._repository);

  final TransactionRepository _repository;

  Future<Either<Failure, void>> call(Transaction transaction) => _repository.addTransaction(transaction);
}
