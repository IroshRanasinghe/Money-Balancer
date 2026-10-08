---
name: flutter-di-bootstrap
description: Use when registering something new in GetIt (lib/core/di/dependency_injection.dart), touching app startup order (lib/main.dart), or deciding whether a BLoC belongs in the app-wide MultiBlocProvider (lib/codezync_pos_app.dart) versus a per-route BlocProvider (lib/core/router/app_router.dart). Documents the real bootstrap sequence, GetIt lifetime rules actually used in this codebase, and known DI smells to not replicate.
---

# DI & App Bootstrap (CodeZync POS)

This is the authoritative reference for the GetIt container and the app's startup
sequence. `flutter-clear-architecture` covers *what* to register for a new
feature; this skill covers *how the container and bootstrap actually work* —
lifetimes, ordering, sharing, and gotchas that are easy to get wrong.

## 1. Bootstrap sequence (`lib/main.dart`)

The real, current order is:

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();          // Hive boxes usable after this
  await dotenv.load();               // BASE_URL / AUTH_URL / S3_* become available
  await init();                      // GetIt registration (core/di/dependency_injection.dart)
  getIt<SyncManager>().initialize(); // starts connectivity_plus listener AFTER DI is ready

  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    await Firebase.initializeApp(...);   // Crashlytics + FCM wiring
  }

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);                                 // orientation lock, right before runApp

  runApp(const CodezyncPosApp());
}
```

Rules that follow from this:
- `dotenv.load()` **must** run before `init()` — `ApiClient._setupDio()` reads
  `dotenv.env['BASE_URL']`/`['AUTH_URL']` synchronously at construction time via
  `ApiClient.regular(Dio())` inside `init()`. If you reorder these, every
  request throws a null-check error on the base URL.
- `Hive.initFlutter()` must run before anything touches
  `CustomizationStorageManager` (registered inside `init()`, opens boxes lazily
  on first use) — keep it ahead of `init()`.
- `getIt<SyncManager>().initialize()` is called explicitly outside `init()` —
  registration and activation are deliberately separate. If you add another
  service that needs to start listening/polling at launch (not just be
  constructible), follow this same split: register it lazily inside `init()`,
  then explicitly call its `initialize()`/`start()` in `main()` after `init()`
  resolves. Don't start side-effecting work inside a GetIt factory closure.
- `Firebase.initializeApp` and the orientation lock happen **after** `init()`
  and have no dependency on it — don't move DI setup after them.

## 2. GetIt lifetime rules

Only two registration styles are used anywhere in this codebase today —
`registerLazySingleton` and `registerFactory`. `registerSingleton` (eager) is
**not used at all**; don't introduce it without a specific reason, since
nothing else in the container expects eager construction.

| Lifetime | Used for | Why |
|---|---|---|
| `registerLazySingleton` | Datasources, repositories, use cases, shared infra (`ApiClient`, `Database`, `SecureStorage`, `CustomizationStorageManager`, `SyncManager`) | These are stateless (or hold shared/cached state that's meant to be shared) and side-effect-free to construct. One instance for the app's lifetime, built on first resolution. |
| `registerFactory` | Screen-scoped BLoCs (`CashierScreenBloc`, `TableBloc`, `LocationBloc`, `MenuBloc`, `TerminalBloc`, `AuthLoginBloc`, `SessionBloc`, ...) | A fresh instance per `getIt<XBloc>()` call, so leaving a screen and coming back doesn't leak the previous visit's state into a stale BLoC instance. |

Two real exceptions to the "BLoCs are factories" rule exist —
`ActiveOrderBloc` and `AppbarBloc` are registered with
`registerLazySingleton`, not `registerFactory` (see
`dependency_injection.dart:328` and `:355`). Both are provided app-wide via
`BlocProvider.value` in `codezync_pos_app.dart` and are meant to survive the
whole session, not be scoped to one screen — that's *why* they're singletons.
**If a BLoC is only ever provided per-route, it must be a factory.** Only make
a BLoC a lazy singleton if it is genuinely intended to be shared/persist across
the whole app session (mirror `ActiveOrderBloc`/`AppbarBloc`, not the norm).

GetIt resolves lazy singletons' dependencies **at first access**, not at
registration time — so registration order inside `init()` mostly doesn't
matter for `getIt()` calls used as constructor args (they're closures,
evaluated later). The two things that genuinely must happen eagerly, in order,
before any registration:

```dart
final storage = FlutterSecureStorage();
final databaseHelper = DatabaseHelper();
final database = await databaseHelper.database;   // opens the sqflite DB now
```

These are plain local variables computed *before* the `getIt.register...`
calls because `database` needs an `await` — GetIt registration closures
themselves aren't `async`, so anything requiring `await` to produce the
instance must be resolved up front like this, not inside a
`registerLazySingleton(() => ...)` closure.

## 3. Registering a new feature's full stack

`dependency_injection.dart` is organized into four labeled blocks, in this
order: `// Datasource...`, `// repository...`, `// Usecase...`,
`// Bloc...` (plus a final `// Sync Manager` block at the very end). Add new
registrations to the matching block, not at the bottom of the file. Follow the
session feature as the template:

