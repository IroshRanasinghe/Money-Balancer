# Money Balance

A modern Flutter personal finance management application with Clean Architecture. Money Balance helps users track their income and expenses, manage budgets, and analyze spending patterns with offline-first Hive storage and dark mode support.

## Features

- **Dashboard** — Overview of current month totals and recent transactions
- **Add Expense** — Quickly log expenses with category, amount, and payment method
- **Add Income** — Track income sources with category, date and optional notes
- **Transactions** — View, edit, and delete all transaction history with filtering
- **Budgets** — Set and monitor category budgets with progress tracking
- **Reports** — Visualize spending trends with interactive charts and analytics
- **Settings** — Configure currency, dark mode, and app preferences

## Getting Started

### Prerequisites
- Flutter 3.11 or higher
- Dart SDK (included with Flutter)

### Setup

```bash
# Install dependencies
flutter pub get

# Generate code (freezed, json_serializable)
dart run build_runner build --delete-conflicting-outputs

# Run the app
flutter run
```

### Build for Release

```bash
flutter build web --release      # Web build
flutter build apk --release       # Android APK
flutter build ios --release       # iOS app
```

## Premium (RevenueCat)

Free plan limits (accounts, cards, budgets, recurring items, CSV export) are lifted by a `premium` entitlement managed in RevenueCat. Configure the products, the `premium` entitlement and the current offering (monthly, yearly with a 7-day trial) in the RevenueCat dashboard. SDK keys are never stored in code; pass them at build time:

```bash
flutter run \
  --dart-define=REVENUECAT_APPLE_KEY=appl_xxx \
  --dart-define=REVENUECAT_GOOGLE_KEY=goog_xxx
```

Without a key for the platform (and always on web and desktop) the app uses a "store unavailable" mode. In debug builds the paywall then shows a "Debug: premium enabled" switch to test limits. iOS also needs the In-App Purchase capability enabled in Xcode.

## Project Structure

```
lib/
  core/                    # Shared infrastructure
    config/              # App configuration (router, theme)
    di/                  # Dependency injection setup
    error/               # Exception and failure handling
    hive/                # Hive adapter setup
    utils/               # Utility functions and constants
    widgets/             # Shared UI components
  features/              # Feature modules (feature-first)
    budget/              # Budget management
      data/            # Models and repository implementations
      domain/          # Entities and use cases
      presentation/    # Pages, BLoCs, and widgets
    dashboard/           # Dashboard feature
      domain/          # Entities and use cases
      presentation/    # Pages, BLoCs, and widgets
    expense/             # Expense tracking
      domain/          # Entities and use cases
      presentation/    # Pages, BLoCs, and widgets
    income/              # Income tracking
      domain/          # Entities and use cases
      presentation/    # Pages, BLoCs, and widgets
    reports/             # Analytics and reports
      domain/          # Entities and use cases
      presentation/    # Pages, BLoCs, and widgets
    settings/            # App settings
      data/            # Models and repository implementations
      domain/          # Entities and use cases
      presentation/    # Pages, BLoCs, and widgets
    transactions/        # Transaction management
      data/            # Models and repository implementations
      domain/          # Entities and use cases
      presentation/    # Pages, BLoCs, and widgets
  shared/                # Shared utilities and widgets
    widgets/           # Reusable UI components
```

Features follow the Clean Architecture layering: presentation (UI/BLoC), domain (business logic), and data (repositories/data sources). Only budget, settings and transactions have their own data layer; dashboard, expense, income and reports reuse the transactions repository.

## Technology Stack

- **Flutter** — Cross-platform mobile framework
- **Material 3** — Modern design system
- **BLoC** — State management
- **GoRouter** — Navigation and routing
- **Hive** — Local persistence (offline-first)
- **Freezed** — Immutable data classes
- **GetIt** — Dependency injection (manual registration)

## Architecture

The app follows Clean Architecture principles with feature-first organization:

- **Presentation Layer** — Pages, BLoCs, and UI widgets
- **Domain Layer** — Business entities and use cases
- **Data Layer** — Repositories and data sources (Hive)
