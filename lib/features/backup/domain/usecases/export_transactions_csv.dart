import 'package:dartz/dartz.dart';
import 'package:intl/intl.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/premium/premium_feature.dart';
import '../../../premium/domain/usecases/check_premium_access.dart';
import '../../../accounts/domain/repositories/account_repository.dart';
import '../../../transactions/domain/repositories/transaction_repository.dart';
import '../entities/export_target.dart';
import '../repositories/backup_repository.dart';
import '../transactions_csv.dart';

class ExportTransactionsCsv {
  const ExportTransactionsCsv(
    this._transactions,
    this._accounts,
    this._backup,
    this._checkPremium,
  );

  final TransactionRepository _transactions;
  final AccountRepository _accounts;
  final BackupRepository _backup;
  final CheckPremiumAccess _checkPremium;

  /// Right(false) when the user dismisses the share sheet or "Save as" picker.
  Future<Either<Failure, bool>> call(DateTime now, ExportTarget target) async {
    final allowed = await _checkPremium(
      PremiumFeature.csvExport,
      currentCount: 0,
    );
    final denied = allowed.fold<Failure?>((f) => f, (_) => null);
    if (denied != null) return Left(denied);
    final txResult = await _transactions.getTransactions();
    return txResult.fold((failure) async => Left(failure), (txs) async {
      if (txs.isEmpty) {
        return const Left(ValidationFailure('No transactions to export yet.'));
      }
      final accResult = await _accounts.getAccounts();
      return accResult.fold((failure) async => Left(failure), (accounts) async {
        final names = {for (final a in accounts) a.id: a.name};
        final fileName =
            'money_balance_transactions_${DateFormat('yyyy-MM-dd').format(now)}.csv';
        final content = buildTransactionsCsv(txs, names);
        return switch (target) {
          ExportTarget.device => _backup.saveFile(
            fileName: fileName,
            content: content,
            mimeType: 'text/csv',
          ),
          ExportTarget.share => _backup.shareFile(
            fileName: fileName,
            content: content,
            mimeType: 'text/csv',
          ),
        };
      });
    });
  }
}
