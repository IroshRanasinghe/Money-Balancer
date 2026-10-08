class AppRoutes {
  const AppRoutes._();

  static const dashboard = '/';
  static const transactions = '/transactions';
  static const budget = '/budget';
  static const reports = '/reports';
  static const settings = '/settings';
  static const cards = '/cards';
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
}

class HiveTypeIds {
  const HiveTypeIds._();

  static const transaction = 0;
  static const budget = 1;
  static const settings = 2;
  static const card = 3;
}

class AppCategories {
  const AppCategories._();

  static const expense = [
    'Food',
    'Groceries',
    'Transport',
    'Fuel',
    'Shopping',
    'Rent',
    'Lease',
    'Bills',
    'Utilities',
    'Subscriptions',
    'Entertainment',
    'Travel',
    'Health',
    'Fitness',
    'Personal Care',
    'Insurance',
    'Education',
    'Kids',
    'Pets',
    'Donations',
    'Loan Payments',
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
