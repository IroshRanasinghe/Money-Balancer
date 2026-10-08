import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/domain/repositories/transaction_repository.dart';
import '../entities/account_balance.dart';
import '../repositories/account_repository.dart';

class GetAccountBalances {
  const GetAccountBalances(this._accounts, this._transactions);

  final AccountRepository _accounts;
  final TransactionRepository _transactions;

  /// Every account with its live balance: opening balance, plus income and
  /// minus expenses linked to it, plus transfers in and minus transfers out.
  Future<Either<Failure, List<AccountBalance>>> call() async {
    final accountsResult = await _accounts.getAccounts();
    return accountsResult.fold((failure) async => Left(failure), (
      accounts,
    ) async {
      final txResult = await _transactions.getTransactions();
      return txResult.fold((failure) async => Left(failure), (txs) async {
        final transfersResult = await _accounts.getTransfers();
        return transfersResult.map((transfers) {
          final delta = <String, double>{};
          void add(String id, double v) =>
              delta.update(id, (x) => x + v, ifAbsent: () => v);
          for (final t in txs) {
            final id = t.accountId;
            if (id == null) continue;
            add(id, t.type == TransactionType.income ? t.amount : -t.amount);
          }
          for (final tr in transfers) {
            add(tr.fromAccountId, -tr.amount);
            add(tr.toAccountId, tr.amount);
          }
          return accounts
              .map(
                (a) => AccountBalance(
                  account: a,
                  balance: a.openingBalance + (delta[a.id] ?? 0),
                ),
              )
              .toList();
        });
      });
    });
  }
}
