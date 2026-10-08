# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

A modern Flutter personal finance management POC with Clean Architecture, featuring dashboard, income/expense tracking, budgets, and analytics.

---

## Current Status

This is a starter Flutter project. The basic structure is in place but implementation of features is pending. Only essential dependencies are currently configured.

---

## Tech Stack

- **Flutter** (3.11+) — cross-platform mobile framework
- **Material 3** — modern design system
- **Clean Architecture** — feature-first, layered separation of concerns
- **BLoC** (flutter_bloc) — state management
- **GoRouter** — navigation and routing
- **Hive** — local persistence (NoSQL)
- **Freezed** — immutable data classes and union types
- **JSON Serializable** — JSON serialization/deserialization
- **Injectable + GetIt** — dependency injection and service locator
- **intl** — internationalization and number/date formatting
- **fl_chart** — charts and analytics visualization
- **Responsive Layout** — mobile-first design

---

## Folder Structure

```
lib/
  core/                    # Shared infrastructure
    config/              # App configuration (router, theme)
    di/                  # Dependency injection setup
    utils/               # Utility functions and constants
  features/              # Feature modules (feature-first)
    dashboard/           # Dashboard feature
    income/              # Income tracking
    expenses/            # Expense tracking
    budget/              # Budget management
    reports/             # Analytics and reports
    settings/            # App settings
  shared/               # Widgets and utils shared across features
```

Each feature follows the three-layer Clean Architecture pattern.

---

## Common Commands

```bash
# Setup & dependencies
flutter pub get
flutter pub upgrade
flutter pub run build_runner build --delete-conflicting-outputs

# Development
flutter run                          # Run on default device
flutter run -d chrome               # Run web version
flutter run --debug                 # Debug mode (default)
flutter run --release               # Release mode

# Code generation & analysis
flutter pub run build_runner build   # Generate code (freezed, json_serializable, injectable)
dart fix --apply                     # Apply automated fixes
dart analyze                         # Static analysis

# Building
flutter build apk --release          # Android APK release
flutter build ios --release          # iOS release
flutter build web --release          # Web build

# Clean & reset
flutter clean                        # Remove build artifacts
flutter pub get                      # Reinstall dependencies

# Testing
flutter test                         # Run all tests
flutter test test/features/          # Run feature-specific tests
flutter test test/features/dashboard # Single test file
```

---

## Architecture Overview

### Clean Architecture Layers

Each feature is divided into three layers:

**Presentation Layer** (`features/*/presentation/`)
- Pages & Screens — full-page widgets
- BLoCs — business logic via flutter_bloc, state management
- Widgets — reusable UI components
- Delegates — event handlers and listeners

**Domain Layer** (`features/*/domain/`)
- Entities — core business objects, immutable (via freezed)
- Repositories — abstract interfaces defining contracts
- Use Cases — business logic operations, plain classes with `call()` method

**Data Layer** (`features/*/data/`)
- Models — serializable versions of entities (json_serializable)
- Repository Implementations — concrete implementations using local/remote storage
- Data Sources — local Hive database access or remote API calls

### State Management Flow

```
User Action (UI)
  ↓
BLoC Event
  ↓
Use Case Execution
  ↓
Repository Call
  ↓
Data Source (Hive/API)
  ↓
Return Entity/Failure
  ↓
BLoC State Emission
  ↓
UI Rebuild (BlocBuilder listener)
```

Example: Adding an expense

```
ExpenseInputPage (UI)
  → AddExpenseBLoC.add(AddExpenseEvent)
    → AddExpenseUseCase.call()
      → ExpenseRepository.addExpense()
        → HiveExpenseDataSource.saveExpense()
          → Hive box writes locally
        → Returns Either<Failure, void>
      → Returns Either<Failure, void>
    → Emits ExpenseAdded state
  → UI listens and shows success/error
```

### Dependency Injection

`lib/core/di/injection_container.dart` manages all dependencies:
- **Data Sources** — registered as singletons
- **Repositories** — registered as singletons
- **Use Cases** — registered as factories
- **BLoCs** — registered as factories (new instance per request)

Use `getIt<RepositoryName>()` to access dependencies in BLoCs and use cases.

---

## Key Patterns

### Adding a New Feature

1. Create feature folder: `lib/features/feature_name/`
2. Create three-layer structure:
   - `presentation/pages/`, `presentation/bloc/`, `presentation/widgets/`
   - `domain/entities/`, `domain/repositories/`, `domain/usecases/`
   - `data/models/`, `data/datasources/`, `data/repositories_impl/`
3. Register dependencies in `lib/core/di/injection_container.dart`
4. Add route to `lib/core/config/router.dart`
5. Add bottom nav link in `lib/core/widgets/app_bottom_nav.dart`

### BLoC Event-to-State Pattern

Every BLoC should have a clear event → state flow:
- **Events** — user actions or external triggers
- **States** — UI states (initial, loading, success, error)
- Use `freezed` or `Equatable` for state equality
- Emit states only once; avoid duplicate emissions
- Group related events and states logically

### Data Models with Freezed

```dart
@freezed
class Transaction with _$Transaction {
  factory Transaction({
    required String id,
    required double amount,
    required DateTime date,
    required String category,
  }) = _Transaction;
  
  factory Transaction.fromJson(Map<String, dynamic> json) =>
      _$TransactionFromJson(json);
}
```

