---
name: flutter-routing-auth
description: Use when adding/changing a route in CodeZync POS, touching TerminalGate/TerminalBloc, or working on anything auth-related (features/auth, features/login, terminal pairing/validation, session-open gating). Documents the real TerminalGate decision tree, the go_router wiring conventions, the state.extra typed-data pattern, and the split between the primary auth flow and the PIN re-auth flow.
---

# Routing & Auth Gating (CodeZync POS)

`go_router` here does almost no work itself — there is **no `redirect:` callback
anywhere in `app_router.dart`**. All gating happens imperatively inside
`TerminalGate` (`lib/features/terminal/presentation/page/terminal_gate.dart`),
the app's `initialLocation`. Read that file in full before touching routing or
auth — it is dense, stateful, and every comment in it exists because of a real
race condition someone already hit.

## 1. How routes are declared (mechanical, low-risk part)

Three files, always touched together for a new route:

1. `lib/core/router/app_route.dart` — path string constant, e.g.
   `static const String openSession = '/open-session';`
2. `lib/core/router/app_route_names.dart` — matching name constant, same key,
   e.g. `static const String openSession = 'openSession';`
3. `lib/core/router/app_router.dart` — a `GoRoute` entry using both:

```dart
GoRoute(
  path: AppRoute.openSession,
  name: AppRouteNames.openSession,
  builder: (context, state) => BlocProvider(
    create: (context) => getIt<LocationBloc>(),
    child: AddSessionScreen(terminal: state.extra as TerminalEntity?),
  ),
),
```

- If the screen needs a screen-scoped BLoC, wrap it inline with
  `BlocProvider(create: (context) => getIt<XBloc>(), ...)` — the BLoC must
  already be `registerFactory`'d in `dependency_injection.dart` (see the DI
  skill). Do not use a `MultiBlocProvider` per route; this codebase doesn't.
- Navigate with `context.goNamed(AppRouteNames.x)`, not with raw path strings
  — every navigation call in `TerminalGate` and elsewhere uses the name.

### The `state.extra` typed-data pattern

Passing a domain object to a route goes through `extra`, which is `Object?` —
there is **no compile-time type safety**, only a runtime cast at the receiving
end:

```dart
// sender (TerminalGate):
context.goNamed(AppRouteNames.openSession, extra: validatedTerminal);

// receiver (app_router.dart):
child: AddSessionScreen(terminal: state.extra as TerminalEntity?),
```

