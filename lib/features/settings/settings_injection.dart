import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';

import '../../core/config/constants.dart';
import 'data/datasources/settings_local_datasource.dart';
import 'data/models/app_settings_model.dart';
import 'data/repositories/settings_repository_impl.dart';
import 'domain/entities/app_settings.dart';
import 'domain/repositories/settings_repository.dart';
import 'domain/usecases/get_settings.dart';
import 'domain/usecases/save_settings.dart';
import 'presentation/bloc/settings_bloc.dart';

void registerSettings(GetIt sl) {
  // Data sources
  sl.registerLazySingleton<SettingsLocalDataSource>(() =>
      HiveSettingsLocalDataSource(Hive.box<AppSettingsModel>(HiveBoxes.settings)));
  // Repositories
  sl.registerLazySingleton<SettingsRepository>(() => SettingsRepositoryImpl(sl()));
  // Use cases
  sl.registerFactory(() => GetSettings(sl()));
  sl.registerFactory(() => SaveSettings(sl()));
  // BLoCs
  sl.registerFactoryParam<SettingsBloc, AppSettings?, void>((s, _) =>
      SettingsBloc(sl(), sl(), initialSettings: s ?? const AppSettings()));
}
