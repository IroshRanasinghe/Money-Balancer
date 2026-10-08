# Money Balance MVP Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the Money Balance personal-finance POC: dashboard, expense & income entry, transaction list, budgets, reports and settings — offline-first on Hive.

**Architecture:** Feature-first Clean Architecture (presentation → domain ← data). Each feature exposes `register<Feature>(GetIt)` in `lib/features/<f>/<f>_injection.dart` and route builder functions in `lib/features/<f>/<f>_routes.dart`; `core/di/injection_container.dart` and `core/config/router.dart` only call those. This lets Tasks 3–6 run in parallel without touching shared files. The `Transaction` entity/repository is owned by the `transactions` feature and consumed by expense, income, dashboard, budget and reports.

**Tech Stack:** Flutter 3.41 / Dart 3.11, Material 3, flutter_bloc 9, get_it 9 (manual registration), go_router 17, hive 2 + hive_flutter (hand-written TypeAdapters), freezed 3 + json_serializable 6, dartz (Either), intl 0.20, fl_chart 1.x, uuid 4, equatable.

**Spec:** Approved artifact "Money Balance - Architecture Plan" — https://claude.ai/artifact/WtMiBj3JusD1GkUJ83ciYQ (folder structure, layers, DI lifetimes, BLoC list, Hive boxes, entities, six core features). Project rules: `CLAUDE.md`.

## Global Constraints

- Folder layout per spec: `lib/core/{config,di,utils,hive}`, `lib/features/{dashboard,expense,income,budget,reports}/{presentation,domain,data}` (+ `transactions`, `settings` features, see rulings). Data-layer repository impls live in `data/repositories/` (spec naming).
- Hive boxes exactly: `transactions` (Transaction), `budgets` (Budget), `app_settings` (AppSettings).
- Entities exactly (fields/types): Transaction {String id, double amount, String category, DateTime date, type expense|income, String? paymentMethod, String? notes, DateTime createdAt}; Budget {String id, String category, double limit, int month, int year, bool isActive}; AppSettings {String currency, bool darkMode, String language}.
- `type` is persisted as the strings `'expense'` / `'income'` (Dart enum `TransactionType` serialised by name).
- DI lifetimes: data sources & repositories `registerLazySingleton`; use cases `registerFactory`; BLoCs `registerFactory` (or `registerFactoryParam`).
- BLoCs per spec: DashboardBloc, ExpenseBloc, IncomeBloc, BudgetBloc, ReportsBloc, TransactionBloc (+ SettingsBloc).
- Repositories return `Future<Either<Failure, T>>` and return entities, never models. Data sources throw `AppException` subclasses; only repository impls catch and convert to `Failure`. Use cases are plain classes with `call()` that delegate to repositories (they may `map`/`fold` a repository result, never construct `Left` for business validation — validation lives in the BLoC or repository impl as specified per task).
- Page BLoCs are provided by `BlocProvider` inside the route builder function, never via `sl` inside `build()`. Exception: `SettingsBloc` is app-wide, provided once in `lib/app.dart`.
- Entities and BLoC states use freezed 3 syntax: `@freezed abstract class X with _$X { const factory X({...}) = _X; }` (add `const X._();` when adding getters). Events are `sealed class` hierarchies extending `Equatable`.
- Colour palette: Primary `#2563EB`, Success `#22C55E`, Warning `#F59E0B`, Danger `#EF4444`, Background `#F8FAFC`, Cards `#FFFFFF`. Dark mode supported.
- Money is displayed only through `formatCurrency(amount, currencyCode)` with the currency from `SettingsBloc`. Amount input is parsed only through `parseAmount`.
- No test files (CLAUDE.md: tests only when explicitly requested). Verification for every task = `dart run build_runner build --delete-conflicting-outputs` succeeds AND `flutter analyze` prints `No issues found!`.
- Generated `*.g.dart` / `*.freezed.dart` files are committed.
- Commits end with `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`.

## Review Focus

1. Amount input like `12,5`, `abc`, `0`, `-5`, empty, `1e400` — rejected with an inline message, never saved, never crashes (`parseAmount` in Task 1; used by Tasks 3 & 5).
2. Empty database (fresh install) — dashboard shows 0.00 totals and an empty state; reports pie/bar charts render an empty state instead of crashing on zero totals / zero maxY (Tasks 4, 6).
3. Budget with spent > limit or spent = 0 — no NaN/Infinity, progress bar clamps to 100%, status shows "exceeded" (Task 5).
4. Month boundaries — a transaction dated the last day of a month at 23:59 counts in that month; navigating Dec → Jan rolls the year; the 6-month trend spans year boundaries correctly (Tasks 1 `addMonths`, 4, 5, 6).
5. Editing a transaction keeps its `id` and `createdAt` (no duplicate created); deleting an id that no longer exists surfaces "Item not found." instead of crashing (Tasks 2, 3).

## Execution Waves

- Wave A (sequential): Task 1 → Task 2.
- Wave B (parallel, one git worktree per task, branched from the head after Task 2): Tasks 3, 4, 5, 6. Each touches only its own feature folder(s) plus the files explicitly listed in its **Files** block.
- Wave C: merge Wave B branches, then Task 7.

---

### Task 1: Foundation — dependencies, core, app shell, settings feature

**Files:**
- Modify: `pubspec.yaml`, `lib/main.dart`
- Delete: `test/widget_test.dart` (tests removed counter app)
- Create: `lib/app.dart`
- Create: `lib/core/config/constants.dart`, `lib/core/config/theme.dart`, `lib/core/config/router.dart`
- Create: `lib/core/error/failures.dart`, `lib/core/error/exceptions.dart`
- Create: `lib/core/utils/formatters.dart`, `lib/core/utils/extensions.dart`
- Create: `lib/core/hive/hive_setup.dart`, `lib/core/hive/adapters/app_settings_model_adapter.dart`
- Create: `lib/core/di/injection_container.dart`
- Create: `lib/core/widgets/app_shell.dart`, `lib/core/widgets/app_bottom_nav.dart`, `lib/core/widgets/placeholder_page.dart`
- Create: `lib/shared/widgets/month_selector.dart`
- Create: settings feature: `lib/features/settings/{settings_injection.dart, settings_routes.dart}`, `domain/entities/app_settings.dart`, `domain/repositories/settings_repository.dart`, `domain/usecases/{get_settings.dart, save_settings.dart}`, `data/models/app_settings_model.dart`, `data/datasources/settings_local_datasource.dart`, `data/repositories/settings_repository_impl.dart`, `presentation/bloc/{settings_bloc.dart, settings_event.dart, settings_state.dart}`, `presentation/pages/settings_page.dart`
- Create stubs (one `_injection.dart` + one `_routes.dart` each) for: `transactions`, `expense`, `income`, `dashboard`, `budget`, `reports`

**Interfaces:**
- Produces (exact names used by later tasks):
  - `AppRoutes.dashboard='/'`, `.transactions='/transactions'`, `.budget='/budget'`, `.reports='/reports'`, `.settings='/settings'`, `.addExpense='/expense/add'`, `.editExpense='/expense/edit'`, `.addIncome='/income/add'`, `.editIncome='/income/edit'`
  - `HiveBoxes.transactions/.budgets/.settings`, `HiveTypeIds.transaction=0/.budget=1/.settings=2`
  - `AppCategories.expense`, `AppCategories.income`, `PaymentMethods.all`, `SupportedCurrencies.codes`
  - `AppColors.*`, `AppTheme.light`, `AppTheme.dark`
  - `Failure(message)`, `CacheFailure`, `NotFoundFailure`, `ValidationFailure`; `AppException`, `CacheException`, `NotFoundException`
  - `String formatCurrency(double amount, String currencyCode)`, `String formatDate(DateTime)`, `String formatMonthYear(int month, int year)`, `String formatShortMonth(int month, int year)`, `double? parseAmount(String input)`
  - `extension DateTimeX on DateTime { bool isSameMonth(DateTime other); DateTime addMonths(int delta); }`
  - `final GetIt sl`, `Future<void> initDependencies()`
  - `void registerX(GetIt sl)` per feature; route builders `Widget xRouteBuilder(BuildContext context, GoRouterState state)`
  - `MonthSelector({required int month, required int year, required ValueChanged<int> onShift})`
  - `SettingsBloc` with state `SettingsState.settings` (`AppSettings`) — pages read currency via `context.select((SettingsBloc b) => b.state.settings.currency)`

- [ ] **Step 1: Add dependencies**

Run in the project root:
```bash
flutter pub add flutter_bloc:^9.1.1 equatable:^2.1.0 get_it:^9.3.0 go_router:^17.5.0 hive:^2.2.3 hive_flutter:^1.1.0 freezed_annotation:^3.1.0 json_annotation:^4.12.0 intl:^0.20.3 fl_chart:^1.2.0 dartz:^0.10.1 uuid:^4.6.0
flutter pub add -d build_runner:^2.15.1 freezed:^3.2.5 json_serializable:^6.14.1
```
Set `description: "Money Balance — personal finance manager (POC)."` in `pubspec.yaml`. Delete `test/widget_test.dart`.