Always cast with `as T?` (nullable), never `as T` — a hot-restart, deep link,
or a future caller that forgets to pass `extra` will otherwise crash on a
`null as TerminalEntity` cast instead of failing gracefully inside the screen.
The receiving screen must handle the `null` case explicitly (don't assume
`extra` is always populated just because today's only caller passes it).

## 2. TerminalGate: the real decision tree

`TerminalGate` listens to **three independent, app-lifetime BLoCs**
(`TerminalBloc`, `UserSessionBloc`, `SessionBloc` — all provided app-wide in
`codezync_pos_app.dart`, not per-route) and re-runs `_performNavigation()`
every time any one of them emits. It does not use go_router redirects because
the decision genuinely depends on three async, independently-resolving
sources of truth.

Sequence on cold start:

1. `initState` fires `GetSavedTerminalRequestedEvent` (TerminalBloc) and
   `LoadCachedUserEvent` (UserSessionBloc) concurrently.
2. `TerminalBloc` resolves to `TerminalLoaded(terminal)` (found a locally
   paired terminal) or `TerminalNotFoundState` (never paired).
3. `TerminalLoaded` triggers `checkSession()` → dispatches
   `ValidateTerminalRequestedEvent`, which calls the backend to confirm the
   terminal is still authorized. **This always happens regardless of whether a
   user is logged in** — terminal validation is authenticated via the
   terminal's own device key (`AuthInterceptor`), not the user session token,
   so a decommissioned terminal must be caught even while signed out.
4. Validation resolves to one of:
   - `TerminalValidatedState` — server confirmed the terminal, online.
   - `TerminalOfflineState` — server unreachable (no network, or the offline
     lease window expired per `OfflineLeaseExpiredFailure`), but the terminal
     was never rejected. Carries the last-known-good cached terminal so the
     app keeps working offline instead of forcing re-pairing. A snackbar
     ("You're offline — working with the last synced terminal data.") is
     shown for this case.
   - `TerminalFailureState` — the server explicitly rejected the terminal
     (`NotFoundFailure`/`TerminalInvalidFailure`: decommissioned, unauthorized,
     or not found) → **routes to `terminal` (pairing)**.
   - `TerminalNotFoundState` — never paired locally → **routes to
     `terminal` (pairing)**.
   - `TerminalUnauthorizedState` — routes to `login`. Note: nothing in
     `TerminalBloc` currently emits this state — it's a dead branch in
     `_performNavigation()` today. If you add a code path that should force a
     re-login without invalidating the terminal pairing, this is the state to
     emit; don't invent a new one.
5. On `TerminalValidatedState`/`TerminalOfflineState`,
   `_proceedPastValidTerminal()` checks `SecureStorage.getToken()`:
   - No token → **routes to `login`**.
   - Token present → resets and refetches `SessionBloc`
     (`ResetSessionEvent` then `GetSessionEvent`) for *this* terminal
     identity, and sets `_awaitingSessionRefresh = true` so
     `_performNavigation()` ignores any stale `SessionBloc` state left over
     from a previous terminal/session until a real result comes back. This
     flag exists because `SessionBloc` is an app-lifetime singleton — after a
     re-pair it can still be sitting on a `SessionLoaded(open)` from a
     *different* terminal, and reading it during the async gap of the
     `SecureStorage` call would wrongly skip the open-session screen.
6. Once `SessionBloc` produces a real result:
   - `SessionLoaded` with `status == SessionStatus.open` → **routes to
     `base`** (the main POS screen).
   - `NoActiveSession` → checks
     `PermissionChecker(permissions: user.permissions).canOpenSessions`:
     - can open → **routes to `openSession`**, passing the validated
       `TerminalEntity` via `extra`.
     - cannot → **routes to `cashier`** (cashier picks/re-authenticates
       instead of opening a session directly).
   - `SessionFailure` → shows a snackbar with a retry action that re-dispatches
     `GetSessionEvent`; does not navigate.

If you need to add a new gating condition (a new required setup step, a forced
password reset, etc.), add it inside `_performNavigation()` in the same
if/else-early-return style — don't try to express it as a go_router
`redirect:`, since none of the sibling conditions are expressed that way and
mixing the two gating mechanisms would make the flow harder to reason about.

## 3. `features/auth` vs `features/login` — both are live, for different jobs

- **`features/auth`** — the primary username/password login, reached via the
  `login` route (`AppRouteNames.login`) from `TerminalGate` when there's no
  session token. Uses `AuthLoginBloc` (registered in DI, provided per-route via
  `BlocProvider` in `app_router.dart`), backed by a real remote datasource
  (`auth_remote_datasource.dart`) hitting the API. Also owns `UserSessionBloc`
  (app-wide, caches the logged-in user + permissions used throughout the app,
  e.g. by `PermissionChecker` in `TerminalGate`).
- **`features/login`** — a separate PIN/password **re-authentication** dialog
  (`LoginDialog`, its own `LoginBloc`/`AuthUsecase`/`AuthRepositoryImpl`),
  shown inline from `CashierScreen._showLoginDialog()` when tapping a cashier
  tile to continue or start a session (`CashierSessionType.continueSession` /
  `.newSession`). This is a *different* class hierarchy from `features/auth`
  despite near-identical file names (`login_bloc.dart`, `login_state.dart`,
  `auth_entity.dart` exist in both features) — don't cross-import between them,
  and don't assume editing one touches the other.
- **Known rough edge, be careful here**: `LoginDialog` currently constructs its
  `LoginBloc`/`AuthUsecase`/`AuthRepositoryImpl`/`AuthLocalDatasourceImpl`
  **manually inline** (`initState` → `LoginBloc(authUsecase: AuthUsecase(...))`)
  instead of resolving them from `getIt` — none of this stack is registered in
  `dependency_injection.dart`. And `AuthLocalDatasourceImpl.login()` is a
  hardcoded stub (`if (password == '123123')`) — it does not check anything
  real yet. If you're asked to make this re-auth flow actually validate against
  the cashier's real credentials, that stub is where the work goes, and while
  you're there, move construction into DI (`registerFactory`) as
  `flutter-clear-architecture` and `flutter-di-bootstrap` describe, rather than
  perpetuating the manual-construction pattern.

## 4. Sanity checklist

- [ ] New route has matching entries in `app_route.dart` and
      `app_route_names.dart`, and is navigated to via `context.goNamed(...)`
      everywhere (not raw path strings).
- [ ] Any `state.extra` cast is nullable (`as T?`) and the receiving widget
      handles `null`.
- [ ] New gating logic lives inside `TerminalGate._performNavigation()`
      alongside the existing conditions, not as a go_router `redirect:`.
- [ ] Before adding a state to `TerminalState`, confirm an existing one
      (including the currently-unused `TerminalUnauthorizedState`) doesn't
      already cover the case.
- [ ] Changes to cashier re-auth go through `features/login`; changes to the
      primary sign-in flow or cached-user/permissions go through
      `features/auth`. Don't merge the two stacks.
- [ ] Any new BLoC touched by `LoginDialog` gets registered in `getIt` rather
      than constructed inline, unless you have a specific reason to keep
      following the existing (non-standard) manual-construction pattern.