```dart
// 1. imports — grouped near other feature imports, e.g.:
import '../../features/session/data/datasource/session_remote_datasource.dart';
import '../../features/session/data/repository/session_repository_impl.dart';
import '../../features/session/domain/repository/session_repository.dart';
import '../../features/session/domain/usecase/open_session_usecase.dart';
import '../../features/session/presentation/bloc/session_bloc.dart';

// 2. in the "// Datasource..." block:
getIt.registerLazySingleton<SessionRemoteDatasource>(
  () => SessionRemoteDatasourceImpl(client: getIt()),
);
getIt.registerLazySingleton<SessionLocalDatasource>(
  () => SessionLocalDatasourceImpl(database: getIt()),
);

// 3. in the "// repository..." block:
getIt.registerLazySingleton<SessionRepository>(
  () => SessionRepositoryImpl(datasource: getIt(), localDatasource: getIt()),
);

// 4. in the "// Usecase..." block, one line per use case:
getIt.registerLazySingleton(() => OpenSessionUseCase(repository: getIt()));

// 5. in the "// Bloc..." block:
getIt.registerFactory(
  () => SessionBloc(openSessionUseCase: getIt(), /* ...other usecases */),
);
```

Always register the **interface** type as the generic parameter
(`registerLazySingleton<SessionRepository>(() => SessionRepositoryImpl(...))`),
never the concrete impl type — every existing repository/datasource
registration does this, and it's what lets tests override with a fake later.

## 4. Where a BLoC gets provided to the widget tree

Three patterns exist in this codebase today — pick the first that fits, don't
default to the third:

1. **Per-route `BlocProvider`** (preferred default) — in
   `app_router.dart`, wrap the route's screen inline:
   ```dart
   GoRoute(
     path: AppRoute.openSession,
     builder: (context, state) => BlocProvider(
       create: (context) => getIt<LocationBloc>(),
       child: AddSessionScreen(...),
     ),
   ),
   ```
   Use this whenever the BLoC's state is only relevant to that one screen and
   its children.

2. **App-wide `MultiBlocProvider`** (`lib/codezync_pos_app.dart`) — for BLoCs
   that must exist before `TerminalGate` even runs, or must survive
   navigation across many screens (drawer/appbar/cart/active-order state,
   `TerminalBloc`, `SessionBloc`, `UserSessionBloc`, `CartBloc`,
   `ActiveOrderBloc`, etc.). Some are provided with `BlocProvider.value` (the
   BLoC is a `registerLazySingleton`, e.g. `ActiveOrderBloc`, `AppbarBloc`,
   `NavigationDrawerBloc`) and some with `BlocProvider(create: ...)` even
   though most of these resolve to the same singleton via `getIt` either way
   for singleton-registered blocs — for **factory**-registered blocs put here
   (`TerminalBloc`, `SessionBloc`, `CartBloc`, ...), always use
   `BlocProvider(create: (context) => getIt<XBloc>())`, not `.value`, or
   you'll get a *new* instance built once but never disposed correctly.
   Only add a BLoC here if it genuinely needs to be reachable from more than
   one route/screen simultaneously — this list is already long; don't grow it
   for screen-local state.

3. **Self-provisioned in `initState`** — `CashierScreen` calls
   `getIt<CashierScreenBloc>()` itself and wraps its own subtree with
   `BlocProvider.value`, and its route in `app_router.dart` has no
   `BlocProvider` at all. This is legacy and inconsistent with the rest of the
   app — **don't copy this pattern for new screens**; use the per-route
   `BlocProvider` approach (option 1) instead. Only touch this pattern if
   you're already modifying `CashierScreen` for another reason.

