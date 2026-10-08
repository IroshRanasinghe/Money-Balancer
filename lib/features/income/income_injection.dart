import 'package:get_it/get_it.dart';
import 'package:uuid/uuid.dart';

import '../transactions/domain/entities/transaction.dart';
import 'domain/usecases/add_income.dart';
import 'presentation/bloc/income_bloc.dart';

void registerIncome(GetIt sl) {
  // Use cases
  sl.registerFactory(() => AddIncome(sl(), const Uuid()));
  // BLoCs
  sl.registerFactoryParam<IncomeBloc, Transaction?, void>(
    (initial, _) => IncomeBloc(sl(), sl(), sl(), initial: initial),
  );
}
