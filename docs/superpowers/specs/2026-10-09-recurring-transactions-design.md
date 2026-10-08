# Recurring Transactions — Design & Implementation Brief (MB-RECURRING)

Approved by the user in chat on 2026-10-09 (roadmap step 2, after MB-ACCOUNTS).

## Goal
Let the user define recurring income/expenses (salary, rent, lease, subscriptions…) once. The app creates the real transactions automatically when they fall due, so the dashboard, budgets and reports stay accurate without manual entry.

## Hard rules
- Follow existing patterns exactly: `lib/features/accounts/` and `lib/features/cards/` are the templates (freezed entity, json_serializable model, hand-written JSON-map Hive adapter, datasource throws `AppException`, repository impl returns `Either<Failure, Entity>`, plain use cases with `call()`, sealed Equatable events, freezed state, BlocProvider at the route builder, `<feature>_injection.dart` + `<feature>_routes.dart`).
- Generated items are ordinary `Transaction`s — nothing else in the app needs to know about rules.
- Generation must be **idempotent**: running it twice (or crashing midway) never creates duplicates.
- Existing stored data must keep loading: the new `Transaction` field is nullable.
- No new packages. No test files. Verification: build_runner + `flutter analyze` → "No issues found!" + `flutter build web --release`.

## Data
Constants: `HiveBoxes.recurring = 'recurring_rules'`, `HiveTypeIds.recurring = 6`, `AppRoutes.recurring = '/recurring'`.

`lib/features/recurring/domain/entities/recurring_rule.dart`:
- `enum RecurrenceFrequency { daily, weekly, monthly, yearly }` (labels `Daily`, `Weekly`, `Monthly`, `Yearly`).
- freezed `RecurringRule { String id, TransactionType type, double amount, String category, String? paymentMethod, String? notes, String? accountId, RecurrenceFrequency frequency, DateTime startDate, DateTime? endDate, @Default(0) int generatedCount, @Default(true) bool isActive, DateTime createdAt }`. `startDate`/`endDate` are date-only (midnight local).
- Getters (needs the freezed private constructor `const RecurringRule._();`): `DateTime get nextDue => occurrenceAt(startDate, frequency, generatedCount);` and `bool get isFinished => endDate != null && nextDue.isAfter(endDate!);`

`lib/features/recurring/domain/recurrence.dart` — pure, no Flutter imports:
- `DateTime occurrenceAt(DateTime start, RecurrenceFrequency f, int index)`: daily → `DateTime(y, m, d + index)`; weekly → `DateTime(y, m, d + 7 * index)`; monthly → month `m + index` with day `min(start.day, daysInMonth)` (so the 31st becomes Feb 28/29 and returns to the 31st where it exists); yearly → year `y + index`, same month, day clamped (Feb 29 → Feb 28). Always computed from `start` + `index`, never by stepping from the previous date, so there is no drift.

`Transaction` entity + `TransactionModel`: add `String? recurringId`.

## Domain / data
- `RecurringRepository`: `getRules()` (oldest `createdAt` first), `saveRule(RecurringRule)` (upsert), `deleteRule(String id)` (NotFoundFailure if absent).
- `RecurringLocalDataSource` / `HiveRecurringLocalDataSource(Box<RecurringRuleModel>)`, `RecurringRuleModel` (enums by name; `type` uses the existing `TransactionType` names), `RecurringRuleModelAdapter`, `RecurringRepositoryImpl`. Register adapter and open box in `HiveSetup`.
- Use cases: `GetRecurringRules`, `SaveRecurringRule`, `DeleteRecurringRule` (already-created transactions are kept), and:
- `ProcessDueRecurring` (`RecurringRepository` + `TransactionRepository`), `Future<Either<Failure, int>> call(DateTime now)` returns how many transactions were created:
  - `today = DateTime(now.year, now.month, now.day)`.
  - For each rule with `isActive`: `index = generatedCount`; while `occurrenceAt(start, f, index)` is not after `today`, and (`endDate == null` or not after `endDate`), and fewer than 1000 iterations for this rule: add a `Transaction(id: '${rule.id}_$index', amount, category, date: occurrence, type, paymentMethod, notes, accountId, recurringId: rule.id, createdAt: now)` using `addTransaction` (Hive `put` upserts by id, which is what makes re-runs safe); `index++`. If `index` changed, save the rule with `generatedCount: index`.
  - Any repository failure → return that `Left` (rules saved so far stay saved).
