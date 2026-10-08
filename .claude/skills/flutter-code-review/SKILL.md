---
name: flutter-code-review
description: Project-specific review checklist for codezync_pos changes — clean architecture layering, error-handling boundaries, DI wiring, bloc conventions, UI/design-system consistency, and known inconsistencies not to propagate further. Use when reviewing a PR/diff or asked to review code in this repo, alongside (not instead of) a general code-review pass.
---

This is a **project-knowledge checklist**, not a substitute for a general
correctness/security review — pair it with that. Everything here is
specific to codezync_pos's actual conventions (verified against the
codebase, not generic Flutter advice) and points at the deeper skills
([flutter-clean-architecture](../flutter-clean-architecture/SKILL.md),
[flutter-bloc](../flutter-bloc/SKILL.md),
[flutter-ui-development](../flutter-ui-development/SKILL.md),
[flutter-unit-testing](../flutter-unit-testing/SKILL.md)) for the
reasoning behind each check.

## Layering

- [ ] `domain/` doesn't import from `data/` or `presentation/`.
- [ ] `presentation/` doesn't call a datasource, `Dio`, or `sqflite`
      directly — only a use case.
- [ ] A repository method never returns a `Model` — it maps to the
      domain `Entity` before wrapping in `Either`.
- [ ] New use cases default to the plain-class-with-`call()` style
      (majority pattern) unless the sibling use cases in that feature
      already use `UseCase<T, Params>`. Don't retrofit existing use
      cases onto the base class as a drive-by change.
- [ ] Nothing new was added to `lib/features/login/` — it's
      superseded/dead code; login changes belong in `lib/features/auth/`.

## Error handling

- [ ] Datasources throw typed `AppException` subclasses
      (`core/error/app_exception.dart`), never a raw `Exception` or a
      string.
- [ ] Only repository impls catch exceptions and convert to `Failure`
      (`core/error/failure.dart`) — use cases and datasources never
      produce `Either` themselves.
- [ ] A new `Failure`/`AppException` subclass pair was added (rather than
      reusing `UnknownFailure`) if a bloc needs to branch on the specific
      error kind.
- [ ] Where a repository branches within one `catch` block on error
      content (e.g. `AuthRepositoryImpl.login`'s `on NotFoundException`
      string-matching for "terminal"), the branching is easy to follow
      and each branch maps to a distinct, meaningful `Failure`.

## Dependency injection

- [ ] Every new datasource/repository/usecase/bloc has a corresponding
      registration in `lib/core/di/dependency_injection.dart`, in
      datasource → repository → usecase → bloc order.
- [ ] Datasources/repositories/use cases are `registerLazySingleton`;
      blocs are `registerFactory` unless the bloc genuinely needs to
      outlive the screen that creates it (e.g. `AppbarBloc`,
      `ActiveOrderBloc`), in which case `registerLazySingleton` is
      correct.
- [ ] New registrations are placed under the section comment matching
      their actual kind (`// Bloc...` for a bloc), even though existing
      code isn't 100% consistent about this — see
      [flutter-bloc](../flutter-bloc/SKILL.md)'s DI note.

## Bloc / state management

- [ ] New state classes: does this bloc call a use case (async, can
      fail)? If so it should use the per-status-subclass pattern
      (`Initial`/`Loading`/`Failure`/`Success`), matching sibling blocs
      in the feature — not a single `copyWith` state (that shape is only
      appropriate for a bloc with no async/failure path, like `CoinBloc`).
- [ ] Events and states extend `Equatable` and list every field that
      distinguishes instances in `props`.
- [ ] Cross-bloc reactions go through `BlocListener` + `context.read` at
      the widget level (the dominant pattern), or constructor injection
      of a live bloc instance for non-widget infra (like `SyncManager`)
      — not some new ad hoc coupling mechanism.
- [ ] A page's bloc is provided via `BlocProvider` at the `go_router`
      route builder, not fetched from `getIt` inside the page's own
      `initState()`/`build()` (the `cashier_screen.dart` pattern is a
      known exception, not a template).

## UI / design system

- [ ] No raw `Color(0x...)` literals in feature code — use
      `AppColors.xxx`.
- [ ] No new hardcoded breakpoint numbers — use the `k*Breakpoint`
      constants from `core/design_system/responsive/breakpoint.dart`.
- [ ] Before writing a new button/text-field/dialog widget, checked
      `lib/core/widgets/` for an existing one to reuse (see
      [flutter-ui-development](../flutter-ui-development/SKILL.md) for
      the catalog).
- [ ] Scaling/typography choice (`SizeConfig`, `ResponsiveText`, or
      `CustomTextPoppins`) matches whatever the surrounding file already
      uses, rather than introducing a fourth approach.
- [ ] New routes follow the `AppRoute`/`AppRouteNames`/`GoRoute` checklist
      in flutter-ui-development, including `state.extra` for params and
      `context.goNamed(...)` for navigation.

## Tests (if the PR adds or touches tests)

- [ ] `mocktail`/`bloc_test` are in `dev_dependencies` (not yet default —
      check `pubspec.yaml` before assuming they're available).
- [ ] Test file mirrors the `lib/` path exactly, including any
      inconsistent folder naming in the layer under test.
- [ ] Repository/bloc tests assert the **specific** `Failure`/state
      subtype (`isA<TerminalInvalidFailure>()`), not just `isA<Failure>()`.
- [ ] All collaborators a class constructor takes are mocked, not just
      the "obvious" one.

## Platform awareness

- [ ] Code gated to Android/iOS (Firebase Crashlytics/Messaging/Analytics)
      isn't assumed to run on the Windows desktop build — `main.dart`
      only initializes Firebase on `Platform.isAndroid || Platform.isIOS`.
- [ ] Local storage choice matches its purpose: `core/storage` (secure
      tokens/session), `core/hive_storage` (cart/customization cache +
      offline sync queue), `core/database` (structured relational cache)
      — not interchanged.
- [ ] For a UI-visible change, verify it actually renders using
      [run-codezync-pos](../run-codezync-pos/SKILL.md) rather than
      relying on `flutter analyze`/tests alone.