Freezed auto-generates `copyWith()`, equality, `toString()`, and JSON serialization.

### Hive Local Storage

- Hive models must extend `HiveType` with `@HiveType()` annotation
- Each Hive box represents one entity collection (transactions, budgets, income, etc.)
- Use `lazy: false` for small, frequently-accessed boxes
- Query using Hive's built-in filtering methods
- Initialize and register all Hive adapters in `lib/core/di/hive_setup.dart` before app startup

---

## UI Theme & Design

Create a premium finance application following Material 3 guidelines.

### Style Principles
- Modern and minimal
- Soft shadows and rounded corners
- Glassmorphism where appropriate
- Smooth animations and transitions
- Responsive layout (mobile-first)
- Dark mode support

### Color Palette

| Role | Color | Hex |
|------|-------|-----|
| Primary | Blue | #2563EB |
| Success | Green | #22C55E |
| Warning | Amber | #F59E0B |
| Danger | Red | #EF4444 |
| Background | Light | #F8FAFC |
| Cards | White | #FFFFFF |

---

## Development Workflow

1. **Feature Design** — Define UI mockups and data models first
2. **Bottom-up Development**:
   - Domain layer (entities, repositories, use cases)
   - Data layer (models, datasources, repository implementations)
   - Presentation layer (pages, BLoCs, widgets)
3. **Code Generation** — After modifying freezed/injectable classes:
   ```bash
   flutter pub run build_runner build
   ```
4. **Manual Testing** — Run app and test feature end-to-end
5. **Polish** — Add animations, error handling, loading states
6. **Integration** — Wire into navigation and bottom navigation

---

## Responsive Layout

Use `MediaQuery` and `LayoutBuilder` for responsive design:
- **Mobile** — Single column, full width (primary target)
- **Tablet** — Two columns or side panels (secondary)
- **Desktop** — Multi-panel layout (if needed)

The app prioritizes mobile-first design.

---

## Performance Optimization

- Use `const` constructors aggressively to avoid rebuilds
- Prefer `BlocBuilder` with selective listeners over rebuilding entire screens
- Implement pagination for long transaction lists (future enhancement)
- Cache Hive box queries to avoid repeated lookups
- Lazy-load dashboard charts only when tabs become visible
- Use `BlocListener` for side effects, not state rebuilds

---

## Troubleshooting

**Build fails after modifying freezed/injectable classes?**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
flutter clean && flutter pub get
```

**Hive box errors on app startup?**
Check `lib/core/di/hive_setup.dart` — ensure all Hive type adapters are registered before opening boxes.

**BLoC state not updating?**
Verify events are emitted correctly and states are different objects (not the same reference). Use `freezed` for automatic equality checks.

**Charts not rendering?**
Ensure dummy data exists in `lib/core/data/dummy_data.dart` and transactions are in the Hive box before rendering.

**Hot reload not reflecting changes?**
Use hot restart (`R` in terminal) instead of hot reload (`r`) after changing:
- Freezed data models
- Hive type adapters
- Dependency injection setup
- Global theme or constants

---

## Do's and Don'ts

### Do

- Follow Clean Architecture strictly — separate presentation, domain, and data layers
- Use `Either<Failure, T>` return types from repositories to handle errors gracefully
- Throw typed `AppException` subclasses from data sources, convert to `Failure` in repository implementations
- Create a new `Failure` subclass when BLoCs need to branch on error kind
- Register new datasource/repository/usecase/bloc in `lib/core/di/injection_container.dart` under the appropriate section comment, in dependency order
- Default new use cases to the plain-class-with-`call()` style
- Provide a page's BLoC via `BlocProvider` at the GoRouter route builder (not via `getIt` inside `build()`)
- Put secrets and configuration in `.env` (already gitignored)
- Use immutable data classes everywhere (via `freezed`) for predictable state management
- Verify UI works across all supported platforms (Android, iOS, web) if making layout changes
- Write tests only when explicitly requested (focus on feature implementation first)

### Don't

- Don't add abstractions or error handling beyond what the task requires
- Don't let a repository return a `Model` or raw exception from a public method — always return `Either<Failure, Entity>`
- Don't reuse `UnknownFailure` when a BLoC needs to branch on error; create a specific failure type
- Don't have datasources or use cases return `Either` directly — only repository implementations should
- Don't have a page reach into `getIt` for its own BLoC inside `build()` — inject via `BlocProvider` at the route
- Don't commit secrets to `.env*` files or `firebase_options.dart`
- Don't mix concerns across layers (e.g., database queries in BLoC, business logic in widgets)
- Don't mutate entities or models after creation — always create new instances with `copyWith()`
- Don't assume testing packages are available — check `pubspec.yaml` first

---

## Future Extensions

- **Backend Integration** — Replace Hive repositories with API calls; domain/presentation layers remain unchanged
- **Cloud Sync** — Add Firebase Firestore for cross-device synchronization
- **Recurring Transactions** — Implement scheduling with background jobs
- **Budget Alerts** — Add push notifications for budget overages
- **Multi-currency Support** — Add conversion rates and currency selector
- **Data Export** — CSV/PDF export functionality
- **Advanced Analytics** — Trends, forecasting, spending insights
