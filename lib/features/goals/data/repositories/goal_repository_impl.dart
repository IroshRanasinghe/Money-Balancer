import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/savings_goal.dart';
import '../../domain/repositories/goal_repository.dart';
import '../datasources/goal_local_datasource.dart';
import '../models/goal_model.dart';

class GoalRepositoryImpl implements GoalRepository {
  GoalRepositoryImpl(this._local);

  final GoalLocalDataSource _local;

  @override
  Future<Either<Failure, List<SavingsGoal>>> getGoals() async {
    try {
      final list = _local.getAll().map((m) => m.toEntity()).toList()
        ..sort((a, b) {
          if (a.isCompleted != b.isCompleted) return a.isCompleted ? 1 : -1;
          final ad = a.targetDate;
          final bd = b.targetDate;
          if (ad != null && bd != null) {
            final byDate = ad.compareTo(bd);
            if (byDate != 0) return byDate;
          } else if (ad != null) {
            return -1;
          } else if (bd != null) {
            return 1;
          }
          return a.createdAt.compareTo(b.createdAt);
        });
      return Right(list);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> saveGoal(SavingsGoal goal) async {
    try {
      await _local.put(GoalModel.fromEntity(goal));
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteGoal(String id) async {
    try {
      await _local.delete(id);
      return const Right(null);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }
}
