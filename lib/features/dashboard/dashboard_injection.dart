import 'package:get_it/get_it.dart';

import 'domain/usecases/get_dashboard_summary.dart';
import 'presentation/bloc/dashboard_bloc.dart';

void registerDashboard(GetIt sl) {
  // Use cases
  sl.registerFactory(() => GetDashboardSummary(sl()));
  // BLoCs
  sl.registerFactory(() => DashboardBloc(sl()));
}
