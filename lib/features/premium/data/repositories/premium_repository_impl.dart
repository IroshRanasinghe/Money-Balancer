import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/premium_package.dart';
import '../../domain/entities/premium_status.dart';
import '../../domain/repositories/premium_repository.dart';
import '../datasources/premium_datasource.dart';

class PremiumRepositoryImpl implements PremiumRepository {
  const PremiumRepositoryImpl(this._source);

  final PremiumDataSource _source;

  @override
  Future<Either<Failure, PremiumStatus>> getStatus() =>
      _run(_source.getStatus);

  @override
  Future<Either<Failure, List<PremiumPackage>>> getPackages() =>
      _run(_source.getPackages);

  @override
  Future<Either<Failure, PremiumStatus>> purchase(String packageId) =>
      _run(() => _source.purchase(packageId));

  @override
  Future<Either<Failure, PremiumStatus>> restorePurchases() =>
      _run(_source.restorePurchases);

  @override
  Stream<PremiumStatus> watchStatus() => _source.watchStatus();

  @override
  bool get storeAvailable => _source.storeAvailable;

  @override
  void setDebugPremium(bool value) => _source.setDebugPremium(value);

  Future<Either<Failure, T>> _run<T>(Future<T> Function() body) async {
    try {
      return Right(await body());
    } on PurchaseCancelledException catch (e) {
      return Left(PurchaseCancelledFailure(e.message));
    } on StoreUnavailableException catch (e) {
      return Left(StoreUnavailableFailure(e.message));
    } on AppException catch (e) {
      return Left(PurchaseFailure(e.message));
    }
  }
}
