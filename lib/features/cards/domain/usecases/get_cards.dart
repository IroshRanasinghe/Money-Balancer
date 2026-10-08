import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/bank_card.dart';
import '../repositories/card_repository.dart';

class GetCards {
  const GetCards(this._repository);

  final CardRepository _repository;

  Future<Either<Failure, List<BankCard>>> call() => _repository.getCards();
}
