import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/domain/repositories/transaction_repository.dart';
import '../entities/account_activity.dart';
import '../repositories/account_repository.dart';

class GetAccountActivity {
  const GetAccountActivity(this._accounts, this._transactions);

  final AccountRepository _accounts;
  final TransactionRepository _transactions;

  /// Transactions and transfers touching [accountId], newest first.
  Future<Either<Failure, List<AccountActivity>>> call(String accountId) async {
    final accountsResult = await _accounts.getAccounts();
    return accountsResult.fold((failure) async => Left(failure), (
      accounts,
    ) async {
      final txResult = await _transactions.getTransactions();
      return txResult.fold((failure) async => Left(failure), (txs) async {
        final transfersResult = await _accounts.getTransfers();
        return transfersResult.map((transfers) {
          final names = {for (final a in accounts) a.id: a.name};
          String nameOf(String id) => names[id] ?? '(removed account)';
          final rows =
              <AccountActivity>[
                for (final t in txs)
                  if (t.accountId == accountId)
                    AccountActivity(
                      date: t.date,
                      createdAt: t.createdAt,
                      title: t.category,
                      signedAmount: t.type == TransactionType.income
                          ? t.amount
                          : -t.amount,
                      transaction: t,
                    ),
                for (final tr in transfers)
                  if (tr.fromAccountId == accountId ||
                      tr.toAccountId == accountId)
                    AccountActivity(
                      date: tr.date,
                      createdAt: tr.createdAt,
                      title: tr.fromAccountId == accountId
                          ? 'Transfer to ${nameOf(tr.toAccountId)}'
                          : 'Transfer from ${nameOf(tr.fromAccountId)}',
                      signedAmount: tr.fromAccountId == accountId
                          ? -tr.amount
                          : tr.amount,
                      transfer: tr,
                    ),
              ]..sort((a, b) {
                final byDate = b.date.compareTo(a.date);
                return byDate != 0
                    ? byDate
                    : b.createdAt.compareTo(a.createdAt);
              });
          return rows;
        });
      });
    });
  }
}
