import 'package:get_it/get_it.dart';
import 'package:uuid/uuid.dart';

import '../transactions/domain/entities/transaction.dart';
import 'domain/usecases/add_expense.dart';
import 'presentation/bloc/expense_bloc.dart';

void registerExpense(GetIt sl) {
  // Use cases
  sl.registerFactory(() => AddExpense(sl(), const Uuid()));
  // BLoCs
  sl.registerFactoryParam<ExpenseBloc, Transaction?, void>(
    (initial, _) => ExpenseBloc(sl(), sl(), sl(), initial: initial),
  );
}
