# Bank Cards — Design & Implementation Brief

Approved by the user in chat on 2026-10-08. Data: safe summary only. Usage: pick a card on expenses.

## Goal
Let the user save bank cards (a safe summary — never the full card number or CVV) and pick which card paid for an expense whose payment method is "Card". Each card shows this month's spending.

## Hard rules
- Never ask for, store or log a full card number or CVV. The form asks for the **last 4 digits only**.
- Follow existing patterns exactly: `lib/features/budget/` is the template (freezed entity, json_serializable model, hand-written Hive adapter in `lib/core/hive/adapters/`, datasource throws `AppException`, repository impl returns `Either<Failure, Entity>`, plain use cases with `call()`, sealed Equatable events, freezed state, BlocProvider at the route builder, `<feature>_injection.dart` + `<feature>_routes.dart`).
- Existing stored transactions must keep loading: new Transaction fields are nullable.
- No new packages. No test files (CLAUDE.md). Verification: `dart run build_runner build --delete-conflicting-outputs` + `flutter analyze` → "No issues found!" + `flutter build web --release`.

## Data
`lib/features/cards/domain/entities/bank_card.dart`:
- `enum CardType { debit, credit }`, `enum CardNetwork { visa, mastercard, amex, other }`
- freezed `BankCard { String id, String nickname, String bankName, CardType type, CardNetwork network, String last4, int expiryMonth, int expiryYear, int colorValue, DateTime createdAt }` (bankName may be empty)
- getter `bool isExpiredAt(DateTime now) => !now.isBefore(DateTime(expiryYear, expiryMonth + 1));` (valid through the last day of the expiry month)

`lib/features/cards/domain/entities/card_spending.dart`: freezed `CardSpending { BankCard card, double spent }`.

Transaction (`lib/features/transactions/domain/entities/transaction.dart` + `data/models/transaction_model.dart`): add `String? cardId` and `String? cardLast4` (snapshot so history survives card deletion). Both null unless paymentMethod == 'Card'.

Constants: `HiveBoxes.cards = 'cards'`, `HiveTypeIds.card = 3`, `AppRoutes.cards = '/cards'`.

## Domain / data
- `CardRepository`: `getCards()` (oldest `createdAt` first), `saveCard(BankCard)` (upsert by id), `deleteCard(String id)` (NotFoundFailure if absent).
- Use cases: `GetCards`, `SaveCard`, `DeleteCard`, `GetCardSpending({required int month, required int year})` → `List<CardSpending>` = every card with the sum of **expense** transactions whose `cardId == card.id` and whose date is in that month/year (same fold pattern as `GetBudgetProgress`; consumes `CardRepository` + `TransactionRepository`).
- `CardModel` (json_serializable; enums by name), `CardModelAdapter` (typeId `HiveTypeIds.card`), `CardLocalDataSource` / `HiveCardLocalDataSource(Box<CardModel>)`, `CardRepositoryImpl`.
- `HiveSetup`: register `CardModelAdapter`, open `Box<CardModel>(HiveBoxes.cards)`.
- `registerCards(GetIt sl)` in `lib/features/cards/cards_injection.dart`, called from `injection_container.dart` right after `registerTransactions(sl)`.

## Presentation
- `CardsBloc(GetCardSpending, SaveCard, DeleteCard, Uuid)`: events `CardsLoadRequested()`, `CardSaveRequested({String? id, required String nickname, required String bankName, required CardType type, required CardNetwork network, required String last4, required int expiryMonth, required int expiryYear, required int colorValue})`, `CardDeleteRequested(String id)`. State freezed `CardsState({@Default(CardsStatus.initial) status, @Default(<CardSpending>[]) items, String? errorMessage})`, `enum CardsStatus { initial, loading, success, failure }`. Load uses the current month (`DateTime.now()`). Clear `errorMessage` at the start of each handler. Validation in the bloc (and mirrored in form validators):
  - nickname trimmed non-empty → else `Enter a card nickname`
  - last4 matches `^\d{4}$` → else `Enter the last 4 digits`
  - expiryMonth 1–12 and expiryYear between current year and current year + 20, and the card not already expired → else `Enter a valid expiry date`
  - On save keep the existing `createdAt` when editing (pass the existing card's createdAt through; new cards use `DateTime.now()`).
- `CardsPage` (route `AppRoutes.cards`, top-level GoRoute like the add/edit routes, `cardsRouteBuilder` provides `CardsBloc..add(CardsLoadRequested())`): AppBar "My cards"; list of `BankCardTile`s (12px gaps); empty → `EmptyState(icon: Icons.credit_card_off, message: 'No cards saved yet.\nTap Add card to save one.')`; FAB extended "Add card" → `CardFormSheet.show`; tap a tile → edit sheet; BlocListener SnackBar for errorMessage (not on failure status).
- `BankCardTile({required CardSpending item, required String currencyCode, VoidCallback? onTap})`: rounded 20, gradient from `Color(colorValue)` to a darker shade, white text: network label (VISA / MASTERCARD / AMEX / CARD) + type (Debit/Credit) top row, nickname + bankName, `•••• 1234`, `Expires MM/YY`, and "This month: <formatCurrency(spent)>". "Expired" chip when `isExpiredAt(DateTime.now())`.
- `CardFormSheet.show(context, {BankCard? existing})`: bottom sheet (BlocProvider.value of the page's bloc) with nickname, bank name (optional), SegmentedButton Debit/Credit, network dropdown, last 4 field (`keyboardType: number`, `maxLength: 4`, digits-only input formatter, `obscureText: false`), expiry month dropdown (01–12) + year dropdown (current year … +20), 6 colour swatches `[0xFF2563EB, 0xFF0F172A, 0xFF7C3AED, 0xFF059669, 0xFFDC2626, 0xFFD97706]` (default first), "Save card" button; when editing a red "Delete" with confirm dialog "Delete this card? Expenses already linked keep showing ••••1234."
- Settings page: add a `ListTile(leading: Icon(Icons.credit_card), title: Text('My cards'), trailing: Icon(Icons.chevron_right))` → `context.push(AppRoutes.cards)`.

## Expense integration
- Expense add/edit route builders provide **both** `ExpenseBloc` and `CardsBloc..add(CardsLoadRequested())` (MultiBlocProvider). Income is unchanged.
- `TransactionFormData` gets `String? cardId`, `String? cardLast4`. `TransactionForm` gets an optional `List<BankCard> cards = const []` and `VoidCallback? onAddCard`; the expense page passes them from a `BlocBuilder<CardsBloc, CardsState>`.
- When `showPaymentMethod` and the selected payment method is `'Card'`, show a `DropdownButtonFormField<String?>` "Which card?" with item `null` → "No specific card" plus one per card "`nickname` •••• `last4`". If editing and `initial.cardId` is not in `cards` (deleted card), add an item for it labelled "•••• `initial.cardLast4` (removed)" so the value is valid and preserved. If `cards` is empty, show a `TextButton.icon('Add a card')` calling `onAddCard` instead of the dropdown. The expense page's `onAddCard`: `await context.push(AppRoutes.cards)` then re-add `CardsLoadRequested` if mounted.
- On submit: cardId/cardLast4 only when payment method is 'Card' (else both null). `ExpenseBloc` passes them to `AddExpense` (new optional `cardId`, `cardLast4` params) and to `initial.copyWith(...)` on edit.
- `TransactionTile` subtitle: when `paymentMethod == 'Card' && cardLast4 != null` show `Card •••• <last4>` instead of `Card`.

## Out of scope
Credit limits, full number storage, card payments, per-card reports beyond this month's total.
