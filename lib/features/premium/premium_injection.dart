import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

import 'data/datasources/premium_datasource.dart';
import 'data/datasources/revenuecat_premium_datasource.dart';
import 'data/datasources/unavailable_premium_datasource.dart';
import 'data/premium_config.dart';
import 'data/repositories/premium_repository_impl.dart';
import 'domain/repositories/premium_repository.dart';
import 'domain/usecases/check_premium_access.dart';
import 'domain/usecases/get_premium_packages.dart';
import 'domain/usecases/is_store_available.dart';
import 'domain/usecases/get_premium_status.dart';
import 'domain/usecases/purchase_premium.dart';
import 'domain/usecases/restore_purchases.dart';
import 'domain/usecases/set_debug_premium.dart';
import 'domain/usecases/watch_premium_status.dart';
import 'presentation/bloc/premium_bloc.dart';

/// The store is only used on iOS, macOS and Android with a configured key.
bool _storeSupported() {
  if (kIsWeb) return false;
  if (Platform.isIOS || Platform.isMacOS) {
    return PremiumConfig.appleKey.isNotEmpty;
  }
  if (Platform.isAndroid) return PremiumConfig.googleKey.isNotEmpty;
  return false;
}

Future<void> registerPremium(GetIt sl) async {
  // Data sources: a failed init falls back to "store unavailable".
  PremiumDataSource source = _storeSupported()
      ? RevenueCatPremiumDataSource()
      : UnavailablePremiumDataSource();
  try {
    await source.init().timeout(const Duration(seconds: 5));
  } catch (_) {
    source = UnavailablePremiumDataSource();
  }
  sl.registerSingleton<PremiumDataSource>(source);
  // Repositories
  sl.registerLazySingleton<PremiumRepository>(
      () => PremiumRepositoryImpl(sl()));
  // Use cases
  sl.registerFactory(() => GetPremiumStatus(sl()));
  sl.registerFactory(() => GetPremiumPackages(sl()));
  sl.registerFactory(() => PurchasePremium(sl()));
  sl.registerFactory(() => RestorePurchases(sl()));
  sl.registerFactory(() => WatchPremiumStatus(sl()));
  sl.registerFactory(() => SetDebugPremium(sl()));
  sl.registerFactory(() => IsStoreAvailable(sl()));
  sl.registerFactory(() => CheckPremiumAccess(sl()));
  // BLoCs
  sl.registerFactory(() => PremiumBloc(sl(), sl(), sl(), sl(), sl(), sl(), sl()));
}