- [ ] **Step 2: Core error types**

`lib/core/error/failures.dart`:
```dart
import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Could not access local storage.']);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Item not found.']);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}
```

`lib/core/error/exceptions.dart`:
```dart
class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

class CacheException extends AppException {
  const CacheException([super.message = 'Local storage error.']);
}

class NotFoundException extends AppException {
  const NotFoundException([super.message = 'Item not found.']);
}
```

- [ ] **Step 3: Constants, theme, formatters, extensions**

`lib/core/config/constants.dart`:
```dart
class AppRoutes {
  const AppRoutes._();

  static const dashboard = '/';
  static const transactions = '/transactions';
  static const budget = '/budget';
  static const reports = '/reports';
  static const settings = '/settings';
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
}

class HiveTypeIds {
  const HiveTypeIds._();

  static const transaction = 0;
  static const budget = 1;
  static const settings = 2;
}

class AppCategories {
  const AppCategories._();

  static const expense = [
    'Food',
    'Transport',
    'Shopping',
    'Bills',
    'Entertainment',
    'Health',
    'Education',
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
```

`lib/core/config/theme.dart`:
```dart
import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  static const primary = Color(0xFF2563EB);
  static const success = Color(0xFF22C55E);
  static const warning = Color(0xFFF59E0B);
  static const danger = Color(0xFFEF4444);
  static const background = Color(0xFFF8FAFC);
  static const card = Color(0xFFFFFFFF);
  static const darkBackground = Color(0xFF0F172A);
  static const darkCard = Color(0xFF1E293B);
}

class AppTheme {
  const AppTheme._();

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: brightness,
      primary: AppColors.primary,
      error: AppColors.danger,
      surface: isDark ? AppColors.darkCard : AppColors.card,
    );
    final radius = BorderRadius.circular(16);
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor:
          isDark ? AppColors.darkBackground : AppColors.background,
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.5)),
        ),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: scheme.onSurface,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: AppColors.primary.withValues(alpha: 0.15),
      ),
    );
  }
}
```

`lib/core/utils/formatters.dart`:
```dart
import 'package:intl/intl.dart';

String formatCurrency(double amount, String currencyCode) =>
    NumberFormat.simpleCurrency(name: currencyCode).format(amount);

String formatDate(DateTime date) => DateFormat('MMM d, yyyy').format(date);

String formatMonthYear(int month, int year) =>
    DateFormat('MMMM yyyy').format(DateTime(year, month));

String formatShortMonth(int month, int year) =>
    DateFormat('MMM').format(DateTime(year, month));

/// Parses user-entered money. Accepts `12.5` and `12,5`.
/// Returns null for empty, non-numeric, non-finite, zero or negative input.
double? parseAmount(String input) {
  final normalized = input.trim().replaceAll(',', '.');
  final value = double.tryParse(normalized);
  if (value == null || !value.isFinite || value <= 0) return null;
  return value;
}
```

`lib/core/utils/extensions.dart`:
```dart
extension DateTimeX on DateTime {
  bool isSameMonth(DateTime other) =>
      year == other.year && month == other.month;

  /// First day of the month [delta] months away; rolls years correctly.
  DateTime addMonths(int delta) => DateTime(year, month + delta);
}
```

- [ ] **Step 4: Settings domain + data**

`lib/features/settings/domain/entities/app_settings.dart`:
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_settings.freezed.dart';

@freezed
abstract class AppSettings with _$AppSettings {
  const factory AppSettings({
    @Default('USD') String currency,
    @Default(false) bool darkMode,
    @Default('en') String language,
  }) = _AppSettings;
}
```

`lib/features/settings/domain/repositories/settings_repository.dart`:
```dart
import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/app_settings.dart';

abstract class SettingsRepository {
  /// Returns stored settings, or defaults when nothing is stored yet.
  Future<Either<Failure, AppSettings>> getSettings();

  Future<Either<Failure, void>> saveSettings(AppSettings settings);
}
```

`lib/features/settings/domain/usecases/get_settings.dart`:
```dart
import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/app_settings.dart';
import '../repositories/settings_repository.dart';

class GetSettings {
  const GetSettings(this._repository);

  final SettingsRepository _repository;

  Future<Either<Failure, AppSettings>> call() => _repository.getSettings();
}
```

`lib/features/settings/domain/usecases/save_settings.dart`:
```dart
import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/app_settings.dart';
import '../repositories/settings_repository.dart';

class SaveSettings {
  const SaveSettings(this._repository);

  final SettingsRepository _repository;

  Future<Either<Failure, void>> call(AppSettings settings) =>
      _repository.saveSettings(settings);
}
```

`lib/features/settings/data/models/app_settings_model.dart`:
```dart
import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/app_settings.dart';

part 'app_settings_model.g.dart';

@JsonSerializable()
class AppSettingsModel {
  const AppSettingsModel({
    required this.currency,
    required this.darkMode,
    required this.language,
  });

  factory AppSettingsModel.fromJson(Map<String, dynamic> json) =>
      _$AppSettingsModelFromJson(json);

  factory AppSettingsModel.fromEntity(AppSettings settings) => AppSettingsModel(
        currency: settings.currency,
        darkMode: settings.darkMode,
        language: settings.language,
      );

  final String currency;
  final bool darkMode;
  final String language;

  Map<String, dynamic> toJson() => _$AppSettingsModelToJson(this);

  AppSettings toEntity() =>
      AppSettings(currency: currency, darkMode: darkMode, language: language);
}
```

`lib/core/hive/adapters/app_settings_model_adapter.dart`:
```dart
import 'package:hive/hive.dart';

import '../../../features/settings/data/models/app_settings_model.dart';
import '../../config/constants.dart';

class AppSettingsModelAdapter extends TypeAdapter<AppSettingsModel> {
  @override
  final int typeId = HiveTypeIds.settings;

  @override
  AppSettingsModel read(BinaryReader reader) =>
      AppSettingsModel.fromJson(Map<String, dynamic>.from(reader.readMap()));

  @override
  void write(BinaryWriter writer, AppSettingsModel obj) =>
      writer.writeMap(obj.toJson());
}
```

`lib/features/settings/data/datasources/settings_local_datasource.dart`:
```dart
import 'package:hive/hive.dart';

import '../../../../core/error/exceptions.dart';
import '../models/app_settings_model.dart';

abstract class SettingsLocalDataSource {
  /// Null when nothing has been saved yet.
  AppSettingsModel? getSettings();

  Future<void> saveSettings(AppSettingsModel model);
}

class HiveSettingsLocalDataSource implements SettingsLocalDataSource {
  HiveSettingsLocalDataSource(this._box);

  static const _key = 'current';

  final Box<AppSettingsModel> _box;

  @override
  AppSettingsModel? getSettings() {
    try {
      return _box.get(_key);
    } catch (e) {
      throw CacheException('Failed to read settings: $e');
    }
  }

