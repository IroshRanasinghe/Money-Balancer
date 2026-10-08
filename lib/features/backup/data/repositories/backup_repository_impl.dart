import 'dart:convert';

import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/backup_counts.dart';
import '../../domain/repositories/backup_repository.dart';
import '../datasources/backup_file_datasource.dart';
import '../datasources/backup_local_datasource.dart';

class BackupRepositoryImpl implements BackupRepository {
  BackupRepositoryImpl(this._local, this._files);

  final BackupLocalDataSource _local;
  final BackupFileDataSource _files;

  @override
  Future<Either<Failure, String>> createBackup(DateTime now) async {
    try {
      final map = _local.exportAll(now);
      return Right(const JsonEncoder.withIndent('  ').convert(map));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, BackupCounts>> restoreBackup(String json) async {
    final Object? decoded;
    try {
      decoded = jsonDecode(json);
    } on FormatException {
      return const Left(InvalidBackupFailure('This is not a valid backup file.'));
    }
    if (decoded is! Map) {
      return const Left(InvalidBackupFailure('This is not a valid backup file.'));
    }
    try {
      return Right(await _local.replaceAll(Map<String, dynamic>.from(decoded)));
    } on InvalidBackupException catch (e) {
      return Left(InvalidBackupFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> shareFile({
    required String fileName,
    required String content,
    required String mimeType,
  }) async {
    try {
      await _files.shareFile(
          fileName: fileName, content: content, mimeType: mimeType);
      return const Right(null);
    } on FileException catch (e) {
      return Left(FileFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, String?>> pickTextFile(
      {required List<String> extensions}) async {
    try {
      return Right(await _files.pickTextFile(extensions: extensions));
    } on FileException catch (e) {
      return Left(FileFailure(e.message));
    }
  }
}
