# Backup, Restore & CSV Export — Design & Implementation Brief (MB-BACKUP)

Approved by the user in chat on 2026-10-09 (roadmap step 3, after MB-ACCOUNTS and MB-RECURRING). Also removes the Language setting, which today offers only English and changes nothing.

## Goal
1. **Back up** all app data to a single JSON file the user can save or send anywhere (share sheet / download).
2. **Restore** from such a file, replacing the data on this device.
3. **Export transactions as CSV** for spreadsheets.

## Hard rules
- **Card numbers are never exported.** They live in secure storage and stay out of backups and CSVs. CVVs are never stored anywhere.
- Restore is all-or-nothing: parse and validate the whole file **before** touching any box. A bad file leaves existing data untouched.
- Follow existing patterns (feature folder, datasources throw `AppException`, repository returns `Either`, plain use cases, sealed Equatable events, freezed state, `<feature>_injection.dart`).
- New packages allowed for this task only: `share_plus` and `file_picker` (latest versions compatible with this SDK, via `flutter pub add`). Apply the platform setup their READMEs require for the installed versions. On macOS, add `com.apple.security.files.user-selected.read-only` = true to both `macos/Runner/DebugProfile.entitlements` and `Release.entitlements`.
- No test files. Verification: build_runner + `flutter analyze` → "No issues found!" + `flutter build web --release`.

## Backup file format
```json
{
  "app": "money_balance",
  "version": 1,
  "exportedAt": "<ISO-8601>",
  "settings": { ...AppSettingsModel.toJson() } | null,
  "transactions": [ ...TransactionModel.toJson() ],
  "budgets": [ ... ],
  "cards": [ ... ],
  "accounts": [ ... ],
  "transfers": [ ... ],
  "recurringRules": [ ... ]
}
```
- File name: `money_balance_backup_YYYY-MM-DD.json` (export date). Pretty-printed with 2-space indent.
- On restore: `app` must equal `money_balance` and `version` must be an int ≤ 1, else `InvalidBackupFailure`. A missing list key is treated as an empty list (so later versions can add collections); a missing/null `settings` keeps the current settings.

## Data layer — `lib/features/backup/data/`
- `BackupLocalDataSource` / `HiveBackupLocalDataSource` constructed with the seven typed boxes (`Box<AppSettingsModel>`, `Box<TransactionModel>`, `Box<BudgetModel>`, `Box<CardModel>`, `Box<AccountModel>`, `Box<TransferModel>`, `Box<RecurringRuleModel>`) plus `CardNumberSecureDataSource`:
  - `Map<String, dynamic> exportAll(DateTime now)` → the map above.
  - `Future<BackupCounts> replaceAll(Map<String, dynamic> data)`:
    1. Validate header (throw `InvalidBackupException(message)`).
    2. Parse every list with each model's `fromJson` into typed lists. Any error → `InvalidBackupException('This backup file is damaged or incomplete.')`.
    3. Remember the current card ids; clear each box and `putAll` keyed by `id`. Settings go under the same key the settings datasource uses (`'current'`; expose that key as a public constant on `HiveSettingsLocalDataSource` rather than duplicating the string).
    4. For every card id that existed before but not after, delete its secure card number (ignore failures).
    5. Return counts.
  - Add `InvalidBackupException` to `lib/core/error/exceptions.dart` and `InvalidBackupFailure` to `failures.dart`.
- `BackupFileDataSource` / `PlatformBackupFileDataSource`:
  - `Future<void> shareFile({required String fileName, required String content, required String mimeType})` → `SharePlus.instance.share(ShareParams(files: [XFile.fromData(utf8.encode(content), mimeType: mimeType, name: fileName)], fileNameOverrides: [fileName]))` (adapt to the installed share_plus API). Works on web as a download.
  - `Future<String?> pickTextFile({required List<String> extensions})` → `FilePicker` with `withData: true`; decode the bytes as UTF-8 (do not use paths — web has none). `null` when cancelled.
  - Errors → `FileException` (new) → `FileFailure` (new, message `Could not open or save the file.`).
