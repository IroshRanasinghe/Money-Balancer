import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../core/config/constants.dart';
import 'data/datasources/goal_local_datasource.dart';
import 'data/models/goal_model.dart';
import 'data/repositories/goal_repository_impl.dart';
import 'domain/repositories/goal_repository.dart';
import 'domain/usecases/adjust_goal_savings.dart';
import 'domain/usecases/delete_goal.dart';
import 'domain/usecases/get_goals.dart';
import 'domain/usecases/save_goal.dart';
import 'presentation/bloc/goals_bloc.dart';

void registerGoals(GetIt sl) {
  // Data sources
  sl.registerLazySingleton<GoalLocalDataSource>(
    () => HiveGoalLocalDataSource(Hive.box<GoalModel>(HiveBoxes.goals)),
  );
  // Repositories
  sl.registerLazySingleton<GoalRepository>(() => GoalRepositoryImpl(sl()));
  // Use cases
  sl.registerFactory(() => GetGoals(sl()));
  sl.registerFactory(() => SaveGoal(sl(), sl()));
  sl.registerFactory(() => DeleteGoal(sl()));
  sl.registerFactory(() => AdjustGoalSavings(sl()));
  // BLoCs
  sl.registerFactory(() => GoalsBloc(sl(), sl(), sl(), sl(), const Uuid()));
}
