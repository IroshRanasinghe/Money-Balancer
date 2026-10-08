# Savings Goals & Budget Alerts — Design & Implementation Brief (MB-GOALS)

Approved by the user in chat on 2026-10-09 ("go ahead" on the premium proposal). This is premium release 1, part 2. It depends on MB-PREMIUM (`CheckPremiumAccess`, `PremiumFeature.goals` / `.budgetAlerts`, `openPaywall`, and the `paywallCount` pattern).

## Goal
1. **Savings goals:** named targets with an optional deadline. The user adds or withdraws money and watches progress. Free plan: 1 goal. Premium: unlimited.
2. **Budget alerts (Premium):** a local notification when a budget first reaches 80% and again when it first goes over 100% in a month.

## Hard rules
- Follow the existing patterns (see `lib/features/accounts/` and `lib/features/premium/`).
- New package allowed: `flutter_local_notifications` (latest compatible). Apply the platform setup its README requires for **immediate** notifications only (no scheduling, no `timezone` package). Android: add the `POST_NOTIFICATIONS` permission. iOS/macOS: request permission at runtime. On web and other unsupported platforms, notifications are a silent no-op, and `flutter build web --release` must still succeed (use a conditional import or a `kIsWeb` guard).
- No test files. Verification: build_runner, then `flutter analyze` → "No issues found!", then `flutter build web --release`.

## Part 1 — Savings goals (`lib/features/goals/`)

### Data
Constants: `HiveBoxes.goals = 'goals'`, `HiveTypeIds.goal = 7`, `AppRoutes.goals = '/goals'`.

freezed `SavingsGoal { String id, String name, double targetAmount, @Default(0) double savedAmount, DateTime? targetDate, int colorValue, DateTime createdAt }`, with getters (via `const SavingsGoal._();`):
- `double get progress` = savedAmount / targetAmount clamped 0..1 (0 when target ≤ 0)
- `bool get isCompleted` = `savedAmount >= targetAmount`
- `double get remaining` = max(0, target − saved)
- `double? monthlyNeeded(DateTime now)`: null when there's no targetDate or the goal is completed. Otherwise remaining ÷ max(1, whole months from now to targetDate rounded up).

Also: `GoalModel`, `GoalModelAdapter`, `GoalLocalDataSource` / `HiveGoalLocalDataSource`, and `GoalRepositoryImpl`. Repository methods: `getGoals()` (incomplete first, then by targetDate ascending with nulls last, then createdAt), `saveGoal`, `deleteGoal` (NotFoundFailure if absent). Add the goals box to **backup/restore** (`"goals"` list key; the export map, `replaceAll` parse/snapshot/rollback, and `BackupCounts.goals`).

### Use cases
- `GetGoals`
- `SaveGoal(GoalRepository, CheckPremiumAccess)`: gated with `PremiumFeature.goals` when the goal is new, count = existing goals.
- `DeleteGoal`
- `AdjustGoalSavings(String id, double delta)`: loads the goal, sets `savedAmount = max(0, saved + delta)`, saves. Returns the updated goal.