- `BackupRepository` + `BackupRepositoryImpl`: `createBackup(DateTime now)` → `Either<Failure, String>` (JSON text), `restoreBackup(String json)` → `Either<Failure, BackupCounts>` (a JSON decode error → `InvalidBackupFailure('This is not a valid backup file.')`), `shareFile(...)` → `Either<Failure, void>`, `pickTextFile(...)` → `Either<Failure, String?>`.

## Domain — `lib/features/backup/domain/`
- `BackupCounts` freezed `{ int transactions, int budgets, int cards, int accounts, int transfers, int recurringRules }`.
- `lib/features/backup/domain/transactions_csv.dart` — pure `String buildTransactionsCsv(List<Transaction> txs, Map<String, String> accountNames)`:
  - Header `Date,Type,Category,Amount,Payment method,Card,Account,Notes`.
  - Rows in the given order (repository order = newest first). Date `yyyy-MM-dd`; Type `Expense`/`Income`; Amount `toStringAsFixed(2)` without currency symbol; Card `•••• 1234` when `cardLast4 != null`; Account name from the map (empty if none/removed).
  - RFC 4180: quote a field when it contains `,`, `"`, `\r` or `\n`; double inner quotes. Lines end with `\r\n`.
- Use cases:
  - `ExportBackup(BackupRepository)` — `call(DateTime now)`: create JSON, share as `application/json`.
  - `RestoreBackupFromFile(BackupRepository)` — `call()`: pick a `.json` file; `Right(null)` when cancelled; else `restoreBackup`.
  - `ExportTransactionsCsv(TransactionRepository, AccountRepository, BackupRepository)` — `call(DateTime now)`: build the CSV, share as `money_balance_transactions_YYYY-MM-DD.csv` with `text/csv`. If there are no transactions → `ValidationFailure('No transactions to export yet.')`.
- `registerBackup(GetIt sl)` in `lib/features/backup/backup_injection.dart`, called in the Features section of `injection_container.dart`. Boxes come from `Hive.box<...>(HiveBoxes.x)` as the other features do.

## Presentation
- `BackupBloc(ExportBackup, RestoreBackupFromFile, ExportTransactionsCsv)`: events `BackupExportRequested()`, `BackupRestoreRequested()`, `CsvExportRequested()`. State freezed `BackupState({@Default(BackupStatus.idle) status, String? message, @Default(0) int restoredCount})` with `enum BackupStatus { idle, working, success, failure }`. Ignore new events while `working`. Messages: `Backup ready to save`, `Transactions exported`, `Restored N transactions` (and the failure's message on failure). A cancelled pick returns to `idle` with no message. Increment `restoredCount` on each successful restore.
- `settingsRouteBuilder` now provides `BackupBloc` with a `BlocProvider` (SettingsBloc stays app-wide); update its doc comment.
- Settings page, new Card titled by a small section header "Data":
  - `ListTile(leading: Icon(Icons.table_chart_outlined), title: Text('Export transactions (CSV)'))`
  - `ListTile(leading: Icon(Icons.backup_outlined), title: Text('Back up data'), subtitle: Text('Card numbers are not included'))`
  - `ListTile(leading: Icon(Icons.restore), title: Text('Restore from backup'))` → confirm dialog `Restore from backup?` / `This replaces all data on this device with the backup. This can't be undone.` / `Cancel` / `Restore` (red).
  - While `working`, disable the three tiles and show a small `CircularProgressIndicator` as the trailing widget of the active one (or a LinearProgressIndicator at the top of the card — simplest).
  - BlocListener: SnackBar for `message`; when `restoredCount` increases, dispatch `SettingsLoadRequested()` on the app-wide `SettingsBloc` so currency/dark mode refresh.
- **Language row:** remove it from the Settings page, and remove the `LanguageChanged` event and its handler. Keep the `language` field in `AppSettings`/`AppSettingsModel` so stored settings and backups stay compatible.

## Out of scope
Cloud sync, automatic scheduled backups, encrypted backups, CSV import, merging a backup into existing data.