## 5. Known DI/architecture smell — don't replicate

`SyncManager` (a core infra service, not a presentation object) is
constructed with a direct dependency on `ActiveOrderBloc`:

```dart
getIt.registerLazySingleton<SyncManager>(
  () => SyncManager(
    storageManager: getIt(),
    createOrderUseCase: getIt(),
    cancelOrderUseCase: getIt(),
    activeOrderBloc: getIt(),   // <- a core service holding a presentation-layer BLoC
  ),
);
```

This breaks the intended `presentation -> domain <- data` direction (a core
service should call back into the domain/use-case layer, or expose a stream
the BLoC listens to — not reach *up* into a BLoC to mutate UI state directly).
It's existing, working code — don't refactor it as a drive-by — but **do not
use it as a precedent** when wiring a new core service. If a new
core/sync-style service needs to notify the UI, expose a `Stream`/`ValueNotifier`
from the service and have the relevant BLoC listen to it, rather than
injecting a BLoC into a core service.

## 6. `ApiClient` sharing — only one client is actually wired up

Only the regular client is registered:

```dart
getIt.registerLazySingleton<ApiClient>(() => ApiClient.regular(Dio()));
```

Every datasource that takes `client: getIt()` gets this same shared
`BASE_URL`-configured instance (confirmed for auth, session, user, location,
menu, terminal, and orders datasources). `ApiClient.auth()` (the
`AUTH_URL`/Keycloak-style factory constructor described in `dio_api_client.dart`)
**exists in code but is not registered anywhere in GetIt and has no call
site** — it's currently dead code, not an active second client. Note also
that `features/auth`'s `AuthRemoteDatasourceImpl.login` calls
`ApiEndpoints.pinLogin` through the *regular* client, not an auth-specific
one — the CLAUDE.md description of `auth` as the "primary username/password"
flow vs `login` as "PIN re-auth" doesn't cleanly match what's wired today;
verify against current code before assuming which flow owns which client. If
you add a feature that genuinely needs the Keycloak/`AUTH_URL` endpoint,
register it explicitly:
```dart
getIt.registerLazySingleton<ApiClient>(
  () => ApiClient.auth(),
  instanceName: 'authClient',
);
```
and resolve it with `getIt<ApiClient>(instanceName: 'authClient')` — don't
silently reuse the regular singleton for auth-only endpoints.

## 7. No test-time DI override exists yet

There is no `getIt.reset()` / `getIt.allowReassignment` usage anywhere in
`lib/` or `test/` today — the container has never been overridden for tests.
If you add unit/widget tests that need a fake repository or use case (see
`flutter-testing-strategy`), you'll need to introduce this yourself:
call `getIt.reset()` in `setUp()`/`tearDown()` and re-register fakes, or avoid
GetIt entirely in the test by constructing the class under test with
explicit fake constructor args instead of pulling from the container. Prefer
the latter for use case/repository/BLoC unit tests — reach for GetIt
overriding only for wider integration-style tests that exercise real
`app_router.dart` routes.

## 8. Checklist for any DI change

- [ ] New registration placed in the correct labeled block
      (`Datasource` / `repository` / `Usecase` / `Bloc`), interface type used
      as the generic parameter.
- [ ] Datasources/repositories/use cases/shared infra → `registerLazySingleton`;
      screen-scoped BLoCs → `registerFactory` (deviate only if the BLoC is
      genuinely app-wide, matching `ActiveOrderBloc`/`AppbarBloc`).
- [ ] Anything requiring `await` to construct is resolved as a local variable
      before `init()`'s `getIt.register...` calls, not inside a closure.
- [ ] If the object needs to start doing work at launch (listeners, timers),
      the "start" call is explicit in `main()` after `init()`, not embedded in
      the registration closure.
- [ ] New BLoC's provisioning matches its actual scope: per-route
      `BlocProvider` for screen-local state, app-wide `MultiBlocProvider` only
      if it must outlive/cross multiple screens.
- [ ] No new core/infra service takes a BLoC as a constructor dependency.
- [ ] If touching auth networking, confirmed which `ApiClient`
      (regular vs. a newly-registered named auth client) is actually intended,
      rather than assuming `ApiClient.auth()` is already wired in.
