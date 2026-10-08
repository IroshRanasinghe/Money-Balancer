import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/budget.dart';
import '../../domain/repositories/budget_repository.dart';
import '../datasources/budget_local_datasource.dart';
import '../models/budget_model.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  BudgetRepositoryImpl(this._dataSource);

  final BudgetLocalDataSource _dataSource;

  @override
  Future<Either<Failure, List<Budget>>> getBudgets(
      {required int month, required int year}) async {
    try {
      final list = _dataSource
          .getAll()
          .where((m) => m.month == month && m.year == year)
          .map((m) => m.toEntity())
          .toList()
        ..sort((a, b) => a.category.compareTo(b.category));
      return Right(list);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> saveBudget(Budget budget) async {
    try {
      final duplicate = _dataSource.getAll().any((m) =>
          m.id != budget.id &&
          m.category == budget.category &&
          m.month == budget.month &&
          m.year == budget.year);
      if (duplicate) {
        return Left(ValidationFailure(
            'A ${budget.category} budget already exists for this month.'));
      }
      await _dataSource.put(BudgetModel.fromEntity(budget));
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteBudget(String id) async {
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
