import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/bank_card.dart';
import '../../domain/repositories/card_repository.dart';
import '../datasources/card_local_datasource.dart';
import '../datasources/card_number_secure_datasource.dart';
import '../models/card_model.dart';

class CardRepositoryImpl implements CardRepository {
  CardRepositoryImpl(this._dataSource, this._numbers);

  final CardLocalDataSource _dataSource;
  final CardNumberSecureDataSource _numbers;

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
  Future<Either<Failure, void>> saveCard(BankCard card,
      {String? cardNumber}) async {
    try {
      await _dataSource.put(CardModel.fromEntity(card));
      if (cardNumber != null) await _numbers.write(card.id, cardNumber);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCard(String id) async {
    try {
      await _dataSource.delete(id);
      await _numbers.delete(id);
      return const Right(null);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, String?>> getCardNumber(String id) async {
    try {
      return Right(await _numbers.read(id));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }
}