Adjusting savings never creates transactions. Goals are envelopes, not accounts. Say so in the form's helper text: `Tracks progress only — doesn't move money between accounts.`

### Presentation
- `GoalsBloc(GetGoals, SaveGoal, DeleteGoal, AdjustGoalSavings, Uuid)`:
  - Events: `GoalsLoadRequested`, `GoalSaveRequested({String? id, required String name, required String targetText, DateTime? targetDate, required int colorValue})`, `GoalDeleteRequested(String id)`, `GoalSavingsAdjusted({required String id, required String amountText, required bool withdraw})`.
  - State: freezed with `status`, `goals`, `errorMessage`, `infoMessage`, `savedCount`, `paywallCount`, `paywallFeature` (same patterns as AccountsBloc + MB-PREMIUM).
  - Validation: name non-empty → `Enter a goal name`; target via `parseAmount` → `Enter a target greater than 0`; adjust amount via `parseAmount` → `Enter an amount greater than 0`; targetDate (if set) not before today → `Choose a date in the future`.
  - When an adjust makes a goal complete (it wasn't before), set `infoMessage` = `Goal reached: <name> 🎉`.
- `GoalsPage` (top-level route):
  - AppBar `Savings goals`, a list of `GoalCard`s, and an extended FAB `Add goal`.
  - Empty → `EmptyState(icon: Icons.flag_outlined, message: 'No goals yet.\nTap Add goal to start saving for something.')`.
  - Tapping a card opens an actions bottom sheet: `Add money`, `Withdraw`, `Edit`.
  - Paywall listener via `openPaywall`; SnackBars for messages.
- `GoalCard`:
  - Rounded 20, a soft tint of `Color(colorValue)`, name, `<saved> of <target>` with `formatCurrency`, a `LinearProgressIndicator` (rounded, goal colour), and the percent.
  - When targetDate is set: `By <formatDate>` plus `Save <monthlyNeeded>/month`.
  - A `Completed` chip (success green) when complete.
- `GoalFormSheet`: name, target amount, optional target date with a clear button, 6 colour swatches (same list as cards), `Save goal`. When editing, a red `Delete` with confirm `Delete this goal?`.
- `GoalAmountSheet`: amount field, `Add money` / `Withdraw` button.
- **Dashboard:**
  - New section under the summary cards: header `Savings goals` with a `See all` TextButton → `/goals`, showing up to 2 incomplete goals as compact `GoalCard`s.
  - When there are no goals, show a single outlined card `Start a savings goal` → `/goals`.
  - Load goals with a `GoalsBloc` added to the dashboard route builder (MultiBlocProvider) and reload when returning from `/goals`.

## Part 2 — Budget alerts (Premium)

### Settings
Add `@Default(true) bool budgetAlertsEnabled` to `AppSettings` and `AppSettingsModel` (with `@JsonKey(defaultValue: true)` so old stored settings load), a `BudgetAlertsToggled(bool)` event, and its handler.

### Notifications (`lib/core/notifications/`)
- `NotificationService` interface: `Future<void> init()`, `Future<bool> requestPermission()`, `Future<void> show({required int id, required String title, required String body})`.
- `LocalNotificationService` uses flutter_local_notifications with an Android channel `budget_alerts`, name `Budget alerts`. `NoopNotificationService` is used on web/unsupported platforms. Register it in DI, call `init()` in `initDependencies`, and swallow failures there.
- It is infrastructure, not a feature: datasource-level, so it throws `AppException` subclasses (`NotificationException`), and the use case below maps the failures.

### Use case `CheckBudgetAlerts` (`lib/features/budget/domain/usecases/`)
- Dependencies: `GetBudgetProgress`, `CheckPremiumAccess`, `GetSettings`, a `BudgetAlertRepository`, and `NotificationService`.
- `call(DateTime date)` returns `Either<Failure, int>` (the number of alerts sent):
  1. Return Right(0) silently when: not premium (`CheckPremiumAccess(PremiumFeature.budgetAlerts, currentCount: 0)` is Left), `budgetAlertsEnabled` is false, or settings fail.
  2. For each `BudgetProgress` in `date`'s month:
     - Threshold `100` when `status == exceeded`, else `80` when `status == warning`, else none.
     - Key `'${budget.id}_${year}_${month}_$threshold'`. Skip if already recorded.
     - Otherwise show the notification and record the key.
     - When 100 fires, also record the 80 key so a later drop-and-rise doesn't send the stale 80% alert.
  3. Text, using the settings currency:
     - 80: title `<category> budget at <percent>%`, body `<formatCurrency(remaining)> left of <formatCurrency(limit)> this month.`
     - 100: title `<category> budget exceeded`, body `You're <formatCurrency(spent - limit)> over your <formatCurrency(limit)> budget.`
     - Notification id = `key.hashCode & 0x7fffffff`.
- `BudgetAlertRepository` + `HiveBudgetAlertDataSource(Box<bool>)` on box `HiveBoxes.budgetAlerts = 'budget_alerts'` (primitive box, no adapter). Methods: `wasSent(key)`, `markSent(key)`. Not part of backups.

### Triggers
- `ExpenseBloc`: after a successful add or edit, call `CheckBudgetAlerts(expense date)` and ignore the result (fire and forget is fine, but await it before emitting success so the bloc doesn't emit after close).
- `ProcessDueRecurring` callers (`main.dart` and `RecurringBloc`): after processing, call `CheckBudgetAlerts(DateTime.now())` and ignore the result.

### Settings UI
- In the first settings Card, under Dark mode: `SwitchListTile(title: Text('Budget alerts'), subtitle: Text('Notify me at 80% and 100% of a budget'))`.
- When the user is free, the switch shows a `PRO` chip and tapping it opens the paywall (`PremiumFeature.budgetAlerts`) instead of toggling.
- When premium and switching on: call `requestPermission()` first (through a small use case `RequestNotificationPermission`). If it's denied, keep the setting off and show a SnackBar `Allow notifications in system settings to get budget alerts.`

## Out of scope
Scheduled bill reminders, notification history, per-budget alert thresholds, linking goals to accounts, goal contributions history.