  @override
  Future<void> saveSettings(AppSettingsModel model) async {
    try {
      await _box.put(_key, model);
    } catch (e) {
      throw CacheException('Failed to save settings: $e');
    }
  }
}
```

`lib/features/settings/data/repositories/settings_repository_impl.dart`:
```dart
import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_local_datasource.dart';
import '../models/app_settings_model.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._dataSource);

  final SettingsLocalDataSource _dataSource;

  @override
  Future<Either<Failure, AppSettings>> getSettings() async {
    try {
      return Right(_dataSource.getSettings()?.toEntity() ?? const AppSettings());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> saveSettings(AppSettings settings) async {
    try {
      await _dataSource.saveSettings(AppSettingsModel.fromEntity(settings));
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }
}
```

- [ ] **Step 5: Settings BLoC**

`settings_event.dart`:
```dart
import 'package:equatable/equatable.dart';

sealed class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class SettingsLoadRequested extends SettingsEvent {
  const SettingsLoadRequested();
}

class CurrencyChanged extends SettingsEvent {
  const CurrencyChanged(this.currency);
  final String currency;
  @override
  List<Object?> get props => [currency];
}

class DarkModeToggled extends SettingsEvent {
  const DarkModeToggled(this.enabled);
  final bool enabled;
  @override
  List<Object?> get props => [enabled];
}

class LanguageChanged extends SettingsEvent {
  const LanguageChanged(this.language);
  final String language;
  @override
  List<Object?> get props => [language];
}
```

`settings_state.dart`:
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/app_settings.dart';

part 'settings_state.freezed.dart';

@freezed
abstract class SettingsState with _$SettingsState {
  const factory SettingsState({
    @Default(AppSettings()) AppSettings settings,
    String? errorMessage,
  }) = _SettingsState;
}
```

`settings_bloc.dart`:
```dart
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/app_settings.dart';
import '../../domain/usecases/get_settings.dart';
import '../../domain/usecases/save_settings.dart';
import 'settings_event.dart';
import 'settings_state.dart';

export 'settings_event.dart';
export 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc(this._getSettings, this._saveSettings)
      : super(const SettingsState()) {
    on<SettingsLoadRequested>(_onLoad);
    on<CurrencyChanged>(
        (e, emit) => _save(state.settings.copyWith(currency: e.currency), emit));
    on<DarkModeToggled>(
        (e, emit) => _save(state.settings.copyWith(darkMode: e.enabled), emit));
    on<LanguageChanged>(
        (e, emit) => _save(state.settings.copyWith(language: e.language), emit));
  }

  final GetSettings _getSettings;
  final SaveSettings _saveSettings;

  Future<void> _onLoad(
      SettingsLoadRequested event, Emitter<SettingsState> emit) async {
    final result = await _getSettings();
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (settings) => emit(SettingsState(settings: settings)),
    );
  }

  Future<void> _save(AppSettings updated, Emitter<SettingsState> emit) async {
    final result = await _saveSettings(updated);
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (_) => emit(SettingsState(settings: updated)),
    );
  }
}
```

- [ ] **Step 6: Settings page, DI, route**

`settings_page.dart`: `class SettingsPage extends StatelessWidget`. `Scaffold(appBar: AppBar(title: Text('Settings')))`, body a `ListView` with padding 16 containing a `Card` with:
- `ListTile` "Currency" with trailing `DropdownButton<String>` over `SupportedCurrencies.codes`, value = current currency, `onChanged` → `CurrencyChanged`.
- `SwitchListTile` "Dark mode" → `DarkModeToggled`.
- `ListTile` "Language" with trailing `DropdownButton<String>` whose only item is `'en'` labelled "English" → `LanguageChanged`.
Wrap in `BlocListener<SettingsBloc, SettingsState>` (listenWhen errorMessage changed and non-null) showing a `SnackBar(errorMessage)`. Use `BlocBuilder` for the values.

`lib/features/settings/settings_injection.dart`:
```dart
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';

import '../../core/config/constants.dart';
import 'data/datasources/settings_local_datasource.dart';
import 'data/models/app_settings_model.dart';
import 'data/repositories/settings_repository_impl.dart';
import 'domain/repositories/settings_repository.dart';
import 'domain/usecases/get_settings.dart';
import 'domain/usecases/save_settings.dart';
import 'presentation/bloc/settings_bloc.dart';

void registerSettings(GetIt sl) {
  // Data sources
  sl.registerLazySingleton<SettingsLocalDataSource>(() =>
      HiveSettingsLocalDataSource(Hive.box<AppSettingsModel>(HiveBoxes.settings)));
  // Repositories
  sl.registerLazySingleton<SettingsRepository>(() => SettingsRepositoryImpl(sl()));
  // Use cases
  sl.registerFactory(() => GetSettings(sl()));
  sl.registerFactory(() => SaveSettings(sl()));
  // BLoCs
  sl.registerFactory(() => SettingsBloc(sl(), sl()));
}
```

`lib/features/settings/settings_routes.dart`:
```dart
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'presentation/pages/settings_page.dart';

/// SettingsBloc is app-wide (provided in app.dart), so no BlocProvider here.
Widget settingsRouteBuilder(BuildContext context, GoRouterState state) =>
    const SettingsPage();
```

- [ ] **Step 7: Feature stubs**

`lib/core/widgets/placeholder_page.dart`:
```dart
import 'package:flutter/material.dart';

class PlaceholderPage extends StatelessWidget {
  const PlaceholderPage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(title)),
        body: Center(child: Text('$title — coming soon')),
      );
}
```

For each feature create `lib/features/<f>/<f>_injection.dart`:
```dart
import 'package:get_it/get_it.dart';

void registerTransactions(GetIt sl) {}
```
(names: `registerTransactions`, `registerExpense`, `registerIncome`, `registerDashboard`, `registerBudget`, `registerReports`)

and `lib/features/<f>/<f>_routes.dart` returning `PlaceholderPage`, e.g.:
```dart
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/placeholder_page.dart';

Widget dashboardRouteBuilder(BuildContext context, GoRouterState state) =>
    const PlaceholderPage(title: 'Dashboard');
```
Builder names: `transactionsRouteBuilder` (Transactions), `dashboardRouteBuilder` (Dashboard), `budgetRouteBuilder` (Budgets), `reportsRouteBuilder` (Reports), in `expense_routes.dart`: `addExpenseRouteBuilder` (Add Expense) and `editExpenseRouteBuilder` (Edit Expense), in `income_routes.dart`: `addIncomeRouteBuilder` (Add Income) and `editIncomeRouteBuilder` (Edit Income).

- [ ] **Step 8: Hive setup, DI container**

`lib/core/hive/hive_setup.dart`:
```dart
import 'package:hive_flutter/hive_flutter.dart';

import '../../features/settings/data/models/app_settings_model.dart';
import '../config/constants.dart';
import 'adapters/app_settings_model_adapter.dart';

class HiveSetup {
  const HiveSetup._();

  /// Registers every adapter, then opens every box. Call before DI.
  static Future<void> init() async {
    await Hive.initFlutter();

    Hive.registerAdapter(AppSettingsModelAdapter());

    await Hive.openBox<AppSettingsModel>(HiveBoxes.settings);
  }
}
```

`lib/core/di/injection_container.dart`:
```dart
import 'package:get_it/get_it.dart';

import '../../features/budget/budget_injection.dart';
import '../../features/dashboard/dashboard_injection.dart';
import '../../features/expense/expense_injection.dart';
import '../../features/income/income_injection.dart';
import '../../features/reports/reports_injection.dart';
import '../../features/settings/settings_injection.dart';
import '../../features/transactions/transactions_injection.dart';
import '../hive/hive_setup.dart';

final GetIt sl = GetIt.instance;

Future<void> initDependencies() async {
  await HiveSetup.init();

  // Shared data (other features depend on these repositories)
  registerSettings(sl);
  registerTransactions(sl);

  // Features
  registerExpense(sl);
  registerIncome(sl);
  registerDashboard(sl);
  registerBudget(sl);
  registerReports(sl);
}
```

- [ ] **Step 9: Router, shell, bottom nav, month selector, app, main**

`lib/core/widgets/app_bottom_nav.dart`: `AppBottomNav({required String location})` → `NavigationBar` with 5 destinations in this order: Home (`Icons.home_outlined`/`Icons.home`, `AppRoutes.dashboard`), Transactions (`Icons.receipt_long_outlined`/`Icons.receipt_long`), Budget (`Icons.savings_outlined`/`Icons.savings`), Reports (`Icons.bar_chart_outlined`/`Icons.bar_chart`), Settings (`Icons.settings_outlined`/`Icons.settings`). `selectedIndex` = index of the tab whose path equals `location`, or for non-root paths `location.startsWith(path)`; default 0. `onDestinationSelected` → `context.go(path)`.

`lib/core/widgets/app_shell.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app_bottom_nav.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: child,
        bottomNavigationBar:
            AppBottomNav(location: GoRouterState.of(context).uri.path),
      );
}
```

`lib/core/config/router.dart`:
```dart
import 'package:go_router/go_router.dart';

import '../../features/budget/budget_routes.dart';
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
    GoRoute(path: AppRoutes.addExpense, builder: addExpenseRouteBuilder),
    GoRoute(path: AppRoutes.editExpense, builder: editExpenseRouteBuilder),
    GoRoute(path: AppRoutes.addIncome, builder: addIncomeRouteBuilder),
    GoRoute(path: AppRoutes.editIncome, builder: editIncomeRouteBuilder),
  ],
);
```

`lib/shared/widgets/month_selector.dart`: `MonthSelector({required int month, required int year, required ValueChanged<int> onShift})` — a `Row(mainAxisAlignment: center)` with `IconButton(Icons.chevron_left, onPressed: () => onShift(-1))`, `Text(formatMonthYear(month, year), style: titleMedium bold)`, `IconButton(Icons.chevron_right, onPressed: () => onShift(1))`.

`lib/app.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/config/router.dart';
import 'core/config/theme.dart';
import 'core/di/injection_container.dart';
import 'features/settings/presentation/bloc/settings_bloc.dart';

class MoneyBalanceApp extends StatelessWidget {
  const MoneyBalanceApp({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider<SettingsBloc>(
        create: (_) => sl<SettingsBloc>()..add(const SettingsLoadRequested()),
        child: BlocBuilder<SettingsBloc, SettingsState>(
          buildWhen: (a, b) => a.settings.darkMode != b.settings.darkMode,
          builder: (context, state) => MaterialApp.router(
            title: 'Money Balance',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: state.settings.darkMode ? ThemeMode.dark : ThemeMode.light,
            routerConfig: appRouter,
          ),
        ),
      );
}
```

`lib/main.dart`:
```dart
import 'package:flutter/material.dart';

import 'app.dart';
import 'core/di/injection_container.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  runApp(const MoneyBalanceApp());
}
```

- [ ] **Step 10: Generate and verify**

Run: `dart run build_runner build --delete-conflicting-outputs` — expect success and generated `app_settings.freezed.dart`, `app_settings_model.g.dart`, `settings_state.freezed.dart`.
Run: `flutter analyze` — expect `No issues found!`. Fix any lint (e.g. `withValues` availability, `CardThemeData`) by consulting the installed package source rather than suppressing.

- [ ] **Step 11: Commit**

```bash
git add -A
git commit -m "feat: app foundation, core infrastructure and settings feature"
```

---

### Task 2: Transactions feature — shared domain/data, TransactionBloc, list page, shared widgets

**Files:**
- Create: `lib/features/transactions/domain/entities/transaction.dart`
- Create: `lib/features/transactions/domain/repositories/transaction_repository.dart`
- Create: `lib/features/transactions/domain/usecases/{get_transactions.dart, add_transaction.dart, update_transaction.dart, delete_transaction.dart}`
- Create: `lib/features/transactions/data/models/transaction_model.dart`
- Create: `lib/features/transactions/data/datasources/transaction_local_datasource.dart`
- Create: `lib/features/transactions/data/repositories/transaction_repository_impl.dart`
- Create: `lib/core/hive/adapters/transaction_model_adapter.dart`
- Create: `lib/features/transactions/presentation/bloc/{transaction_bloc.dart, transaction_event.dart, transaction_state.dart}`
- Create: `lib/features/transactions/presentation/pages/transaction_list_page.dart`
- Create: `lib/shared/widgets/{transaction_tile.dart, category_icon.dart, empty_state.dart}`
- Modify: `lib/core/hive/hive_setup.dart`, `lib/features/transactions/transactions_injection.dart`, `lib/features/transactions/transactions_routes.dart`

**Interfaces:**
- Consumes (Task 1): `Failure` family, `AppException` family, `HiveBoxes.transactions`, `HiveTypeIds.transaction`, `AppRoutes.editExpense/editIncome`, `AppCategories`, `formatCurrency`, `formatDate`, `AppColors`, `sl`, `SettingsBloc`.
- Produces (used by Tasks 3–6):
  - `enum TransactionType { expense, income }` and freezed `Transaction` in `transaction.dart`
  - `abstract class TransactionRepository` with `getTransactions()`, `addTransaction(Transaction)`, `updateTransaction(Transaction)`, `deleteTransaction(String id)`
  - Use cases `GetTransactions`, `AddTransaction`, `UpdateTransaction`, `DeleteTransaction`, all registered in GetIt as factories; `TransactionRepository` registered as lazy singleton
  - `TransactionTile({required Transaction transaction, required String currencyCode, VoidCallback? onTap})`
  - `IconData categoryIcon(String category)`
  - `EmptyState({required IconData icon, required String message, Widget? action})`

- [ ] **Step 1: Entity and repository contract**

`transaction.dart`:
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction.freezed.dart';

enum TransactionType { expense, income }

@freezed
abstract class Transaction with _$Transaction {
  const factory Transaction({
    required String id,
    required double amount,
    required String category,
    required DateTime date,
    required TransactionType type,
    String? paymentMethod,
    String? notes,
    required DateTime createdAt,
  }) = _Transaction;
}
```

`transaction_repository.dart`:
```dart
import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/transaction.dart';

abstract class TransactionRepository {
  /// All transactions, newest `date` first (ties: newest `createdAt` first).
  Future<Either<Failure, List<Transaction>>> getTransactions();

  Future<Either<Failure, void>> addTransaction(Transaction transaction);

  /// Fails with [NotFoundFailure] if no transaction has this id.
  Future<Either<Failure, void>> updateTransaction(Transaction transaction);

  /// Fails with [NotFoundFailure] if no transaction has this id.
  Future<Either<Failure, void>> deleteTransaction(String id);
}
```

Use cases — each a plain class with a `const` constructor taking `TransactionRepository` and a `call` that delegates:
- `GetTransactions.call()` → `getTransactions()`
- `AddTransaction.call(Transaction t)` → `addTransaction(t)`
- `UpdateTransaction.call(Transaction t)` → `updateTransaction(t)`
- `DeleteTransaction.call(String id)` → `deleteTransaction(id)`

(Same shape as `GetSettings` in Task 1.)

- [ ] **Step 2: Model, adapter, data source, repository impl**

`transaction_model.dart`:
```dart
import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/transaction.dart';

part 'transaction_model.g.dart';

@JsonSerializable()
class TransactionModel {
  const TransactionModel({
    required this.id,
    required this.amount,
    required this.category,
    required this.date,
    required this.type,
    this.paymentMethod,
    this.notes,
    required this.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      _$TransactionModelFromJson(json);

  factory TransactionModel.fromEntity(Transaction t) => TransactionModel(
        id: t.id,
        amount: t.amount,
        category: t.category,
        date: t.date,
        type: t.type,
        paymentMethod: t.paymentMethod,
        notes: t.notes,
        createdAt: t.createdAt,
      );

  final String id;
  final double amount;
  final String category;
  final DateTime date;
  final TransactionType type;
  final String? paymentMethod;
  final String? notes;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => _$TransactionModelToJson(this);

  Transaction toEntity() => Transaction(
        id: id,
        amount: amount,
        category: category,
        date: date,
        type: type,
        paymentMethod: paymentMethod,
        notes: notes,
        createdAt: createdAt,
      );
}
```

`lib/core/hive/adapters/transaction_model_adapter.dart` — same shape as `AppSettingsModelAdapter` with `typeId = HiveTypeIds.transaction`, reading `TransactionModel.fromJson(Map<String, dynamic>.from(reader.readMap()))` and writing `obj.toJson()`.

`hive_setup.dart`: register `TransactionModelAdapter()` and `await Hive.openBox<TransactionModel>(HiveBoxes.transactions);` (adapters block, then boxes block).

`transaction_local_datasource.dart`:
```dart
import 'package:hive/hive.dart';

import '../../../../core/error/exceptions.dart';
import '../models/transaction_model.dart';

abstract class TransactionLocalDataSource {
  List<TransactionModel> getAll();
  Future<void> put(TransactionModel model);

  /// Throws [NotFoundException] when [id] is absent.
  Future<void> update(TransactionModel model);

  /// Throws [NotFoundException] when [id] is absent.
  Future<void> delete(String id);
}

class HiveTransactionLocalDataSource implements TransactionLocalDataSource {
  HiveTransactionLocalDataSource(this._box);

  final Box<TransactionModel> _box;

  @override
  List<TransactionModel> getAll() {
    try {
      return _box.values.toList();
    } catch (e) {
      throw CacheException('Failed to read transactions: $e');
    }
  }

  @override
  Future<void> put(TransactionModel model) async {
    try {
      await _box.put(model.id, model);
    } catch (e) {
      throw CacheException('Failed to save transaction: $e');
    }
  }

  @override
  Future<void> update(TransactionModel model) async {
    if (!_box.containsKey(model.id)) throw const NotFoundException();
    await put(model);
  }

  @override
  Future<void> delete(String id) async {
    if (!_box.containsKey(id)) throw const NotFoundException();
    try {
      await _box.delete(id);
    } catch (e) {
      throw CacheException('Failed to delete transaction: $e');
    }
  }
}
```

`transaction_repository_impl.dart`: implements every method with `try { ... } on NotFoundException catch (e) { return Left(NotFoundFailure(e.message)); } on CacheException catch (e) { return Left(CacheFailure(e.message)); }`. `getTransactions` maps models to entities and sorts: `b.date.compareTo(a.date)`, tie → `b.createdAt.compareTo(a.createdAt)`.

- [ ] **Step 3: DI and shared widgets**

`transactions_injection.dart`:
```dart
void registerTransactions(GetIt sl) {
  // Data sources
  sl.registerLazySingleton<TransactionLocalDataSource>(() =>
      HiveTransactionLocalDataSource(
          Hive.box<TransactionModel>(HiveBoxes.transactions)));
  // Repositories
  sl.registerLazySingleton<TransactionRepository>(
      () => TransactionRepositoryImpl(sl()));
  // Use cases
  sl.registerFactory(() => GetTransactions(sl()));
  sl.registerFactory(() => AddTransaction(sl()));
  sl.registerFactory(() => UpdateTransaction(sl()));
  sl.registerFactory(() => DeleteTransaction(sl()));
  // BLoCs
  sl.registerFactory(() => TransactionBloc(sl(), sl()));
}
```

`category_icon.dart`: `IconData categoryIcon(String category)` switch: Food→`Icons.restaurant`, Transport→`Icons.directions_car`, Shopping→`Icons.shopping_bag`, Bills→`Icons.receipt`, Entertainment→`Icons.movie`, Health→`Icons.favorite`, Education→`Icons.school`, Salary→`Icons.work`, Freelance→`Icons.laptop`, Business→`Icons.store`, Investment→`Icons.trending_up`, Gift→`Icons.card_giftcard`, default→`Icons.category`.

`empty_state.dart`: centred `Column` (padding 32): `Icon(icon, size: 56, color: onSurfaceVariant)`, 12px gap, `Text(message, textAlign: center, style: bodyLarge onSurfaceVariant)`, optional `action` below with 16px gap.

`transaction_tile.dart`: `ListTile` with leading `CircleAvatar` (background = type colour at 15% alpha, icon `categoryIcon(category)` in type colour; expense = `AppColors.danger`, income = `AppColors.success`), title = category, subtitle = `formatDate(date)` plus ` · paymentMethod` when present and `notes` on a second line when non-empty (maxLines 1, ellipsis), trailing = `'${expense ? '-' : '+'}${formatCurrency(amount, currencyCode)}'` bold in type colour, `onTap`.

- [ ] **Step 4: TransactionBloc**

Events (`sealed class TransactionEvent extends Equatable`): `TransactionsLoadRequested()`, `TransactionTypeFilterChanged(TransactionType? type)`, `TransactionCategoryFilterChanged(String? category)`, `TransactionSortChanged(TransactionSort sort)`, `TransactionDeleteRequested(String id)`.

State (`transaction_state.dart`):
```dart
enum TransactionListStatus { initial, loading, success, failure }

enum TransactionSort { newest, oldest, highest, lowest }

@freezed
abstract class TransactionState with _$TransactionState {
  const TransactionState._();

  const factory TransactionState({
    @Default(TransactionListStatus.initial) TransactionListStatus status,
    @Default(<Transaction>[]) List<Transaction> all,
    TransactionType? typeFilter,
    String? categoryFilter,
    @Default(TransactionSort.newest) TransactionSort sort,
    String? errorMessage,
  }) = _TransactionState;

  List<Transaction> get visible {
    final filtered = all.where((t) =>
        (typeFilter == null || t.type == typeFilter) &&
        (categoryFilter == null || t.category == categoryFilter));
    final list = filtered.toList();
    switch (sort) {
      case TransactionSort.newest:
        list.sort((a, b) => b.date.compareTo(a.date));
      case TransactionSort.oldest:
        list.sort((a, b) => a.date.compareTo(b.date));
      case TransactionSort.highest:
        list.sort((a, b) => b.amount.compareTo(a.amount));
      case TransactionSort.lowest:
        list.sort((a, b) => a.amount.compareTo(b.amount));
    }
    return list;
  }
}
```

Bloc `TransactionBloc(GetTransactions, DeleteTransaction)`:
- `TransactionsLoadRequested` → emit `status: loading` (keep `all`), call `GetTransactions`; Right → `status: success, all: list, errorMessage: null`; Left → `status: failure, errorMessage`.
- `TransactionTypeFilterChanged` → `copyWith(typeFilter: type, categoryFilter: null)` (category list depends on type).
- `TransactionCategoryFilterChanged` / `TransactionSortChanged` → `copyWith`.
- `TransactionDeleteRequested` → `DeleteTransaction(id)`; Right → re-run load; Left → `copyWith(errorMessage: failure.message)` (status unchanged).
Clear `errorMessage` (set null) at the start of every handler so a repeated identical error still re-triggers the listener.

- [ ] **Step 5: TransactionListPage and route**

`TransactionListPage` (StatelessWidget, reads currency via `context.select((SettingsBloc b) => b.state.settings.currency)`):
- `AppBar(title: Text('Transactions'))` with `PopupMenuButton<TransactionSort>` (icon `Icons.sort`) items "Newest first", "Oldest first", "Highest amount", "Lowest amount".
- Filter area: `SegmentedButton<TransactionType?>` with segments All(null)/Expenses/Income; below it a `DropdownButton<String?>` "All categories" + categories (`AppCategories.expense`, `.income`, or the de-duplicated union of both when type is null).
- Body by status: loading & `all` empty → `CircularProgressIndicator`; failure → `EmptyState(icon: Icons.error_outline, message: errorMessage, action: TextButton('Retry'))`; `visible` empty → `EmptyState(icon: Icons.receipt_long, message: 'No transactions yet')`; else `RefreshIndicator` + `ListView.separated` of `Dismissible` (key `ValueKey(t.id)`, direction endToStart, red background with delete icon, `confirmDismiss` → `AlertDialog` "Delete transaction?" Cancel/Delete; on confirm add `TransactionDeleteRequested`) wrapping `TransactionTile`.
- Tile tap: `final changed = await context.push<bool>(t.type == TransactionType.expense ? AppRoutes.editExpense : AppRoutes.editIncome, extra: t); if (changed == true && context.mounted) bloc.add(const TransactionsLoadRequested());`
- `BlocListener` shows `SnackBar(errorMessage)` when status is not failure and `errorMessage` becomes non-null.

`transactions_routes.dart`:
```dart
Widget transactionsRouteBuilder(BuildContext context, GoRouterState state) =>
    BlocProvider(
      create: (_) => sl<TransactionBloc>()..add(const TransactionsLoadRequested()),
      child: const TransactionListPage(),
    );
```

- [ ] **Step 6: Generate, verify, commit**

Run `dart run build_runner build --delete-conflicting-outputs` then `flutter analyze` → `No issues found!`.
```bash
git add -A
git commit -m "feat: transactions domain/data layer, list page and shared widgets"
```

---

### Task 3: Expense & Income entry (add / edit / delete)

**Files (only these):**
- Create: `lib/features/expense/domain/usecases/add_expense.dart`
- Create: `lib/features/expense/presentation/bloc/{expense_bloc.dart, expense_event.dart, expense_state.dart}`
- Create: `lib/features/expense/presentation/pages/expense_form_page.dart`
- Modify: `lib/features/expense/expense_injection.dart`, `lib/features/expense/expense_routes.dart`
- Create: `lib/features/income/domain/usecases/add_income.dart`
- Create: `lib/features/income/presentation/bloc/{income_bloc.dart, income_event.dart, income_state.dart}`
- Create: `lib/features/income/presentation/pages/income_form_page.dart`
- Modify: `lib/features/income/income_injection.dart`, `lib/features/income/income_routes.dart`
- Create: `lib/shared/widgets/transaction_form.dart`, `lib/shared/form_submission_status.dart`

**Interfaces:**
- Consumes: `Transaction`, `TransactionType`, `TransactionRepository`, `UpdateTransaction`, `DeleteTransaction` (Task 2, already in GetIt); `parseAmount`, `formatDate`, `AppCategories`, `PaymentMethods`, `ValidationFailure`, `sl` (Task 1).
- Produces: routes `AppRoutes.addExpense/editExpense/addIncome/editIncome` working; pages `pop(true)` after a successful save or delete so callers reload. Callers push edit routes with `extra: Transaction`.

- [ ] **Step 1: Use cases**

`add_expense.dart`:
```dart
import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/error/failures.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/domain/repositories/transaction_repository.dart';

class AddExpense {
  const AddExpense(this._repository, this._uuid);

  final TransactionRepository _repository;
  final Uuid _uuid;

  Future<Either<Failure, void>> call({
    required double amount,
    required String category,
    required DateTime date,
    String? paymentMethod,
    String? notes,
  }) =>
      _repository.addTransaction(Transaction(
        id: _uuid.v4(),
        amount: amount,
        category: category,
        date: date,
        type: TransactionType.expense,
        paymentMethod: paymentMethod,
        notes: notes,
        createdAt: DateTime.now(),
      ));
}
```
`add_income.dart`: `AddIncome` identical but `type: TransactionType.income` and no `paymentMethod` parameter (always null).

- [ ] **Step 2: Shared form widget**

`lib/shared/form_submission_status.dart`: `enum FormSubmissionStatus { initial, submitting, success, failure }`.

`lib/shared/widgets/transaction_form.dart`:
```dart
class TransactionFormData {
  const TransactionFormData({
    required this.amountText,
    required this.category,
    required this.date,
    this.paymentMethod,
    this.notes,
  });

  final String amountText;
  final String? category;
  final DateTime date;
  final String? paymentMethod;
  final String? notes;
}
```
`TransactionForm({required List<String> categories, required bool showPaymentMethod, Transaction? initial, required bool isSubmitting, required String submitLabel, required ValueChanged<TransactionFormData> onSubmit})` — StatefulWidget with a `Form`:
- Amount `TextFormField` (autofocus when adding, `TextInputType.numberWithOptions(decimal: true)`, large bold text, prefix icon `Icons.attach_money`), validator: `parseAmount(v ?? '') == null ? 'Enter an amount greater than 0' : null`. Initial value `initial.amount.toString()` when editing.
- Category: `Wrap` of `ChoiceChip`s with `categoryIcon` avatars; validation message `Select a category` shown under the chips when submitting with none selected.
- Date: `ListTile` showing `formatDate(date)` → `showDatePicker(firstDate: DateTime(2000), lastDate: DateTime.now())`; keep the time-of-day of `initial.date` when editing, else `DateTime.now()`.
- Payment method (only if `showPaymentMethod`): `DropdownButtonFormField<String>` over `PaymentMethods.all`, default `initial?.paymentMethod ?? 'Cash'`.
- Notes: `TextFormField(maxLength: 200, maxLines: 3)`; empty/whitespace → `null`.
- `FilledButton(submitLabel)`; disabled and showing a small `CircularProgressIndicator` while `isSubmitting`. On press: validate, then `onSubmit(TransactionFormData(...))`.

- [ ] **Step 3: ExpenseBloc / IncomeBloc**

`expense_event.dart`: `sealed class ExpenseEvent extends Equatable`; `ExpenseSubmitted(TransactionFormData data)`, `ExpenseDeleteRequested()`.
`expense_state.dart`: freezed `ExpenseState({@Default(FormSubmissionStatus.initial) FormSubmissionStatus status, String? errorMessage})`.
`ExpenseBloc(AddExpense addExpense, UpdateTransaction updateTransaction, DeleteTransaction deleteTransaction, {Transaction? initial})`:
- `ExpenseSubmitted`: `final amount = parseAmount(data.amountText)`; null → emit `failure` with `const ValidationFailure('Enter an amount greater than 0').message`; `data.category == null` → `failure` 'Select a category'. Emit `submitting`. If `initial == null` → `AddExpense(...)`; else `UpdateTransaction(initial.copyWith(amount:, category:, date:, paymentMethod:, notes:))` — `id`, `type` and `createdAt` are preserved. Right → `success`; Left → `failure` + message.
- `ExpenseDeleteRequested` (only when `initial != null`): `submitting` → `DeleteTransaction(initial.id)` → `success` / `failure`.
`IncomeBloc` mirrors it with `IncomeSubmitted`, `IncomeDeleteRequested`, `IncomeState`, `AddIncome` (paymentMethod ignored).

- [ ] **Step 4: Pages**

`ExpenseFormPage({Transaction? initial})`: `Scaffold(appBar: AppBar(title: Text(initial == null ? 'Add Expense' : 'Edit Expense'), actions: [if editing IconButton(Icons.delete_outline) → confirm AlertDialog "Delete this expense?" → ExpenseDeleteRequested]))`, body `SingleChildScrollView(padding 16)` with `TransactionForm(categories: AppCategories.expense, showPaymentMethod: true, submitLabel: initial == null ? 'Save expense' : 'Update expense', ...)`. `BlocConsumer`: on `success` → `context.pop(true)`; on `failure` → `SnackBar(errorMessage)`.
`IncomeFormPage` mirrors it: titles 'Add Income'/'Edit Income', `AppCategories.income`, `showPaymentMethod: false`, labels 'Save income'/'Update income', dialog "Delete this income?".

- [ ] **Step 5: DI and routes**

`expense_injection.dart`:
```dart
void registerExpense(GetIt sl) {
  // Use cases
  sl.registerFactory(() => AddExpense(sl(), const Uuid()));
  // BLoCs
  sl.registerFactoryParam<ExpenseBloc, Transaction?, void>(
      (initial, _) => ExpenseBloc(sl(), sl(), sl(), initial: initial));
}
```
`expense_routes.dart`:
```dart
Widget addExpenseRouteBuilder(BuildContext context, GoRouterState state) =>
    BlocProvider(
      create: (_) => sl<ExpenseBloc>(param1: null),
      child: const ExpenseFormPage(),
    );

Widget editExpenseRouteBuilder(BuildContext context, GoRouterState state) {
  final initial = state.extra is Transaction ? state.extra as Transaction : null;
  return BlocProvider(
    create: (_) => sl<ExpenseBloc>(param1: initial),
    child: ExpenseFormPage(initial: initial),
  );
}
```
Income: same with `AddIncome`, `IncomeBloc`, `IncomeFormPage`, `addIncomeRouteBuilder`, `editIncomeRouteBuilder`.

- [ ] **Step 6: Generate, verify, commit**

`dart run build_runner build --delete-conflicting-outputs`, `flutter analyze` → `No issues found!`.
```bash
git add -A
git commit -m "feat: add, edit and delete expenses and income"
```

---

### Task 4: Dashboard

**Files (only these):**
- Create: `lib/features/dashboard/domain/entities/dashboard_summary.dart`
- Create: `lib/features/dashboard/domain/usecases/get_dashboard_summary.dart`
- Create: `lib/features/dashboard/presentation/bloc/{dashboard_bloc.dart, dashboard_event.dart, dashboard_state.dart}`
- Create: `lib/features/dashboard/presentation/pages/dashboard_page.dart`
- Create: `lib/features/dashboard/presentation/widgets/{balance_card.dart, summary_card.dart, add_transaction_sheet.dart}`
- Modify: `lib/features/dashboard/dashboard_injection.dart`, `lib/features/dashboard/dashboard_routes.dart`

**Interfaces:**
- Consumes: `Transaction`, `TransactionType`, `TransactionRepository` (Task 2); `TransactionTile`, `EmptyState` (Task 2); `AppRoutes`, `formatCurrency`, `formatMonthYear`, `DateTimeX.isSameMonth`, `AppColors`, `SettingsBloc`, `sl` (Task 1). Add/edit routes return `true` via `pop(true)` after a change (Task 3).
- Produces: `dashboardRouteBuilder`.

- [ ] **Step 1: Entity and use case**

```dart
@freezed
abstract class DashboardSummary with _$DashboardSummary {
  const factory DashboardSummary({
    required double totalBalance,
    required double monthIncome,
    required double monthExpense,
    required List<Transaction> recentTransactions,
  }) = _DashboardSummary;
}
```

```dart
class GetDashboardSummary {
  const GetDashboardSummary(this._repository);

  static const recentCount = 5;

  final TransactionRepository _repository;

  /// [now] selects the "current month" for the month totals.
  Future<Either<Failure, DashboardSummary>> call(DateTime now) async {
    final result = await _repository.getTransactions();
    return result.map((txs) {
      var balance = 0.0, income = 0.0, expense = 0.0;
      for (final t in txs) {
        final signed = t.type == TransactionType.income ? t.amount : -t.amount;
        balance += signed;
        if (t.date.isSameMonth(now)) {
          if (t.type == TransactionType.income) {
            income += t.amount;
          } else {
            expense += t.amount;
          }
        }
      }
      return DashboardSummary(
        totalBalance: balance,
        monthIncome: income,
        monthExpense: expense,
        recentTransactions: txs.take(recentCount).toList(),
      );
    });
  }
}
```
(Repository already returns newest-first, so `take` yields the most recent.) The dashboard has no data layer of its own — it reads `TransactionRepository`.

- [ ] **Step 2: DashboardBloc**

Event: `DashboardLoadRequested()`. State: freezed `DashboardState({@Default(DashboardStatus.initial) DashboardStatus status, DashboardSummary? summary, String? errorMessage})` with `enum DashboardStatus { initial, loading, success, failure }`. Handler: emit loading (keep previous summary), call `GetDashboardSummary(DateTime.now())`, emit success/failure.

- [ ] **Step 3: Widgets and page**

- `BalanceCard({required double balance, required String currencyCode})`: full-width container, radius 24, gradient `AppColors.primary` → `Color(0xFF1D4ED8)`, soft shadow (primary 30% alpha, blur 24, offset (0,12)); decorative translucent white circles in the corner (glassmorphism feel); label "Total balance" (white70), amount `formatCurrency` 32px bold white animated with `TweenAnimationBuilder<double>` (600ms, easeOutCubic) from 0 to balance.
- `SummaryCard({required String label, required double amount, required String currencyCode, required IconData icon, required Color color})`: `Card` with padding 16: tinted circular icon, label, bold amount.
- `AddTransactionSheet`: static `Future<String?> show(BuildContext)` → `showModalBottomSheet` with two `ListTile`s "Add expense" (red `Icons.remove_circle_outline`) returning `AppRoutes.addExpense` and "Add income" (green `Icons.add_circle_outline`) returning `AppRoutes.addIncome`.
- `DashboardPage`: `Scaffold` with `FloatingActionButton.extended(icon: Icons.add, label: 'Add')` → route = `await AddTransactionSheet.show(context)`; if non-null `final changed = await context.push<bool>(route)`; if `changed == true && context.mounted` → `DashboardLoadRequested`. Body: `SafeArea` → `RefreshIndicator` → `ListView(padding 16)`: header "Money Balance" (headlineSmall bold) + `formatMonthYear(now)` subtitle; `BalanceCard`; `Row` of two `Expanded` `SummaryCard`s — "Income this month" (`Icons.arrow_downward`, success) and "Expenses this month" (`Icons.arrow_upward`, danger); section header "Recent transactions" with `TextButton('See all')` → `context.go(AppRoutes.transactions)`; recent list of `TransactionTile`s (tap → edit route like Task 2, reload on `true`), or `EmptyState(icon: Icons.receipt_long, message: 'No transactions yet.\nTap Add to record your first one.')`. When `summary == null` and loading → `CircularProgressIndicator`; failure with no summary → `EmptyState(icon: Icons.error_outline, message: errorMessage, action: Retry)`. Wrap the content in `AnimatedSwitcher` (300ms) keyed by status. Totals show `formatCurrency(0, currency)` on an empty database.

- [ ] **Step 4: DI and route**

```dart
void registerDashboard(GetIt sl) {
  // Use cases
  sl.registerFactory(() => GetDashboardSummary(sl()));
  // BLoCs
  sl.registerFactory(() => DashboardBloc(sl()));
}
```
```dart
Widget dashboardRouteBuilder(BuildContext context, GoRouterState state) =>
    BlocProvider(
      create: (_) => sl<DashboardBloc>()..add(const DashboardLoadRequested()),
      child: const DashboardPage(),
    );
```

- [ ] **Step 5: Generate, verify, commit**

`dart run build_runner build --delete-conflicting-outputs`, `flutter analyze` → `No issues found!`.
```bash
git add -A
git commit -m "feat: dashboard with balance, monthly totals and recent transactions"
```

---

### Task 5: Budget management

**Files (only these):**
- Create: `lib/features/budget/domain/entities/{budget.dart, budget_progress.dart}`
- Create: `lib/features/budget/domain/repositories/budget_repository.dart`
- Create: `lib/features/budget/domain/usecases/{get_budget_progress.dart, save_budget.dart, delete_budget.dart}`
- Create: `lib/features/budget/data/models/budget_model.dart`
- Create: `lib/features/budget/data/datasources/budget_local_datasource.dart`
- Create: `lib/features/budget/data/repositories/budget_repository_impl.dart`
- Create: `lib/core/hive/adapters/budget_model_adapter.dart`
- Modify: `lib/core/hive/hive_setup.dart` (register `BudgetModelAdapter`, open `Box<BudgetModel>(HiveBoxes.budgets)`)
- Create: `lib/features/budget/presentation/bloc/{budget_bloc.dart, budget_event.dart, budget_state.dart}`
- Create: `lib/features/budget/presentation/pages/budget_page.dart`
- Create: `lib/features/budget/presentation/widgets/{budget_progress_card.dart, budget_form_sheet.dart}`
- Modify: `lib/features/budget/budget_injection.dart`, `lib/features/budget/budget_routes.dart`

**Interfaces:**
- Consumes: `Transaction`, `TransactionType`, `TransactionRepository` (Task 2); `EmptyState`, `categoryIcon` (Task 2); `MonthSelector`, `parseAmount`, `formatCurrency`, `DateTimeX.addMonths`, `AppCategories.expense`, `HiveBoxes.budgets`, `HiveTypeIds.budget`, `AppColors`, Failure/Exception types, `SettingsBloc`, `sl` (Task 1).
- Produces: `budgetRouteBuilder`.

- [ ] **Step 1: Entities**

```dart
@freezed
abstract class Budget with _$Budget {
  const factory Budget({
    required String id,
    required String category,
    required double limit,
    required int month,
    required int year,
    @Default(true) bool isActive,
  }) = _Budget;
}
```

```dart
const kBudgetWarningThreshold = 0.8;

enum BudgetStatus { onTrack, warning, exceeded }

@freezed
abstract class BudgetProgress with _$BudgetProgress {
  const BudgetProgress._();

  const factory BudgetProgress({
    required Budget budget,
    required double spent,
  }) = _BudgetProgress;

  /// spent / limit; never NaN or infinite.
  double get ratio {
    if (budget.limit > 0) return spent / budget.limit;
    return spent > 0 ? 1.0 : 0.0;
  }

  /// 0..1 for progress bars.
  double get progress => ratio.clamp(0.0, 1.0);

  double get remaining => budget.limit - spent;

  BudgetStatus get status {
    if (spent > budget.limit) return BudgetStatus.exceeded;
    if (ratio >= kBudgetWarningThreshold) return BudgetStatus.warning;
    return BudgetStatus.onTrack;
  }
}
```

- [ ] **Step 2: Repository, data layer**

```dart
abstract class BudgetRepository {
  Future<Either<Failure, List<Budget>>> getBudgets({required int month, required int year});

  /// Insert or update by id. Fails with [ValidationFailure] when a different
  /// budget already exists for the same category, month and year.
  Future<Either<Failure, void>> saveBudget(Budget budget);

  /// Fails with [NotFoundFailure] if absent.
  Future<Either<Failure, void>> deleteBudget(String id);
}
```
`BudgetModel` (json_serializable, `fromEntity`/`toEntity`, same pattern as `TransactionModel`), `BudgetModelAdapter` (`typeId = HiveTypeIds.budget`, same pattern as `AppSettingsModelAdapter`), `BudgetLocalDataSource` with `List<BudgetModel> getAll()`, `Future<void> put(BudgetModel)`, `Future<void> delete(String id)` (throws `NotFoundException` when absent) implemented by `HiveBudgetLocalDataSource(Box<BudgetModel>)` (keys = id; wraps Hive errors in `CacheException`). `BudgetRepositoryImpl`: `getBudgets` filters by month/year and sorts by category; `saveBudget` checks `getAll()` for another id with same category/month/year → `Left(ValidationFailure('A ${budget.category} budget already exists for this month.'))`, else `put`; exceptions → `CacheFailure` / `NotFoundFailure`.

- [ ] **Step 3: Use cases**

`SaveBudget.call(Budget)` and `DeleteBudget.call(String id)` delegate. `GetBudgetProgress`:
```dart
class GetBudgetProgress {
  const GetBudgetProgress(this._budgets, this._transactions);

  final BudgetRepository _budgets;
  final TransactionRepository _transactions;

  /// Budgets of the month with the month's spending in their category,
  /// highest usage first.
  Future<Either<Failure, List<BudgetProgress>>> call({
    required int month,
    required int year,
  }) async {
    final budgetsResult = await _budgets.getBudgets(month: month, year: year);
    return budgetsResult.fold(
      (failure) async => Left(failure),
      (budgets) async {
        final txResult = await _transactions.getTransactions();
        return txResult.map((txs) {
          final spentByCategory = <String, double>{};
          for (final t in txs) {
            if (t.type == TransactionType.expense &&
                t.date.year == year &&
                t.date.month == month) {
              spentByCategory.update(t.category, (v) => v + t.amount,
                  ifAbsent: () => t.amount);
            }
          }
          return budgets
              .map((b) => BudgetProgress(
                  budget: b, spent: spentByCategory[b.category] ?? 0))
              .toList()
            ..sort((a, b) => b.ratio.compareTo(a.ratio));
        });
      },
    );
  }
}
```

- [ ] **Step 4: BudgetBloc**

Events: `BudgetLoadRequested()`, `BudgetMonthShifted(int delta)`, `BudgetSaveRequested({String? id, required String category, required String limitText, required bool isActive})`, `BudgetDeleteRequested(String id)`.
State: freezed `BudgetState({required int month, required int year, @Default(BudgetListStatus.initial) BudgetListStatus status, @Default(<BudgetProgress>[]) List<BudgetProgress> items, String? errorMessage})` with `enum BudgetListStatus { initial, loading, success, failure }`. Initial state from `DateTime.now()` month/year (constructor takes an optional `DateTime? now`).
- Load: loading → `GetBudgetProgress` → success/failure.
- MonthShifted: `final d = DateTime(state.year, state.month).addMonths(delta)` → update month/year → load.
- SaveRequested: `parseAmount(limitText)` null → `errorMessage: 'Enter a limit greater than 0'` (no save). Otherwise `SaveBudget(Budget(id: id ?? uuid.v4(), category, limit, month: state.month, year: state.year, isActive))`; Right → load; Left → errorMessage.
- DeleteRequested: `DeleteBudget(id)`; Right → load; Left → errorMessage.
Clear `errorMessage` at the start of each handler. Constructor: `BudgetBloc(GetBudgetProgress, SaveBudget, DeleteBudget, Uuid, {DateTime? now})`.

- [ ] **Step 5: UI**

- `BudgetProgressCard({required BudgetProgress item, required String currencyCode, VoidCallback? onTap})`: `Card` → `InkWell` → padding 16: row with `categoryIcon` avatar, category name, "`spent` of `limit`" text; `ClipRRect(radius 8) LinearProgressIndicator(value: item.progress, minHeight: 10)` coloured success/warning/danger per status (animate value with `TweenAnimationBuilder`, 500ms); status line: onTrack → "`remaining` left", warning → "`(ratio*100).round()`% used — nearing limit", exceeded → "Over by `formatCurrency(-remaining)`". Inactive budgets render at 50% opacity with an "Inactive" chip.
- `BudgetFormSheet`: `static Future<void> show(BuildContext context, {BudgetProgress? existing})` → modal bottom sheet (isScrollControlled, padded by `viewInsets`) with `DropdownButtonFormField<String>` over `AppCategories.expense`, limit `TextFormField` (decimal keyboard, validator via `parseAmount` → 'Enter a limit greater than 0'), `SwitchListTile('Active')`, `FilledButton('Save budget')` → `BudgetSaveRequested` then pop; when editing also a `TextButton('Delete', red)` → confirm → `BudgetDeleteRequested`. The sheet receives the page's `BudgetBloc` via `BlocProvider.value`.
- `BudgetPage`: AppBar "Budgets"; `MonthSelector` → `BudgetMonthShifted`; a summary `Card` (total spent of total limit across active budgets, overall `LinearProgressIndicator` clamped 0..1, guarded for total limit 0); list of `BudgetProgressCard`s (tap → edit sheet); empty → `EmptyState(icon: Icons.savings_outlined, message: 'No budgets for this month.\nTap Add budget to set one.')`; FAB `extended` "Add budget" → `BudgetFormSheet.show`. `BlocListener` shows errorMessage as SnackBar.

- [ ] **Step 6: DI and route**

```dart
void registerBudget(GetIt sl) {
  // Data sources
  sl.registerLazySingleton<BudgetLocalDataSource>(
      () => HiveBudgetLocalDataSource(Hive.box<BudgetModel>(HiveBoxes.budgets)));
  // Repositories
  sl.registerLazySingleton<BudgetRepository>(() => BudgetRepositoryImpl(sl()));
  // Use cases
  sl.registerFactory(() => GetBudgetProgress(sl(), sl()));
  sl.registerFactory(() => SaveBudget(sl()));
  sl.registerFactory(() => DeleteBudget(sl()));
  // BLoCs
  sl.registerFactory(() => BudgetBloc(sl(), sl(), sl(), const Uuid()));
}
```
`budgetRouteBuilder` → `BlocProvider(create: (_) => sl<BudgetBloc>()..add(const BudgetLoadRequested()), child: const BudgetPage())`.

- [ ] **Step 7: Generate, verify, commit**

`dart run build_runner build --delete-conflicting-outputs`, `flutter analyze` → `No issues found!`.
```bash
git add -A
git commit -m "feat: monthly budgets with progress tracking and warnings"
```

---

### Task 6: Analytics & Reports

**Files (only these):**
- Create: `lib/features/reports/domain/entities/report_data.dart`
- Create: `lib/features/reports/domain/usecases/get_report.dart`
- Create: `lib/features/reports/presentation/bloc/{reports_bloc.dart, reports_event.dart, reports_state.dart}`
- Create: `lib/features/reports/presentation/pages/reports_page.dart`
- Create: `lib/features/reports/presentation/widgets/{category_pie_chart.dart, income_expense_bar_chart.dart, report_summary_row.dart}`
- Modify: `lib/features/reports/reports_injection.dart`, `lib/features/reports/reports_routes.dart`

**Interfaces:**
- Consumes: `Transaction`, `TransactionType`, `TransactionRepository`, `EmptyState` (Task 2); `MonthSelector`, `formatCurrency`, `formatShortMonth`, `DateTimeX.addMonths`, `AppColors`, `SettingsBloc`, `sl` (Task 1).
- Produces: `reportsRouteBuilder`.

- [ ] **Step 1: Entities and use case**

```dart
@freezed
abstract class MonthlyTotal with _$MonthlyTotal {
  const factory MonthlyTotal({
    required int month,
    required int year,
    required double income,
    required double expense,
  }) = _MonthlyTotal;
}

@freezed
abstract class ReportData with _$ReportData {
  const ReportData._();

  const factory ReportData({
    required int month,
    required int year,
    required double totalIncome,
    required double totalExpense,
    /// Expense totals per category for the month, largest first.
    required Map<String, double> expenseByCategory,
    /// Oldest → newest, ending with the selected month.
    required List<MonthlyTotal> trend,
  }) = _ReportData;

  double get net => totalIncome - totalExpense;

  /// Null when there is no income (rate undefined).
  double? get savingsRate => totalIncome > 0 ? net / totalIncome : null;
}
```

```dart
class GetReport {
  const GetReport(this._repository);

  static const trendMonths = 6;

  final TransactionRepository _repository;

  Future<Either<Failure, ReportData>> call({required int month, required int year}) async {
    final result = await _repository.getTransactions();
    return result.map((txs) {
      final selected = DateTime(year, month);
      final trend = [
        for (var i = trendMonths - 1; i >= 0; i--) selected.addMonths(-i),
      ].map((m) {
        var income = 0.0, expense = 0.0;
        for (final t in txs) {
          if (t.date.year == m.year && t.date.month == m.month) {
            if (t.type == TransactionType.income) {
              income += t.amount;
            } else {
              expense += t.amount;
            }
          }
        }
        return MonthlyTotal(month: m.month, year: m.year, income: income, expense: expense);
      }).toList();

      final byCategory = <String, double>{};
      for (final t in txs) {
        if (t.type == TransactionType.expense &&
            t.date.year == year &&
            t.date.month == month) {
          byCategory.update(t.category, (v) => v + t.amount, ifAbsent: () => t.amount);
        }
      }
      final sorted = byCategory.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      final current = trend.last;
      return ReportData(
        month: month,
        year: year,
        totalIncome: current.income,
        totalExpense: current.expense,
        expenseByCategory: Map.fromEntries(sorted),
        trend: trend,
      );
    });
  }
}
```
Reports have no data layer of their own — they read `TransactionRepository`.

- [ ] **Step 2: ReportsBloc**

Events: `ReportsLoadRequested()`, `ReportsMonthShifted(int delta)`. State: freezed `ReportsState({required int month, required int year, @Default(ReportsStatus.initial) ReportsStatus status, ReportData? report, String? errorMessage})`, `enum ReportsStatus { initial, loading, success, failure }`; initial month/year from optional `DateTime? now` (default `DateTime.now()`). MonthShifted uses `DateTime(state.year, state.month).addMonths(delta)` then loads.

- [ ] **Step 3: Widgets and page**

Check the installed fl_chart 1.x API in `~/.pub-cache/hosted/pub.dev/fl_chart-*/lib` before writing chart code (e.g. `SideTitleWidget(meta: meta, child: ...)`).
- `ReportSummaryRow({required ReportData report, required String currencyCode})`: three compact cards — Income (success), Expenses (danger), Net (primary; danger when negative) — plus a line "Savings rate: `NN%`" or "Savings rate: —" when `savingsRate` is null.
- `CategoryPieChart({required Map<String, double> data, required String currencyCode})`: if data empty or total ≤ 0 → `EmptyState(icon: Icons.pie_chart_outline, message: 'No expenses this month')`. Else `PieChart` (height 220, `centerSpaceRadius: 48`, `sectionsSpace: 2`) with a section per category coloured from a fixed 8-colour palette starting `[AppColors.primary, AppColors.success, AppColors.warning, AppColors.danger, Color(0xFF8B5CF6), Color(0xFF06B6D4), Color(0xFFEC4899), Color(0xFF64748B)]` (cycled), title = percentage when ≥ 5% else empty; legend below: colour dot, category, amount, percent. Tapping a section enlarges it (track touched index in State).
- `IncomeExpenseBarChart({required List<MonthlyTotal> trend, required String currencyCode})`: if every income and expense is 0 → `EmptyState(icon: Icons.bar_chart, message: 'No data for the last 6 months')`. Else `BarChart` (height 240) with one `BarChartGroupData` per month, two rods (income `AppColors.success`, expense `AppColors.danger`, width 10, rounded top), `maxY = max * 1.2`, bottom titles `formatShortMonth`, left titles compact (`NumberFormat.compact()`), horizontal grid only, no border, tooltip showing `formatCurrency`. Legend row "Income" / "Expenses".
- `ReportsPage`: AppBar "Reports"; `MonthSelector` → `ReportsMonthShifted`; loading with no report → spinner; failure → EmptyState + Retry; else `ListView(padding 16)`: `ReportSummaryRow`, section "Spending by category" in a `Card` with `CategoryPieChart`, section "Income vs expenses" in a `Card` with `IncomeExpenseBarChart`. `RefreshIndicator` reloads.

- [ ] **Step 4: DI and route**

```dart
void registerReports(GetIt sl) {
  // Use cases
  sl.registerFactory(() => GetReport(sl()));
  // BLoCs
  sl.registerFactory(() => ReportsBloc(sl()));
}
```
`reportsRouteBuilder` → `BlocProvider(create: (_) => sl<ReportsBloc>()..add(const ReportsLoadRequested()), child: const ReportsPage())`.

- [ ] **Step 5: Generate, verify, commit**

`dart run build_runner build --delete-conflicting-outputs`, `flutter analyze` → `No issues found!`.
```bash
git add -A
git commit -m "feat: reports with category breakdown and income vs expense trend"
```

---

### Task 7: Integration clean-up and release verification

**Files:**
- Delete: `lib/core/widgets/placeholder_page.dart` (must be unreferenced after Tasks 2–6)
- Modify: `README.md`

**Interfaces:**
- Consumes: all features merged.

- [ ] **Step 1:** `grep -rn PlaceholderPage lib/` → expect only the file itself; delete it. If any route still references it, STOP and report BLOCKED.
- [ ] **Step 2:** Replace `README.md` with: one-paragraph description, feature list (Dashboard, Add Expense, Add Income, Transactions, Budgets, Reports, Settings), setup commands (`flutter pub get`, `dart run build_runner build --delete-conflicting-outputs`, `flutter run`), and the folder-structure summary from CLAUDE.md.
- [ ] **Step 3:** `dart run build_runner build --delete-conflicting-outputs` (expect no generated-file changes), `flutter analyze` → `No issues found!`, `flutter build web --release` → expect `✓ Built build/web`.
- [ ] **Step 4: Commit**
```bash
git add -A
git commit -m "chore: remove placeholders, document setup, verify release build"
```
