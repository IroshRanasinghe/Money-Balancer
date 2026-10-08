import 'package:hive_flutter/hive_flutter.dart';

import '../../features/accounts/data/models/account_model.dart';
import '../../features/accounts/data/models/transfer_model.dart';
import '../../features/budget/data/models/budget_model.dart';
import '../../features/cards/data/models/card_model.dart';
import '../../features/settings/data/models/app_settings_model.dart';
import '../../features/transactions/data/models/transaction_model.dart';
import '../config/constants.dart';
import 'adapters/account_model_adapter.dart';
import 'adapters/budget_model_adapter.dart';
import 'adapters/card_model_adapter.dart';
import 'adapters/app_settings_model_adapter.dart';
import 'adapters/transfer_model_adapter.dart';
import 'adapters/transaction_model_adapter.dart';

class HiveSetup {
  const HiveSetup._();

  /// Registers every adapter, then opens every box. Call before DI.
  static Future<void> init() async {
    await Hive.initFlutter();

    Hive.registerAdapter(AppSettingsModelAdapter());
    Hive.registerAdapter(TransactionModelAdapter());
    Hive.registerAdapter(BudgetModelAdapter());
    Hive.registerAdapter(CardModelAdapter());
    Hive.registerAdapter(AccountModelAdapter());
    Hive.registerAdapter(TransferModelAdapter());

    await Hive.openBox<AppSettingsModel>(HiveBoxes.settings);
    await Hive.openBox<TransactionModel>(HiveBoxes.transactions);
    await Hive.openBox<BudgetModel>(HiveBoxes.budgets);
    await Hive.openBox<CardModel>(HiveBoxes.cards);
    await Hive.openBox<AccountModel>(HiveBoxes.accounts);
    await Hive.openBox<TransferModel>(HiveBoxes.transfers);
  }
}
