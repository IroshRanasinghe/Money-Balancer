import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../core/config/constants.dart';
import 'data/datasources/budget_alert_datasource.dart';
import 'data/datasources/budget_local_datasource.dart';
import 'data/models/budget_model.dart';
import 'data/repositories/budget_alert_repository_impl.dart';
import 'data/repositories/budget_repository_impl.dart';
import 'domain/repositories/budget_alert_repository.dart';
import 'domain/repositories/budget_repository.dart';
import 'domain/usecases/check_budget_alerts.dart';
import 'domain/usecases/delete_budget.dart';
import 'domain/usecases/get_budget_progress.dart';
import 'domain/usecases/save_budget.dart';
import 'presentation/bloc/budget_bloc.dart';

void registerBudget(GetIt sl) {
  // Data sources
  sl.registerLazySingleton<BudgetLocalDataSource>(() =>
      HiveBudgetLocalDataSource(Hive.box<BudgetModel>(HiveBoxes.budgets)));
  sl.registerLazySingleton<BudgetAlertDataSource>(
      () => HiveBudgetAlertDataSource(Hive.box<bool>(HiveBoxes.budgetAlerts)));
  // Repositories
  sl.registerLazySingleton<BudgetRepository>(() => BudgetRepositoryImpl(sl()));
  sl.registerLazySingleton<BudgetAlertRepository>(
      () => BudgetAlertRepositoryImpl(sl()));
  // Use cases
  sl.registerFactory(() => GetBudgetProgress(sl(), sl()));
  sl.registerFactory(() => SaveBudget(sl(), sl()));
  sl.registerFactory(() => DeleteBudget(sl()));
  sl.registerFactory(() => CheckBudgetAlerts(sl(), sl(), sl(), sl(), sl()));
  // BLoCs
  sl.registerFactory(() => BudgetBloc(sl(), sl(), sl(), const Uuid()));
}
