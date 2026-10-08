import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/premium_package.dart';
import '../entities/premium_status.dart';

abstract class PremiumRepository {
  Future<Either<Failure, PremiumStatus>> getStatus();

  Future<Either<Failure, List<PremiumPackage>>> getPackages();

  /// Fails with [PurchaseCancelledFailure] when the user backs out.
  Future<Either<Failure, PremiumStatus>> purchase(String packageId);

  Future<Either<Failure, PremiumStatus>> restorePurchases();

  /// Plain stream; consumers ignore its errors.
  Stream<PremiumStatus> watchStatus();

  /// Debug builds only; a no-op elsewhere.
  void setDebugPremium(bool value);
}
