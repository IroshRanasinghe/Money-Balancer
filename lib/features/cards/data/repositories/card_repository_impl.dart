import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/bank_card.dart';
import '../../domain/repositories/card_repository.dart';
import '../datasources/card_local_datasource.dart';
import '../models/card_model.dart';

class CardRepositoryImpl implements CardRepository {
  CardRepositoryImpl(this._dataSource);

  final CardLocalDataSource _dataSource;

  @override
  Future<Either<Failure, List<BankCard>>> getCards() async {
    try {
      final list = _dataSource.getAll().map((m) => m.toEntity()).toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
      return Right(list);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> saveCard(BankCard card) async {
    try {
      await _dataSource.put(CardModel.fromEntity(card));
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCard(String id) async {
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
