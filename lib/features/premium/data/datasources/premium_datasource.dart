import '../../domain/entities/premium_package.dart';
import '../../domain/entities/premium_status.dart';

/// Throws `AppException` subclasses; never returns `Either`.
abstract class PremiumDataSource {
  /// Prepares the store SDK. Throws on failure.
  Future<void> init();

  Future<PremiumStatus> getStatus();

  Future<List<PremiumPackage>> getPackages();

  Future<PremiumStatus> purchase(String packageId);

  Future<PremiumStatus> restorePurchases();

  Stream<PremiumStatus> watchStatus();

  /// Whether a real store backs this datasource, regardless of reads working.
  bool get storeAvailable;

  /// Debug builds only; ignored everywhere else.
  void setDebugPremium(bool value);
}
