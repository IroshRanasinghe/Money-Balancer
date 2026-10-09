import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/premium_package.dart';
import '../../domain/entities/premium_status.dart';
import '../../domain/repositories/premium_repository.dart';
import '../datasources/premium_datasource.dart';
import '../premium_config.dart';

class PremiumRepositoryImpl implements PremiumRepository {
  const PremiumRepositoryImpl(this._source);

  final PremiumDataSource _source;

  @override
  Future<Either<Failure, PremiumStatus>> getStatus() async {
    final result = await _run(() async => _grant(await _source.getStatus()));
    // Without this, an offline store read would put everyone back on Free.
    if (PremiumConfig.forEveryone && result.isLeft()) {
      return Right(PremiumStatus(
          isPremium: true, storeAvailable: _source.storeAvailable));
    }
    return result;
  }

  @override
  Future<Either<Failure, List<PremiumPackage>>> getPackages() =>
      _run(_source.getPackages);

  @override
  Future<Either<Failure, PremiumStatus>> purchase(String packageId) =>
      _run(() async => _grant(await _source.purchase(packageId)));

  @override
  Future<Either<Failure, PremiumStatus>> restorePurchases() =>
      _run(() async => _grant(await _source.restorePurchases()));

  @override
  Stream<PremiumStatus> watchStatus() => _source.watchStatus().map(_grant);

  @override
  bool get storeAvailable => _source.storeAvailable;

  @override
  void setDebugPremium(bool value) => _source.setDebugPremium(value);

  PremiumStatus _grant(PremiumStatus status) => PremiumConfig.forEveryone
      ? status.copyWith(isPremium: true)
      : status;

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
