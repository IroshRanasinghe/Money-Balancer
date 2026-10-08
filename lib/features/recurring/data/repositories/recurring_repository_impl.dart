import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/recurring_rule.dart';
import '../../domain/repositories/recurring_repository.dart';
import '../datasources/recurring_local_datasource.dart';
import '../models/recurring_rule_model.dart';

class RecurringRepositoryImpl implements RecurringRepository {
  RecurringRepositoryImpl(this._dataSource);

  final RecurringLocalDataSource _dataSource;

  @override
  Future<Either<Failure, List<RecurringRule>>> getRules() async {
    try {
      final list = _dataSource.getAll().map((m) => m.toEntity()).toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
      return Right(list);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> saveRule(RecurringRule rule) async {
    try {
      await _dataSource.put(RecurringRuleModel.fromEntity(rule));
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteRule(String id) async {
    try {
      await _dataSource.delete(id);
      return const Right(null);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }
}
