import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../core/config/constants.dart';
import 'data/datasources/card_local_datasource.dart';
import 'data/datasources/card_number_secure_datasource.dart';
import 'data/models/card_model.dart';
import 'data/repositories/card_repository_impl.dart';
import 'domain/repositories/card_repository.dart';
import 'domain/usecases/delete_card.dart';
import 'domain/usecases/get_card_spending.dart';
import 'domain/usecases/get_card_number.dart';
import 'domain/usecases/get_cards.dart';
import 'domain/usecases/save_card.dart';
import 'presentation/bloc/cards_bloc.dart';

void registerCards(GetIt sl) {
  // Data sources
  // macOS: legacy login keychain; works without a provisioning profile.
  sl.registerLazySingleton(() => const FlutterSecureStorage(
      mOptions: MacOsOptions(usesDataProtectionKeychain: false)));
  sl.registerLazySingleton<CardLocalDataSource>(
      () => HiveCardLocalDataSource(Hive.box<CardModel>(HiveBoxes.cards)));
  sl.registerLazySingleton<CardNumberSecureDataSource>(
      () => SecureStorageCardNumberDataSource(sl()));
  // Repositories
  sl.registerLazySingleton<CardRepository>(
      () => CardRepositoryImpl(sl(), sl()));
  // Use cases
  sl.registerFactory(() => GetCards(sl()));
  sl.registerFactory(() => GetCardSpending(sl(), sl()));
  sl.registerFactory(() => SaveCard(sl()));
  sl.registerFactory(() => DeleteCard(sl()));
  sl.registerFactory(() => GetCardNumber(sl()));
  // BLoCs
  sl.registerFactory(() => CardsBloc(sl(), sl(), sl(), sl(), const Uuid()));
}
