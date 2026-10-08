import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../core/config/constants.dart';
import 'data/datasources/account_local_datasource.dart';
import 'data/datasources/transfer_local_datasource.dart';
import 'data/models/account_model.dart';
import 'data/models/transfer_model.dart';
import 'data/repositories/account_repository_impl.dart';
import 'domain/repositories/account_repository.dart';
import 'domain/usecases/delete_account.dart';
import 'domain/usecases/delete_transfer.dart';
import 'domain/usecases/get_account_activity.dart';
import 'domain/usecases/get_account_balances.dart';
import 'domain/usecases/get_accounts.dart';
import 'domain/usecases/save_account.dart';
import 'domain/usecases/save_transfer.dart';
import 'presentation/bloc/account_detail_bloc.dart';
import 'presentation/bloc/accounts_bloc.dart';

void registerAccounts(GetIt sl) {
  // Data sources
  sl.registerLazySingleton<AccountLocalDataSource>(
    () =>
        HiveAccountLocalDataSource(Hive.box<AccountModel>(HiveBoxes.accounts)),
  );
  sl.registerLazySingleton<TransferLocalDataSource>(
    () => HiveTransferLocalDataSource(
      Hive.box<TransferModel>(HiveBoxes.transfers),
    ),
  );
  // Repositories
  sl.registerLazySingleton<AccountRepository>(
    () => AccountRepositoryImpl(sl(), sl()),
  );
  // Use cases
  sl.registerFactory(() => GetAccounts(sl()));
  sl.registerFactory(() => SaveAccount(sl(), sl()));
  sl.registerFactory(() => SaveTransfer(sl()));
  sl.registerFactory(() => DeleteTransfer(sl()));
  sl.registerFactory(() => GetAccountBalances(sl(), sl()));
  sl.registerFactory(() => DeleteAccount(sl(), sl()));
  sl.registerFactory(() => GetAccountActivity(sl(), sl()));
  // BLoCs
  sl.registerFactory(
    () => AccountsBloc(sl(), sl(), sl(), sl(), sl(), const Uuid()),
  );
  sl.registerFactory(() => AccountDetailBloc(sl(), sl()));
}
