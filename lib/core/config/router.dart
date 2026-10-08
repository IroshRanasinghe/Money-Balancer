import 'package:go_router/go_router.dart';

import '../../features/accounts/accounts_routes.dart';
import '../../features/budget/budget_routes.dart';
import '../../features/cards/cards_routes.dart';
import '../../features/dashboard/dashboard_routes.dart';
import '../../features/expense/expense_routes.dart';
import '../../features/income/income_routes.dart';
import '../../features/reports/reports_routes.dart';
import '../../features/settings/settings_routes.dart';
import '../../features/transactions/transactions_routes.dart';
import '../widgets/app_shell.dart';
import 'constants.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.dashboard,
  routes: [
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
          path: AppRoutes.dashboard,
          pageBuilder: (c, s) => NoTransitionPage(child: dashboardRouteBuilder(c, s)),
        ),
        GoRoute(
          path: AppRoutes.transactions,
          pageBuilder: (c, s) => NoTransitionPage(child: transactionsRouteBuilder(c, s)),
        ),
        GoRoute(
          path: AppRoutes.budget,
          pageBuilder: (c, s) => NoTransitionPage(child: budgetRouteBuilder(c, s)),
        ),
        GoRoute(
          path: AppRoutes.reports,
          pageBuilder: (c, s) => NoTransitionPage(child: reportsRouteBuilder(c, s)),
        ),
        GoRoute(
          path: AppRoutes.settings,
          pageBuilder: (c, s) => NoTransitionPage(child: settingsRouteBuilder(c, s)),
        ),
      ],
    ),
    GoRoute(path: AppRoutes.cards, builder: cardsRouteBuilder),
    GoRoute(path: AppRoutes.accounts, builder: accountsRouteBuilder),
    GoRoute(
        path: AppRoutes.accountDetail, builder: accountDetailRouteBuilder),
    GoRoute(path: AppRoutes.addExpense, builder: addExpenseRouteBuilder),
    GoRoute(path: AppRoutes.editExpense, builder: editExpenseRouteBuilder),
    GoRoute(path: AppRoutes.addIncome, builder: addIncomeRouteBuilder),
    GoRoute(path: AppRoutes.editIncome, builder: editIncomeRouteBuilder),
  ],
);
