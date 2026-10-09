import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/backup_counts.dart';

abstract class BackupRepository {
  /// Pretty-printed JSON text of all app data (no card numbers).
  Future<Either<Failure, String>> createBackup(DateTime now);

  /// Replaces all data with [json]. Nothing changes if the file is invalid.
  Future<Either<Failure, BackupCounts>> restoreBackup(String json);

  /// Right(false) when the user dismisses the share sheet.
  Future<Either<Failure, bool>> shareFile({
    required String fileName,
    required String content,
    required String mimeType,
  });

  /// Right(false) when the user cancels the "Save as" picker.
  Future<Either<Failure, bool>> saveFile({
    required String fileName,
    required String content,
    required String mimeType,
  });

  /// Null when the user cancels.
  Future<Either<Failure, String?>> pickTextFile({
    required List<String> extensions,
  });
}
