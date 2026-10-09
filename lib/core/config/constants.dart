class AppRoutes {
  const AppRoutes._();

  static const dashboard = '/';
  static const transactions = '/transactions';
  static const budget = '/budget';
  static const reports = '/reports';
  static const settings = '/settings';
  static const cards = '/cards';
  static const accounts = '/accounts';
  static const accountDetail = '/accounts/detail';
  static const recurring = '/recurring';
  static const premium = '/premium';
  static const goals = '/goals';
  static const addExpense = '/expense/add';
  static const editExpense = '/expense/edit';
  static const addIncome = '/income/add';
  static const editIncome = '/income/edit';
}

class HiveBoxes {
  const HiveBoxes._();

  static const transactions = 'transactions';
  static const budgets = 'budgets';
  static const settings = 'app_settings';
  static const cards = 'cards';
  static const accounts = 'accounts';
  static const transfers = 'transfers';
  static const recurring = 'recurring_rules';
  static const goals = 'goals';
  static const budgetAlerts = 'budget_alerts';
}

class HiveTypeIds {
  const HiveTypeIds._();

  static const transaction = 0;
  static const budget = 1;
  static const settings = 2;
  static const card = 3;
  static const account = 4;
  static const transfer = 5;
  static const recurring = 6;
  static const goal = 7;
}

class AppCategories {
  const AppCategories._();

  static const expense = [
    'Food',
    'Uber Eats',
    'PickMe Eats',
    'Groceries',
    'Kitchen Items',
    'Transport',
    'Uber',
    'PickMe',
    'Fuel',
    'Shopping',
    'Rent',
    'Lease',
    'Bills',
    'Utilities',
    'Dialog Internet',
    'Mobitel Internet',
    'Dialog Phone Card',
    'Mobitel Phone Card',
    'Subscriptions',
    'Entertainment',
    'Travel',
    'Health',
    'Fitness',
    'Personal Care',
    'Insurance',
    'Education',
    'Kids',
    'Toys',
    'Pets',
    'Donations',
    'Loan Payments',
    'Credit Card',
    'Pawn',
    'Other',
  ];

  static const income = [
    'Salary',
    'Freelance',
    'Business',
    'Investment',
    'Gift',
    'Other',
  ];
}

class PaymentMethods {
  const PaymentMethods._();

  static const all = ['Cash', 'Card', 'Bank Transfer', 'Mobile Wallet'];
}

class SupportedCurrencies {
  const SupportedCurrencies._();

  static const codes = ['USD', 'EUR', 'GBP', 'INR', 'LKR'];
}

class PremiumLimits {
  const PremiumLimits._();

  static const freeAccounts = 2;
  static const freeCards = 2;
  static const freeBudgetsPerMonth = 5;
  static const freeRecurring = 3;
  static const freeGoals = 1;
}
