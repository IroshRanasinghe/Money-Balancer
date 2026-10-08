import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/premium/premium_feature.dart';
import '../../../premium/domain/usecases/check_premium_access.dart';
import '../entities/bank_card.dart';
import '../repositories/card_repository.dart';

class SaveCard {
  const SaveCard(this._repository, this._checkPremium);

  final CardRepository _repository;
  final CheckPremiumAccess _checkPremium;

  Future<Either<Failure, void>> call(BankCard card, {String? cardNumber}) async {
    final existing = await _repository.getCards();
    return existing.fold((failure) async => Left(failure), (cards) async {
      if (!cards.any((c) => c.id == card.id)) {
        final allowed = await _checkPremium(
          PremiumFeature.cards,
          currentCount: cards.length,
        );
        if (allowed.isLeft()) return allowed;
      }
      return _repository.saveCard(card, cardNumber: cardNumber);
    });
  }
}
