import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/backup_counts.dart';
import '../repositories/backup_repository.dart';

class RestoreBackupFromFile {
  const RestoreBackupFromFile(this._repository);

  final BackupRepository _repository;

  /// `Right(null)` when the user cancels the picker.
  Future<Either<Failure, BackupCounts?>> call() async {
    final picked = await _repository.pickTextFile(extensions: const ['json']);
    return picked.fold(
      (failure) async => Left(failure),
      (text) async {
        if (text == null) return const Right(null);
        return _repository.restoreBackup(text);
      },
    );
  }
}
