import 'package:get_it/get_it.dart';

import 'domain/usecases/get_report.dart';
import 'presentation/bloc/reports_bloc.dart';

void registerReports(GetIt sl) {
  // Use cases
  sl.registerFactory(() => GetReport(sl()));
  // BLoCs
  sl.registerFactory(() => ReportsBloc(sl()));
}
