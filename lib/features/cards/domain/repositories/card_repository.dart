import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/bank_card.dart';

abstract class CardRepository {
  /// Oldest `createdAt` first.
  Future<Either<Failure, List<BankCard>>> getCards();

  /// Insert or update by id.
  Future<Either<Failure, void>> saveCard(BankCard card);

  /// Fails with [NotFoundFailure] if absent.
  Future<Either<Failure, void>> deleteCard(String id);
}
