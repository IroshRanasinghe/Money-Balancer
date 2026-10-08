# Premium: Entitlement, Free Limits & Paywall — Design & Implementation Brief (MB-PREMIUM)

Approved by the user in chat on 2026-10-09 ("go ahead" on the premium proposal). This is release 1 of premium. MB-GOALS (savings goals and budget alerts) builds on it.

## Goal
Add a premium entitlement with in-app subscriptions through RevenueCat, free-tier limits that are enforced in the domain layer, and a single paywall page. Core tracking stays free and unlimited.

## Product decisions (verbatim)
| Item | Free | Premium |
|---|---|---|
| Income/expenses, dashboard, monthly reports, manual backup/restore | unlimited | unlimited |
| Accounts | 2 | unlimited |
| Saved cards | 2 | unlimited |
| Budgets per month | 5 | unlimited |
| Recurring items | 3 | unlimited |
| Savings goals (MB-GOALS) | 1 | unlimited |
| CSV export | — | ✓ |
| Budget alerts (MB-GOALS) | — | ✓ |

- Limits apply only when **creating** an item. Editing, deleting and using existing items always works. A user who drops back to free keeps everything they already have.
- Packages offered: monthly and yearly, plus a 7-day free trial on yearly, all configured in the RevenueCat dashboard (not in code). The paywall shows whatever packages RevenueCat's current offering returns, with prices from the store.

## Hard rules
- Follow the existing patterns: feature folder, datasources throw `AppException`, only repository impls return `Either`, plain use cases, sealed Equatable events, freezed state, `<feature>_injection.dart` + `<feature>_routes.dart`, BlocProvider at the route or in `app.dart` for app-wide blocs.
- **Gating lives in use cases.** Widgets never compare counts against limits.
- New package allowed: `purchases_flutter` (latest compatible version, added with `flutter pub add`). Apply any platform setup its README requires. `flutter build web --release` must still succeed. If the package doesn't compile on web, use a conditional import so web gets the "store unavailable" datasource.
- RevenueCat API keys come from `--dart-define` (`REVENUECAT_APPLE_KEY`, `REVENUECAT_GOOGLE_KEY`) through `String.fromEnvironment`. Never hard-code keys. Document the run command in README.md (under a short "Premium (RevenueCat)" section).
- No test files. Verification: build_runner, then `flutter analyze` → "No issues found!", then `flutter build web --release`.

## Domain — `lib/features/premium/domain/`
- `PremiumLimits` (in `lib/core/config/constants.dart`): `freeAccounts = 2`, `freeCards = 2`, `freeBudgetsPerMonth = 5`, `freeRecurring = 3`, `freeGoals = 1`.
- `enum PremiumFeature { accounts, cards, budgets, recurring, goals, csvExport, budgetAlerts }` with a `paywallReason` getter, used verbatim:
  - accounts → `Free plan includes 2 accounts.`
  - cards → `Free plan includes 2 saved cards.`
  - budgets → `Free plan includes 5 budgets per month.`
  - recurring → `Free plan includes 3 recurring items.`
  - goals → `Free plan includes 1 savings goal.`
  - csvExport → `CSV export is a Premium feature.`
  - budgetAlerts → `Budget alerts are a Premium feature.`
- freezed `PremiumStatus { @Default(false) bool isPremium, DateTime? expiresAt, String? productId, @Default(false) bool storeAvailable }`.
- freezed `PremiumPackage { String id, String title, String priceString, String period /* 'monthly' | 'yearly' | other */, String? introOffer /* e.g. '7-day free trial' */ }`.
- `PremiumRepository`: `getStatus()`, `getPackages()` → `List<PremiumPackage>`, `purchase(String packageId)` → `PremiumStatus`, `restorePurchases()` → `PremiumStatus`, and `Stream<PremiumStatus> watchStatus()`. The stream is plain (not Either); errors on it are ignored by consumers.
- New failures in `failures.dart`:
  - `PremiumRequiredFailure(PremiumFeature feature)`. `message` = `feature.paywallReason`; include `feature` in props.
  - `PurchaseCancelledFailure` (message `Purchase cancelled.`).
  - `StoreUnavailableFailure` (message `Purchases aren't available on this device.`).
- Use cases: `GetPremiumStatus`, `GetPremiumPackages`, `PurchasePremium(String packageId)`, `RestorePurchases`, and `CheckPremiumAccess`. `CheckPremiumAccess.call(PremiumFeature feature, {required int currentCount})` → `Either<Failure, void>`:
  - status is premium → Right.
  - feature is csvExport or budgetAlerts → Left(PremiumRequiredFailure).
  - otherwise currentCount < the matching free limit → Right, else Left(PremiumRequiredFailure).
  - Failing to read status counts as free (it never blocks with a CacheFailure). Free tier is the safe fallback.

## Data — `lib/features/premium/data/`
- `PremiumDataSource` interface mirrors the repository with plain types/exceptions.
- `RevenueCatPremiumDataSource`:
  - `init()` configures `Purchases` with the platform key (iOS/macOS → apple key, Android → google key). The entitlement identifier is `premium`, as constant `PremiumConfig.entitlementId`.
  - Maps `CustomerInfo.entitlements.active['premium']` to `PremiumStatus`.
  - Maps the current offering's `availablePackages` to `PremiumPackage`.
  - Maps purchase-cancelled errors to `PurchaseCancelledException` and other platform errors to `PurchaseException(message)`. Add these exceptions to `exceptions.dart` and their matching failures to `failures.dart`: `PurchaseFailure(message)`.
  - `watchStatus` comes from `Purchases.addCustomerInfoUpdateListener`.
