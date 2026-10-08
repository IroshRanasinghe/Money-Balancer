import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/account.dart';
import '../entities/transfer.dart';

abstract class AccountRepository {
  /// Oldest `createdAt` first.
  Future<Either<Failure, List<Account>>> getAccounts();

  /// Insert or update by id.
  Future<Either<Failure, void>> saveAccount(Account account);

  /// Fails with [NotFoundFailure] if absent.
  Future<Either<Failure, void>> deleteAccount(String id);

  /// Newest `date` first (ties: newest `createdAt` first).
  Future<Either<Failure, List<Transfer>>> getTransfers();

  /// Insert or update by id.
  Future<Either<Failure, void>> saveTransfer(Transfer transfer);

  /// Fails with [NotFoundFailure] if absent.
  Future<Either<Failure, void>> deleteTransfer(String id);
}