- `registerRecurring(GetIt sl)` in `lib/features/recurring/recurring_injection.dart`, called in the shared-data section after `registerAccounts(sl)`.

## When generation runs
- `main.dart`: after `initDependencies()` and before `runApp`, `await sl<ProcessDueRecurring>()(DateTime.now());` — ignore the result (failures must not block startup).
- After the user saves a rule (see bloc), so a rule starting today or in the past takes effect immediately.

## Presentation
- `RecurringBloc(GetRecurringRules, SaveRecurringRule, DeleteRecurringRule, ProcessDueRecurring, Uuid)`:
  - events `RecurringLoadRequested()`, `RecurringSaveRequested({String? id, required TransactionType type, required String amountText, required String? category, required RecurrenceFrequency frequency, required DateTime startDate, DateTime? endDate, String? paymentMethod, String? notes, String? accountId})`, `RecurringActiveToggled(String id, bool isActive)`, `RecurringDeleteRequested(String id)`.
  - state freezed `RecurringState({@Default(RecurringStatus.initial) status, @Default(<RecurringRule>[]) rules, String? errorMessage, String? infoMessage, @Default(0) int savedCount})`; `enum RecurringStatus { initial, loading, success, failure }`. Clear both messages at the start of each handler.
  - Validation: amount via `parseAmount` → `Enter an amount greater than 0`; category non-null → `Choose a category`; endDate, if set, not before startDate → `End date must be after the start date`.
  - Editing keeps `id`, `createdAt` and `generatedCount`. If `generatedCount > 0`, the existing `startDate` and `frequency` are kept regardless of the event (the form disables those fields — see below), so already-created occurrences are never re-numbered.
  - After a successful save or toggle-to-active: run `ProcessDueRecurring(DateTime.now())`; if it created n > 0 set `infoMessage` to `Added n transaction(s)` (singular/plural correctly). Then reload rules. Increment `savedCount` on save/delete success.
- `RecurringPage` (top-level GoRoute, `recurringRouteBuilder` provides `RecurringBloc..add(RecurringLoadRequested())` **and** `AccountsBloc..add(AccountsLoadRequested())` for the account picker): AppBar "Recurring"; list of `RecurringRuleTile`s; empty → `EmptyState(icon: Icons.event_repeat, message: 'No recurring items yet.\nTap Add recurring to set one up.')`; FAB extended "Add recurring" → `RecurringFormSheet.show`; tap → edit sheet. BlocListener shows SnackBars for `errorMessage` and `infoMessage`.
- `RecurringRuleTile`: leading `CategoryIcon`, title category, subtitle `Monthly · Next Nov 12, 2026` (or `Ended` when `isFinished`, or `Paused` when inactive), trailing column with signed amount (income success green, expense default) and a `Switch` for `isActive`. Use the existing date formatter in `lib/core/utils/formatters.dart`.
- `RecurringFormSheet.show(context, {RecurringRule? existing})`: SegmentedButton Expense/Income (changing type clears category if not valid for the new type), amount, category dropdown (`AppCategories.expense` / `.income`), frequency dropdown, start date picker, optional end date picker with a clear button, account dropdown (same behaviour as the transaction form: hidden when no accounts; `No account` option), payment method dropdown for expense only (optional, `PaymentMethods.all`), notes, "Save". When editing with `generatedCount > 0`, start date and frequency are disabled with helper text `Already started — create a new item to change the schedule`. When editing, red "Delete" with confirm `Delete this recurring item? Transactions already added are kept.`
- Settings page: add `ListTile(leading: Icon(Icons.event_repeat), title: Text('Recurring'), trailing: Icon(Icons.chevron_right))` → `context.push(AppRoutes.recurring)`, in the same Card as Accounts / My cards.
- `TransactionTile`: when `recurringId != null`, show a small `Icons.repeat` (size 14, muted colour) before the subtitle text.

## Out of scope
Generation while the app stays open across midnight (next launch catches up), notifications, skipping single occurrences, editing all past occurrences.