- `UnavailablePremiumDataSource`: used on web, on desktop, or when the key for the platform is empty. Status is `PremiumStatus(storeAvailable: false)`, packages are empty, and purchase/restore throw `StoreUnavailableException`.
  - **Debug override:** in `kDebugMode` only, this datasource also supports `setDebugPremium(bool)`, held in memory (not persisted) and emitted on `watchStatus`. This lets the paywall and limits be tested without store setup. It must not exist in release behaviour.
- `PremiumRepositoryImpl` converts exceptions to failures.
- DI `registerPremium(GetIt sl)`:
  - Called in the shared-data section **before** the other features that gate, i.e. right after `registerSettings(sl)`.
  - Choose the datasource with `kIsWeb` / `Platform` checks plus whether the key is empty.
  - Call `await datasource.init()` from `initDependencies`. A failed init falls back to the unavailable datasource and must never block startup.
  - Because `init` is async, make `registerPremium` a `Future<void>` and await it.

## Gating existing use cases
For each one, add `CheckPremiumAccess` as a constructor dependency and update DI. The check runs **only when the item is new** (its id isn't in the existing list):
- `SaveAccount`: count = number of accounts.
- `SaveCard`: count = number of cards.
- `SaveBudget`: count = budgets for that budget's month/year.
- `SaveRecurringRule`: count = number of rules.
- `ExportTransactionsCsv`: `CheckPremiumAccess(PremiumFeature.csvExport, currentCount: 0)` is the first step.

Each gated use case loads the list it needs through its own repository. Reuse the existing repository methods; add none unless unavoidable.

## Presentation
- App-wide `PremiumBloc(GetPremiumStatus, GetPremiumPackages, PurchasePremium, RestorePurchases, PremiumRepository-watch via a `WatchPremiumStatus` use case)`, provided in `app.dart` with a `MultiBlocProvider` next to `SettingsBloc` and created with `..add(PremiumStarted())`.
  - Events: `PremiumStarted()` (loads status + packages, subscribes to the stream; cancel the subscription in `close()`), `PremiumPurchaseRequested(String packageId)`, `PremiumRestoreRequested()`, `PremiumDebugToggled(bool)` (debug only; no-op otherwise).
  - State: freezed `PremiumState({@Default(PremiumStatus()) status, @Default(<PremiumPackage>[]) packages, @Default(PremiumBusy.none) busy, String? message, @Default(false) bool packagesLoading})`, with `enum PremiumBusy { none, purchasing, restoring }`.
  - Messages: `Welcome to Premium!` after a successful purchase. After restore: `Purchases restored` when premium, `No previous purchases found` otherwise. Failures show `failure.message`. A cancelled purchase shows no message.
- **Paywall:** `AppRoutes.premium = '/premium'`, a top-level GoRoute, `PremiumPage({PremiumFeature? reason})` with the reason passed via `state.extra`.
  - Top: a gradient hero (primary #2563EB to a darker shade) with `Icons.workspace_premium`, title `Money Balance Premium`, and the reason text when one was passed.
  - Benefit list with check icons: `Unlimited accounts, cards, budgets and goals`, `Unlimited recurring items`, `Budget alerts`, `CSV export`, `Support future features`.
  - Package cards: yearly first and pre-selected, with an intro-offer badge and a `Best value` chip. Selecting a card highlights it.
  - Primary button: `Start free trial` when the selected package has an intro offer, else `Continue`. Then a `Restore purchases` TextButton.
  - Small print: `Subscriptions renew automatically until cancelled in your store account settings.`
  - When `storeAvailable` is false: replace the package cards and buttons with `Purchases aren't available on this device.` In debug builds also show a `SwitchListTile('Debug: premium enabled')` bound to `PremiumDebugToggled`.
  - When already premium: show `You're Premium` with the expiry date (if any) instead of the package cards.
  - BlocListener: SnackBar for `message`. Pop the page automatically after a successful purchase or a restore that makes the user premium.
- **Opening the paywall from limits:**
  - Each affected bloc (`AccountsBloc`, `CardsBloc`, `BudgetBloc`, `RecurringBloc`, `BackupBloc`) adds `@Default(0) int paywallCount` and `PremiumFeature? paywallFeature` to its state.
  - On a `PremiumRequiredFailure` it increments `paywallCount` and sets `paywallFeature` **instead of** setting `errorMessage`.
  - Each page (or form sheet, wherever the save happens) listens with `listenWhen: paywallCount changed`. It closes an open form sheet if needed, then calls `context.push(AppRoutes.premium, extra: feature)`.
  - Use one shared helper so the push code isn't duplicated: `lib/shared/premium_gate.dart`, `void openPaywall(BuildContext context, PremiumFeature feature)`.
- **Settings:**
  - New first Card: when free, `ListTile(leading: Icon(Icons.workspace_premium, color: amber #F59E0B), title: Text('Go Premium'), subtitle: Text('Unlimited accounts, budgets, goals and more'), trailing: chevron)` → `/premium`. When premium: `title: Text('Premium')`, `subtitle: Text('Active')` (or `Active until <formatDate>`), → `/premium`.
  - The CSV tile shows a small `PRO` chip when free.

## Out of scope
Server-side receipt validation (RevenueCat handles it), promo codes, family sharing, a lifetime product, regional pricing (store-side), gating anything not listed above.
