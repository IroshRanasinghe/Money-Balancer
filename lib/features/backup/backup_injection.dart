import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';

import '../../core/config/constants.dart';
import '../accounts/data/models/account_model.dart';
import '../accounts/data/models/transfer_model.dart';
import '../budget/data/models/budget_model.dart';
import '../cards/data/models/card_model.dart';
import '../goals/data/models/goal_model.dart';
import '../recurring/data/models/recurring_rule_model.dart';
import '../settings/data/models/app_settings_model.dart';
import '../transactions/data/models/transaction_model.dart';
import 'data/datasources/backup_file_datasource.dart';
import 'data/datasources/backup_local_datasource.dart';
import 'data/repositories/backup_repository_impl.dart';
import 'domain/repositories/backup_repository.dart';
import 'domain/usecases/export_backup.dart';
import 'domain/usecases/export_transactions_csv.dart';
import 'domain/usecases/restore_backup_from_file.dart';
import 'presentation/bloc/backup_bloc.dart';

void registerBackup(GetIt sl) {
  // Data sources
  sl.registerLazySingleton<BackupLocalDataSource>(
      () => HiveBackupLocalDataSource(
            Hive.box<AppSettingsModel>(HiveBoxes.settings),
            Hive.box<TransactionModel>(HiveBoxes.transactions),
            Hive.box<BudgetModel>(HiveBoxes.budgets),
            Hive.box<CardModel>(HiveBoxes.cards),
            Hive.box<AccountModel>(HiveBoxes.accounts),
            Hive.box<TransferModel>(HiveBoxes.transfers),
            Hive.box<RecurringRuleModel>(HiveBoxes.recurring),
            Hive.box<GoalModel>(HiveBoxes.goals),
            sl(),
          ));
  sl.registerLazySingleton<BackupFileDataSource>(
      () => const PlatformBackupFileDataSource());
  // Repositories
  sl.registerLazySingleton<BackupRepository>(
      () => BackupRepositoryImpl(sl(), sl()));
  // Use cases
  sl.registerFactory(() => ExportBackup(sl()));
  sl.registerFactory(() => RestoreBackupFromFile(sl()));
  sl.registerFactory(() => ExportTransactionsCsv(sl(), sl(), sl(), sl()));
  // BLoCs
  sl.registerFactory(() => BackupBloc(sl(), sl(), sl()));
}
