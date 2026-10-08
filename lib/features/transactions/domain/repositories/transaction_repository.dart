import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/transaction.dart';

abstract class TransactionRepository {
  /// All transactions, newest `date` first (ties: newest `createdAt` first).
  Future<Either<Failure, List<Transaction>>> getTransactions();

  Future<Either<Failure, void>> addTransaction(Transaction transaction);

  /// Fails with [NotFoundFailure] if no transaction has this id.
  Future<Either<Failure, void>> updateTransaction(Transaction transaction);

  /// Fails with [NotFoundFailure] if no transaction has this id.
  Future<Either<Failure, void>> deleteTransaction(String id);
}
