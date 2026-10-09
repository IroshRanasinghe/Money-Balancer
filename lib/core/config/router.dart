import 'package:go_router/go_router.dart';

import '../../features/accounts/accounts_routes.dart';
import '../../features/budget/budget_routes.dart';
import '../../features/cards/cards_routes.dart';
import '../../features/dashboard/dashboard_routes.dart';
import '../../features/expense/expense_routes.dart';
import '../../features/goals/goals_routes.dart';
import '../../features/income/income_routes.dart';
import '../../features/premium/premium_routes.dart';
import '../../features/recurring/recurring_routes.dart';
import '../../features/reports/reports_routes.dart';
import '../../features/settings/settings_routes.dart';
import '../../features/transactions/transactions_routes.dart';
import '../widgets/app_shell.dart';
import 'constants.dart';
import 'page_transitions.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.dashboard,
  routes: [
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
          path: AppRoutes.dashboard,
          pageBuilder: (c, s) =>
              fadeTabPage(state: s, child: dashboardRouteBuilder(c, s)),
        ),
        GoRoute(
          path: AppRoutes.transactions,
          pageBuilder: (c, s) =>
              fadeTabPage(state: s, child: transactionsRouteBuilder(c, s)),
        ),
        GoRoute(
          path: AppRoutes.budget,
          pageBuilder: (c, s) =>
              fadeTabPage(state: s, child: budgetRouteBuilder(c, s)),
        ),
        GoRoute(
          path: AppRoutes.reports,
          pageBuilder: (c, s) =>
              fadeTabPage(state: s, child: reportsRouteBuilder(c, s)),
        ),
        GoRoute(
          path: AppRoutes.settings,
          pageBuilder: (c, s) =>
              fadeTabPage(state: s, child: settingsRouteBuilder(c, s)),
        ),
      ],
    ),
    GoRoute(
      path: AppRoutes.cards,
      pageBuilder: fadeSlideBuilder(cardsRouteBuilder),
    ),
    GoRoute(
      path: AppRoutes.accounts,
      pageBuilder: fadeSlideBuilder(accountsRouteBuilder),
    ),
    GoRoute(
      path: AppRoutes.accountDetail,
      pageBuilder: fadeSlideBuilder(accountDetailRouteBuilder),
    ),
    GoRoute(
      path: AppRoutes.recurring,
      pageBuilder: fadeSlideBuilder(recurringRouteBuilder),
    ),
    GoRoute(
      path: AppRoutes.goals,
      pageBuilder: fadeSlideBuilder(goalsRouteBuilder),
    ),
    GoRoute(
      path: AppRoutes.premium,
      pageBuilder: fadeSlideBuilder(premiumRouteBuilder),
    ),
    GoRoute(
      path: AppRoutes.addExpense,
      pageBuilder: fadeSlideBuilder(addExpenseRouteBuilder),
    ),
    GoRoute(
      path: AppRoutes.editExpense,
      pageBuilder: fadeSlideBuilder(editExpenseRouteBuilder),
    ),
    GoRoute(
      path: AppRoutes.addIncome,
      pageBuilder: fadeSlideBuilder(addIncomeRouteBuilder),
    ),
    GoRoute(
      path: AppRoutes.editIncome,
      pageBuilder: fadeSlideBuilder(editIncomeRouteBuilder),
    ),
  ],
);
