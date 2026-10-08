import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/card_repository.dart';

class DeleteCard {
  const DeleteCard(this._repository);

  final CardRepository _repository;

  Future<Either<Failure, void>> call(String id) => _repository.deleteCard(id);
}
