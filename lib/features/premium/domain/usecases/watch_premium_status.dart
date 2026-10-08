import '../entities/premium_status.dart';
import '../repositories/premium_repository.dart';

class WatchPremiumStatus {
  const WatchPremiumStatus(this._repository);

  final PremiumRepository _repository;

  Stream<PremiumStatus> call() => _repository.watchStatus();
}
