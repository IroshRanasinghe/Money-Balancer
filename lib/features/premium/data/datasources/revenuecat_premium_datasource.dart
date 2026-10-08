import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/premium_package.dart';
import '../../domain/entities/premium_status.dart';
import '../premium_config.dart';
import 'premium_datasource.dart';

class RevenueCatPremiumDataSource implements PremiumDataSource {
  RevenueCatPremiumDataSource();

  @override
  Future<void> init() async {
    final key = (Platform.isIOS || Platform.isMacOS)
        ? PremiumConfig.appleKey
        : PremiumConfig.googleKey;
    await Purchases.configure(PurchasesConfiguration(key));
  }

  @override
  Future<PremiumStatus> getStatus() =>
      _guard(() async => _toStatus(await Purchases.getCustomerInfo()));

  @override
  Future<List<PremiumPackage>> getPackages() => _guard(() async {
        final packages = await _currentPackages();
        return [for (final p in packages) _toPackage(p)];
      });

  @override
  Future<PremiumStatus> purchase(String packageId) => _guard(() async {
        final packages = await _currentPackages();
        final match = packages.where((p) => p.identifier == packageId);
        if (match.isEmpty) {
          throw const PurchaseException('That plan is no longer available.');
        }
        final result =
            await Purchases.purchase(PurchaseParams.package(match.first));
        return _toStatus(result.customerInfo);
      });

  @override
  Future<PremiumStatus> restorePurchases() =>
      _guard(() async => _toStatus(await Purchases.restorePurchases()));

  @override
  Stream<PremiumStatus> watchStatus() {
    late final StreamController<PremiumStatus> controller;
    void listener(CustomerInfo info) {
      if (!controller.isClosed) controller.add(_toStatus(info));
    }

    controller = StreamController<PremiumStatus>(
      onListen: () => Purchases.addCustomerInfoUpdateListener(listener),
      onCancel: () {
        Purchases.removeCustomerInfoUpdateListener(listener);
        return controller.close();
      },
    );
    return controller.stream;
  }

  @override
  void setDebugPremium(bool value) {}

  Future<List<Package>> _currentPackages() async {
    final offerings = await Purchases.getOfferings();
    return offerings.current?.availablePackages ?? const [];
  }

  PremiumStatus _toStatus(CustomerInfo info) {
    final entitlement = info.entitlements.active[PremiumConfig.entitlementId];
    return PremiumStatus(
      isPremium: entitlement != null,
      expiresAt: entitlement?.expirationDate == null
          ? null
          : DateTime.tryParse(entitlement!.expirationDate!)?.toLocal(),
      productId: entitlement?.productIdentifier,
      storeAvailable: true,
    );
  }

  PremiumPackage _toPackage(Package p) => PremiumPackage(
        id: p.identifier,
        title: p.storeProduct.title,
        priceString: p.storeProduct.priceString,
        period: switch (p.packageType) {
          PackageType.monthly => 'monthly',
          PackageType.annual => 'yearly',
          _ => 'other',
        },
        introOffer: _introOffer(p.storeProduct.introductoryPrice),
      );

  String? _introOffer(IntroductoryPrice? intro) {
    if (intro == null) return null;
    final n = intro.periodNumberOfUnits * (intro.cycles < 1 ? 1 : intro.cycles);
    final unit = switch (intro.periodUnit) {
      PeriodUnit.day => 'day',
      PeriodUnit.week => 'week',
      PeriodUnit.month => 'month',
      PeriodUnit.year => 'year',
      PeriodUnit.unknown => null,
    };
    if (unit == null) return null;
    if (intro.price == 0) return '$n-$unit free trial';
    return '${intro.priceString} for $n $unit${n == 1 ? '' : 's'}';
  }

  /// Translates SDK errors into [AppException]s. Messages are the SDK's own
  /// text; receipts and customer ids are never included.
  Future<T> _guard<T>(Future<T> Function() body) async {
    try {
      return await body();
    } on AppException {
      rethrow;
    } on PlatformException catch (e) {
      PurchasesErrorCode? code;
      try {
        code = PurchasesErrorHelper.getErrorCode(e);
      } catch (_) {
        code = null;
      }
      if (code == PurchasesErrorCode.purchaseCancelledError) {
        throw const PurchaseCancelledException();
      }
      throw PurchaseException(e.message ?? 'Something went wrong. Try again.');
    } catch (_) {
      throw const PurchaseException('Something went wrong. Try again.');
    }
  }
}
