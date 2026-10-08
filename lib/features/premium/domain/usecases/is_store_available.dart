import '../repositories/premium_repository.dart';

class IsStoreAvailable {
  const IsStoreAvailable(this._repository);

  final PremiumRepository _repository;

  bool call() => _repository.storeAvailable;
}
