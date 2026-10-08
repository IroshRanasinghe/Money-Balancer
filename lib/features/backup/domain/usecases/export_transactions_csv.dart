import 'package:dartz/dartz.dart';
import 'package:intl/intl.dart';

import '../../../../core/error/failures.dart';
import '../../../premium/domain/entities/premium_feature.dart';
import '../../../premium/domain/usecases/check_premium_access.dart';
import '../../../accounts/domain/repositories/account_repository.dart';
import '../../../transactions/domain/repositories/transaction_repository.dart';
import '../repositories/backup_repository.dart';
import '../transactions_csv.dart';

class ExportTransactionsCsv {
  const ExportTransactionsCsv(
      this._transactions, this._accounts, this._backup, this._checkPremium);

  final TransactionRepository _transactions;
  final AccountRepository _accounts;
  final BackupRepository _backup;
  final CheckPremiumAccess _checkPremium;

  Future<Either<Failure, void>> call(DateTime now) async {
    final allowed =
        await _checkPremium(PremiumFeature.csvExport, currentCount: 0);
    if (allowed.isLeft()) return allowed;
    final txResult = await _transactions.getTransactions();
    return txResult.fold(
      (failure) async => Left(failure),
      (txs) async {
        if (txs.isEmpty) {
          return const Left(ValidationFailure('No transactions to export yet.'));
        }
        final accResult = await _accounts.getAccounts();
        return accResult.fold(
          (failure) async => Left(failure),
          (accounts) async {
            final names = {for (final a in accounts) a.id: a.name};
            return _backup.shareFile(
              fileName:
                  'money_balance_transactions_${DateFormat('yyyy-MM-dd').format(now)}.csv',
              content: buildTransactionsCsv(txs, names),
              mimeType: 'text/csv',
            );
          },
        );
      },
    );
  }
}
