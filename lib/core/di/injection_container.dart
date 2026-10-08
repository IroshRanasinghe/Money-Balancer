import 'package:get_it/get_it.dart';

import '../../features/budget/budget_injection.dart';
import '../../features/dashboard/dashboard_injection.dart';
import '../../features/expense/expense_injection.dart';
import '../../features/income/income_injection.dart';
import '../../features/reports/reports_injection.dart';
import '../../features/settings/settings_injection.dart';
import '../../features/transactions/transactions_injection.dart';
import '../hive/hive_setup.dart';

final GetIt sl = GetIt.instance;

Future<void> initDependencies() async {
  await HiveSetup.init();

  // Shared data (other features depend on these repositories)
  registerSettings(sl);
  registerTransactions(sl);

  // Features
  registerExpense(sl);
  registerIncome(sl);
  registerDashboard(sl);
  registerBudget(sl);
  registerReports(sl);
}
