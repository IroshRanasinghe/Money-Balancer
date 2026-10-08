import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/budget_alert_repository.dart';
import '../datasources/budget_alert_datasource.dart';

class BudgetAlertRepositoryImpl implements BudgetAlertRepository {
  BudgetAlertRepositoryImpl(this._local);

  final BudgetAlertDataSource _local;

  @override
  Future<Either<Failure, bool>> wasSent(String key) async {
    try {
      return Right(_local.wasSent(key));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> markSent(String key) async {
    try {
      await _local.markSent(key);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }
}
