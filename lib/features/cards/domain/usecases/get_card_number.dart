import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/card_repository.dart';

class GetCardNumber {
  const GetCardNumber(this._repository);

  final CardRepository _repository;

  /// Right(null) when no number is stored.
  Future<Either<Failure, String?>> call(String id) =>
      _repository.getCardNumber(id);
}
