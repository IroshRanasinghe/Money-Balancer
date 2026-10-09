import 'package:uuid/uuid.dart';

import '../../features/accounts/domain/entities/account.dart';
import '../../features/accounts/domain/usecases/save_account.dart';
import '../../features/budget/domain/entities/budget.dart';
import '../../features/budget/domain/usecases/save_budget.dart';
import '../../features/cards/domain/entities/bank_card.dart';
import '../../features/cards/domain/usecases/save_card.dart';
import '../../features/expense/domain/usecases/add_expense.dart';
import '../../features/goals/domain/entities/savings_goal.dart';
import '../../features/goals/domain/repositories/goal_repository.dart';
import '../../features/income/domain/usecases/add_income.dart';
import '../../features/recurring/domain/entities/recurring_rule.dart';
import '../../features/recurring/domain/usecases/save_recurring_rule.dart';
import '../../features/transactions/domain/entities/transaction.dart';
import '../../features/transactions/domain/repositories/transaction_repository.dart';
import '../../features/transactions/domain/usecases/get_transactions.dart';
import '../di/injection_container.dart';

/// Populates an empty install with realistic sample data for screenshots.
/// Only called from `main.dart` when built with `--dart-define=DEMO_DATA=true`.
/// Does nothing if any transaction already exists. Failures are ignored on
/// purpose: this is a best-effort demo seeder.
Future<void> seedDummyDataIfEmpty() async {
  final existing = (await sl<GetTransactions>()()).getOrElse(() => const []);
  if (existing.isNotEmpty) return;

  const uuid = Uuid();
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  // Accounts
  final everyday = uuid.v4();
  final cash = uuid.v4();
  final saveAccount = sl<SaveAccount>();
  await saveAccount(
    Account(
      id: everyday,
      name: 'Everyday',
      type: AccountType.bank,
      openingBalance: 1200,
      colorValue: 0xFF2563EB,
      createdAt: now,
    ),
  );
  await saveAccount(
    Account(
      id: cash,
      name: 'Cash',
      type: AccountType.cash,
      openingBalance: 150,
      colorValue: 0xFF22C55E,
      createdAt: now,
    ),
  );

  // Card
  final cardId = uuid.v4();
  await sl<SaveCard>()(
    BankCard(
      id: cardId,
      nickname: 'Visa Platinum',
      bankName: 'Everyday Bank',
      type: CardType.credit,
      network: CardNetwork.visa,
      last4: '4242',
      expiryMonth: 11,
      expiryYear: now.year + 3,
      colorValue: 0xFF4F46E5,
      createdAt: now,
    ),
  );

  // Date helper: day [d] of the month [back] months ago, never in the future.
  DateTime at(int back, int d) {
    final date = DateTime(now.year, now.month - back, d);
    return date.isAfter(today) ? today : date;
  }

  final addExpense = sl<AddExpense>();
  final addIncome = sl<AddIncome>();
  final transactions = sl<TransactionRepository>();

  Future<void> expense(
    String category,
    double amount,
    int back,
    int day, {
    String? notes,
    bool onCard = false,
    bool inCash = false,
  }) => addExpense(
    amount: amount,
    category: category,
    date: at(back, day),
    notes: notes,
    paymentMethod: onCard ? 'Card' : (inCash ? 'Cash' : 'Bank Transfer'),
    cardId: onCard ? cardId : null,
    cardLast4: onCard ? '4242' : null,
    accountId: inCash ? cash : everyday,
  );

  // Recurring rules and their already-generated transactions. Ids follow the
  // `<ruleId>_<index>` scheme used by ProcessDueRecurring.
  const salaryRuleId = 'demo_salary';
  const netflixRuleId = 'demo_netflix';
  final salaryStart = DateTime(now.year, now.month - 5, 1);
  final netflixStart = DateTime(now.year, now.month - 5, 12);
  var netflixCount = 0;
  for (var i = 0; i < 6; i++) {
    final date = DateTime(netflixStart.year, netflixStart.month + i, 12);
    if (date.isAfter(today)) break;
    netflixCount++;
    await transactions.addTransaction(
      Transaction(
        id: '${netflixRuleId}_$i',
        amount: 15.99,
        category: 'Subscriptions',
        date: date,
        type: TransactionType.expense,
        paymentMethod: 'Card',
        cardId: cardId,
        cardLast4: '4242',
        notes: 'Netflix',
        accountId: everyday,
        recurringId: netflixRuleId,
        createdAt: now,
      ),
    );
  }
  for (var i = 0; i < 6; i++) {
    await transactions.addTransaction(
      Transaction(
        id: '${salaryRuleId}_$i',
        amount: 3200,
        category: 'Salary',
        date: DateTime(salaryStart.year, salaryStart.month + i, 1),
        type: TransactionType.income,
        notes: 'Monthly salary',
        accountId: everyday,
        recurringId: salaryRuleId,
        createdAt: now,
      ),
    );
  }
  final saveRule = sl<SaveRecurringRule>();
  await saveRule(
    RecurringRule(
      id: salaryRuleId,
      type: TransactionType.income,
      amount: 3200,
      category: 'Salary',
      notes: 'Monthly salary',
      accountId: everyday,
      frequency: RecurrenceFrequency.monthly,
      startDate: salaryStart,
      generatedCount: 6,
      createdAt: now,
    ),
  );
  await saveRule(
    RecurringRule(
      id: netflixRuleId,
      type: TransactionType.expense,
      amount: 15.99,
      category: 'Subscriptions',
      paymentMethod: 'Card',
      notes: 'Netflix',
      accountId: everyday,
      frequency: RecurrenceFrequency.monthly,
      startDate: netflixStart,
      generatedCount: netflixCount,
      createdAt: now,
    ),
  );

  // Current month (Food 340/400, Transport 60/150, Shopping 345/300,
  // Bills 150/250).
  await expense('Food', 120, 0, 2, notes: 'Dinner out', onCard: true);
  await expense('Food', 85, 0, 4, notes: 'Lunch with team');
  await expense('Food', 75, 0, 6, inCash: true);
  await expense('Food', 60, 0, 8, notes: 'Brunch', onCard: true);
  await expense('Transport', 35, 0, 3, notes: 'Monthly pass', inCash: true);
  await expense('Transport', 25, 0, 7, notes: 'Taxi');
  await expense('Shopping', 220, 0, 5, notes: 'Sneakers', onCard: true);
  await expense('Shopping', 125, 0, 8, notes: 'Home decor');
  await expense('Bills', 90, 0, 2, notes: 'Internet');
  await expense('Bills', 60, 0, 4, notes: 'Phone');
  await addIncome(
    amount: 450,
    category: 'Freelance',
    date: at(0, 6),
    notes: 'Logo design',
    accountId: everyday,
  );

  // Previous five months.
  const history = [
    ('Food', 310.0, 'Groceries'),
    ('Transport', 120.0, null),
    ('Shopping', 260.0, null),
    ('Bills', 210.0, null),
    ('Entertainment', 95.0, 'Concert'),
    ('Health', 70.0, null),
    ('Groceries', 180.0, null),
  ];
  for (var back = 1; back <= 5; back++) {
    for (var j = 0; j < 2; j++) {
      final h = history[(back * 2 + j) % history.length];
      await expense(
        h.$1,
        h.$2 + back * 7,
        back,
        6 + j * 11,
        notes: h.$3,
        onCard: j == 0,
      );
    }
  }

  // Budgets for the current month.
  final saveBudget = sl<SaveBudget>();
  for (final (category, limit) in const [
    ('Food', 400.0),
    ('Transport', 150.0),
    ('Shopping', 300.0),
    ('Bills', 250.0),
  ]) {
    await saveBudget(
      Budget(
        id: uuid.v4(),
        category: category,
        limit: limit,
        month: now.month,
        year: now.year,
      ),
    );
  }

  // Goals (saved through the repository so the free-plan limit of one goal
  // doesn't apply to demo data).
  final goals = sl<GoalRepository>();
  await goals.saveGoal(
    SavingsGoal(
      id: uuid.v4(),
      name: 'Emergency fund',
      targetAmount: 5000,
      savedAmount: 3200,
      targetDate: DateTime(now.year, now.month + 8, now.day),
      colorValue: 0xFF22C55E,
      createdAt: now,
    ),
  );
  await goals.saveGoal(
    SavingsGoal(
      id: uuid.v4(),
      name: 'New laptop',
      targetAmount: 1800,
      savedAmount: 450,
      colorValue: 0xFF7C3AED,
      createdAt: now,
    ),
  );
}
