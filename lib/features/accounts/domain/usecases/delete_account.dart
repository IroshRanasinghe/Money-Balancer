import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../transactions/domain/repositories/transaction_repository.dart';
import '../repositories/account_repository.dart';

class DeleteAccount {
  const DeleteAccount(this._accounts, this._transactions);

  final AccountRepository _accounts;
  final TransactionRepository _transactions;

  /// Fails with [AccountInUseFailure] while any transaction or transfer
  /// references the account.
  Future<Either<Failure, void>> call(String id) async {
    final txResult = await _transactions.getTransactions();
    return txResult.fold((failure) async => Left(failure), (txs) async {
      if (txs.any((t) => t.accountId == id)) {
        return const Left(AccountInUseFailure());
      }
      final transfersResult = await _accounts.getTransfers();
      return transfersResult.fold((failure) async => Left(failure), (
        transfers,
      ) {
        if (transfers.any(
          (t) => t.fromAccountId == id || t.toAccountId == id,
        )) {
          return Future.value(const Left(AccountInUseFailure()));
        }
        return _accounts.deleteAccount(id);
      });
    });
  }
}
