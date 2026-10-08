import '../repositories/premium_repository.dart';

/// Debug-only switch used to test limits and the paywall without a store.
class SetDebugPremium {
  const SetDebugPremium(this._repository);

  final PremiumRepository _repository;

  void call(bool value) => _repository.setDebugPremium(value);
}
