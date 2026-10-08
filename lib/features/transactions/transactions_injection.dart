import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';

import '../../core/config/constants.dart';
import 'data/datasources/transaction_local_datasource.dart';
import 'data/models/transaction_model.dart';
import 'data/repositories/transaction_repository_impl.dart';
import 'domain/repositories/transaction_repository.dart';
import 'domain/usecases/delete_transaction.dart';
import 'domain/usecases/get_transactions.dart';
import 'domain/usecases/update_transaction.dart';
import 'presentation/bloc/transaction_bloc.dart';

void registerTransactions(GetIt sl) {
  // Data sources
  sl.registerLazySingleton<TransactionLocalDataSource>(() =>
      HiveTransactionLocalDataSource(
          Hive.box<TransactionModel>(HiveBoxes.transactions)));
  // Repositories
  sl.registerLazySingleton<TransactionRepository>(
      () => TransactionRepositoryImpl(sl()));
  // Use cases
  sl.registerFactory(() => GetTransactions(sl()));
  sl.registerFactory(() => UpdateTransaction(sl()));
  sl.registerFactory(() => DeleteTransaction(sl()));
  // BLoCs
  sl.registerFactory(() => TransactionBloc(sl(), sl()));
}
