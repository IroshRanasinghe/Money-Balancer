import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/premium_package.dart';
import '../../domain/entities/premium_status.dart';
import 'premium_datasource.dart';

/// Used on web, desktop, or when no store key is configured.
class UnavailablePremiumDataSource implements PremiumDataSource {
  UnavailablePremiumDataSource();

  final _controller = StreamController<PremiumStatus>.broadcast();
  bool _debugPremium = false;

  PremiumStatus get _status =>
      PremiumStatus(isPremium: _debugPremium, storeAvailable: false);

  @override
  Future<void> init() async {}

  @override
  Future<PremiumStatus> getStatus() async => _status;

  @override
  Future<List<PremiumPackage>> getPackages() async => const [];

  @override
  Future<PremiumStatus> purchase(String packageId) =>
      Future.error(const StoreUnavailableException());

  @override
  Future<PremiumStatus> restorePurchases() =>
      Future.error(const StoreUnavailableException());

  @override
  Stream<PremiumStatus> watchStatus() => _controller.stream;

  @override
  void setDebugPremium(bool value) {
    if (!kDebugMode) return;
    _debugPremium = value;
    _controller.add(_status);
  }
}
