# Accounts & Transfers — Design & Implementation Brief (MB-ACCOUNTS)

Approved by the user in chat on 2026-10-09 ("plan the work and go ahead" on the recommended roadmap: accounts + transfers → recurring → backup/export).

## Goal
Let the user keep several money accounts (cash, bank, savings, wallet…), each with an opening balance and a live balance, link income/expenses to an account, and move money between accounts with transfers that are **not** income or expense.

## Hard rules
- Follow existing patterns exactly: `lib/features/cards/` and `lib/features/budget/` are the templates (freezed entity, json_serializable model, hand-written Hive adapter in `lib/core/hive/adapters/` that stores `toJson()` maps, datasource throws `AppException`, repository impl returns `Either<Failure, Entity>`, plain use cases with `call()`, sealed Equatable events, freezed state, BlocProvider at the route builder, `<feature>_injection.dart` + `<feature>_routes.dart`).
- Existing stored data must keep loading: every new `Transaction` field is nullable.
- Transfers are a **separate entity in their own box**. Do NOT add a value to `TransactionType` — reports, budgets and the dashboard assume income/expense only.
- No new packages. No test files (CLAUDE.md). Verification: `dart run build_runner build --delete-conflicting-outputs` + `flutter analyze` → "No issues found!" + `flutter build web --release`.

## Data
Constants: `HiveBoxes.accounts = 'accounts'`, `HiveBoxes.transfers = 'transfers'`, `HiveTypeIds.account = 4`, `HiveTypeIds.transfer = 5`, `AppRoutes.accounts = '/accounts'`, `AppRoutes.accountDetail = '/accounts/detail'` (account id passed via `state.extra` as `String`).

`lib/features/accounts/domain/entities/account.dart`:
- `enum AccountType { cash, bank, savings, wallet, other }` with a label getter or helper (`Cash`, `Bank`, `Savings`, `Wallet`, `Other`) and an icon helper in presentation (`Icons.payments`, `Icons.account_balance`, `Icons.savings`, `Icons.account_balance_wallet`, `Icons.folder`).
- freezed `Account { String id, String name, AccountType type, double openingBalance, int colorValue, DateTime createdAt }`.

`lib/features/accounts/domain/entities/transfer.dart`:
- freezed `Transfer { String id, String fromAccountId, String toAccountId, double amount, DateTime date, String? notes, DateTime createdAt }`.

`lib/features/accounts/domain/entities/account_balance.dart`:
- freezed `AccountBalance { Account account, double balance }`.

`Transaction` entity + `TransactionModel`: add `String? accountId`.

## Domain / data
- `AccountRepository`: `getAccounts()` (oldest `createdAt` first), `saveAccount(Account)` (upsert), `deleteAccount(String id)` (NotFoundFailure if absent), `getTransfers()` (newest `date` first, ties newest `createdAt`), `saveTransfer(Transfer)` (upsert), `deleteTransfer(String id)` (NotFoundFailure if absent).
- Two datasources: `AccountLocalDataSource` / `HiveAccountLocalDataSource(Box<AccountModel>)` and `TransferLocalDataSource` / `HiveTransferLocalDataSource(Box<TransferModel>)`. One `AccountRepositoryImpl` taking both.
- New failure in `lib/core/error/failures.dart`: `AccountInUseFailure` (message `This account has transactions or transfers. Remove them first.`).
- Use cases:
  - `GetAccounts`, `SaveAccount`, `SaveTransfer`, `DeleteTransfer`.
  - `GetAccountBalances()` → `List<AccountBalance>`: balance = openingBalance + Σ income with that accountId − Σ expense with that accountId + Σ transfers in − Σ transfers out. Consumes `AccountRepository` + `TransactionRepository` (fold pattern like `GetCardSpending`).
  - `DeleteAccount(String id)`: fails with `AccountInUseFailure` if any transaction has `accountId == id` or any transfer references it; otherwise deletes.
  - `GetAccountActivity(String accountId)` → `List<AccountActivity>` where `AccountActivity` is a freezed union or simple class `{ DateTime date, DateTime createdAt, String title, double signedAmount, Transaction? transaction, Transfer? transfer }`, newest first. Title: transaction category, or `Transfer to <name>` / `Transfer from <name>`.
- `HiveSetup`: register both adapters, open both boxes.
- `registerAccounts(GetIt sl)` in `lib/features/accounts/accounts_injection.dart`, called from `injection_container.dart` right after `registerCards(sl)` (shared data section).

## Dashboard total balance
`GetDashboardSummary` now also takes `AccountRepository`: `totalBalance` = Σ account openingBalance + Σ income − Σ expense (transfers net to zero, so they are ignored). If accounts fail to load, fall back to the old income − expense figure. Update its DI registration. Make `BalanceCard` tappable → `context.push(AppRoutes.accounts)` (add an `onTap` param; keep the look, add a small `chevron_right` or "Accounts" hint).

