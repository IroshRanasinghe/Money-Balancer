import 'package:dartz/dartz.dart';
import 'package:intl/intl.dart';

import '../../../../core/error/failures.dart';
import '../repositories/backup_repository.dart';

class ExportBackup {
  const ExportBackup(this._repository);

  final BackupRepository _repository;

  /// Right(false) when the user dismisses the share sheet.
  Future<Either<Failure, bool>> call(DateTime now) async {
    final created = await _repository.createBackup(now);
    return created.fold(
      (failure) async => Left(failure),
      (json) => _repository.shareFile(
        fileName:
            'money_balance_backup_${DateFormat('yyyy-MM-dd').format(now)}.json',
        content: json,
        mimeType: 'application/json',
      ),
    );
  }
}
