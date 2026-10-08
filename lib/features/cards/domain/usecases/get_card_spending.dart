import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/domain/repositories/transaction_repository.dart';
import '../entities/card_spending.dart';
import '../repositories/card_repository.dart';

class GetCardSpending {
  const GetCardSpending(this._cards, this._transactions);

  final CardRepository _cards;
  final TransactionRepository _transactions;

  /// Every card with the month's expense total charged to it.
  Future<Either<Failure, List<CardSpending>>> call({
    required int month,
    required int year,
  }) async {
    final cardsResult = await _cards.getCards();
    return cardsResult.fold(
      (failure) async => Left(failure),
      (cards) async {
        final txResult = await _transactions.getTransactions();
        return txResult.map((txs) {
          final spentByCard = <String, double>{};
          for (final t in txs) {
            final cardId = t.cardId;
            if (cardId != null &&
                t.type == TransactionType.expense &&
                t.date.year == year &&
                t.date.month == month) {
              spentByCard.update(cardId, (v) => v + t.amount,
                  ifAbsent: () => t.amount);
            }
          }
          return cards
              .map((c) => CardSpending(card: c, spent: spentByCard[c.id] ?? 0))
              .toList();
        });
      },
    );
  }
}