## Presentation
- `AccountsBloc(GetAccountBalances, SaveAccount, DeleteAccount, SaveTransfer, DeleteTransfer, Uuid)`:
  - events `AccountsLoadRequested()`, `AccountSaveRequested({String? id, required String name, required AccountType type, required String openingBalanceText, required int colorValue, DateTime? createdAt})`, `AccountDeleteRequested(String id)`, `TransferSaveRequested({String? id, required String? fromAccountId, required String? toAccountId, required String amountText, required DateTime date, String? notes, DateTime? createdAt})`, `TransferDeleteRequested(String id)`.
  - state freezed `AccountsState({@Default(AccountsStatus.initial) status, @Default(<AccountBalance>[]) items, String? errorMessage, @Default(0) int savedCount})`; `enum AccountsStatus { initial, loading, success, failure }`. Reload balances after every successful save/delete. Clear `errorMessage` at the start of each handler. Increment `savedCount` on each successful save/delete so sheets can close via `listenWhen`.
  - Validation (in bloc, mirrored in form validators): name trimmed non-empty → `Enter an account name`; opening balance parses as a double (may be 0 or negative; empty = 0) → `Enter a valid amount`; transfer amount > 0 → `Enter an amount greater than 0`; both accounts chosen → `Choose both accounts`; from ≠ to → `Choose two different accounts`. Amount parsing: transfer amounts use the existing `parseAmount` in `lib/core/utils/formatters.dart`. `parseAmount` rejects zero and negatives, so add next to it `double? parseSignedAmount(String input)` for the opening balance: empty → 0, an optional leading `-`, then the same rules as `parseAmount` (but 0 allowed); returns null for invalid input.
  - Delete failures show `failure.message` via errorMessage.
- `AccountsPage` (top-level GoRoute `AppRoutes.accounts`, `accountsRouteBuilder` provides `AccountsBloc..add(AccountsLoadRequested())`): AppBar "Accounts" with an action `IconButton(Icons.swap_horiz, tooltip: 'Transfer')` (disabled with SnackBar hint `Add two accounts to make a transfer` when fewer than 2 accounts); a header card showing "Total" = Σ balances; list of `AccountTile`s; empty → `EmptyState(icon: Icons.account_balance_wallet_outlined, message: 'No accounts yet.\nTap Add account to create one.')`; FAB extended "Add account" → `AccountFormSheet.show`; tap tile → `context.push(AppRoutes.accountDetail, extra: id)` then reload on return; long-press or trailing edit icon → edit sheet. BlocListener SnackBar for errorMessage.
- `AccountTile`: leading circle avatar in `Color(colorValue)` with type icon, title name, subtitle type label, trailing balance formatted with `formatCurrency` and the settings currency (negative in danger red).
- `AccountFormSheet.show(context, {Account? existing})`: name, SegmentedButton or dropdown for type, opening balance field (signed decimal allowed), 6 colour swatches (same list as cards), "Save account"; when editing a red "Delete" with confirm dialog `Delete this account?`.
- `TransferFormSheet.show(context, {required List<Account> accounts, Transfer? existing})`: From dropdown, To dropdown, amount, date picker, notes, "Save transfer"; when editing, red "Delete".
- `AccountDetailPage` (route `AppRoutes.accountDetail`, provides its own `AccountDetailBloc(GetAccountBalances, GetAccountActivity)` or reuse `AccountsBloc` + a `GetAccountActivity` call — pick the simplest that keeps layers clean): header with name, type, balance; list of activity rows (transactions use `TransactionTile`; transfers use a ListTile with `Icons.swap_horiz`, title, signed amount). Tap a transfer → `TransferFormSheet` edit (needs the accounts list + the AccountsBloc for save/delete); tap a transaction → the existing edit route for its type. Empty → `EmptyState(icon: Icons.history, message: 'No activity yet.')`.
- Settings page: add `ListTile(leading: Icon(Icons.account_balance_wallet), title: Text('Accounts'), trailing: Icon(Icons.chevron_right))` → `context.push(AppRoutes.accounts)`, in the same Card as "My cards" (above it, with a Divider).

## Transaction integration
- Expense and income add/edit route builders also provide `AccountsBloc..add(AccountsLoadRequested())` (MultiBlocProvider).
- `TransactionFormData` gets `String? accountId`. `TransactionForm` gets `List<Account> accounts = const []` and `bool accountsLoading = false`. When `accounts` is non-empty, show a `DropdownButtonFormField<String?>` "Account" (item `null` → "No account" plus one per account) for both income and expense. If editing and `initial.accountId` is not in `accounts`, add an item `(removed account)` so the value stays valid. Hidden while loading; hidden when there are no accounts.
- `AddExpense` / `AddIncome` gain optional `accountId`; edit paths pass it via `copyWith`.

## Out of scope
Per-account currencies, reconciliation, account archiving, transfer fees, reports per account.
