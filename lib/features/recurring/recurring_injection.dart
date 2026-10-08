import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../core/config/constants.dart';
import 'data/datasources/recurring_local_datasource.dart';
import 'data/models/recurring_rule_model.dart';
import 'data/repositories/recurring_repository_impl.dart';
import 'domain/repositories/recurring_repository.dart';
import 'domain/usecases/delete_recurring_rule.dart';
import 'domain/usecases/get_recurring_rules.dart';
import 'domain/usecases/process_due_recurring.dart';
import 'domain/usecases/save_recurring_rule.dart';
import 'presentation/bloc/recurring_bloc.dart';

void registerRecurring(GetIt sl) {
  // Data sources
  sl.registerLazySingleton<RecurringLocalDataSource>(
    () => HiveRecurringLocalDataSource(
      Hive.box<RecurringRuleModel>(HiveBoxes.recurring),
    ),
  );
  // Repositories
  sl.registerLazySingleton<RecurringRepository>(
    () => RecurringRepositoryImpl(sl()),
  );
  // Use cases
  sl.registerFactory(() => GetRecurringRules(sl()));
  sl.registerFactory(() => SaveRecurringRule(sl()));
  sl.registerFactory(() => DeleteRecurringRule(sl()));
  sl.registerFactory(() => ProcessDueRecurring(sl(), sl()));
  // BLoCs
  sl.registerFactory(
    () => RecurringBloc(sl(), sl(), sl(), sl(), const Uuid()),
  );
}
