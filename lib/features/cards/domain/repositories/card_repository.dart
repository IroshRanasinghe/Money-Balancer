import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/bank_card.dart';

abstract class CardRepository {
  /// Oldest `createdAt` first.
  Future<Either<Failure, List<BankCard>>> getCards();

  /// Insert or update by id. When [cardNumber] is non-null it is also written
  /// to secure storage.
  Future<Either<Failure, void>> saveCard(BankCard card, {String? cardNumber});

  /// Fails with [NotFoundFailure] if absent. Also removes the stored number.
  Future<Either<Failure, void>> deleteCard(String id);

  /// The full number, or null when none is stored.
  Future<Either<Failure, String?>> getCardNumber(String id);
}
