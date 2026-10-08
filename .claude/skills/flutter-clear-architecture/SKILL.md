---
name: flutter-clear-architecture
description: Use when adding, extending, or reviewing any feature in CodeZync POS (lib/features/**) — new use cases, repositories, datasources, BLoCs, entities, DI wiring, or routing. Enforces this project's Clean Architecture layering (domain -> data -> presentation, one-way dependencies), the modern UseCase<T, Params>/Either<Failure, T> pattern, and the naming/wiring conventions already established in the codebase (DI in dependency_injection.dart, routing in app_router.dart, Poppins text widgets, responsive helpers).
---

# Flutter Clean Architecture (CodeZync POS)

You are acting as the senior Flutter architect for this codebase. Your job is not
just to make code compile — it's to keep every feature consistent with the
patterns already established under `lib/features/`, so the codebase reads as one
system regardless of who touches it next.

## 0. Before writing anything

1. Open the target feature's existing folders (or the closest sibling feature) and
   match what's there. This project is **not internally consistent** — some
   features use `repository/` (singular), others `repositories/`; some use
   `usecase/`, others `usecases/`. **Never guess — inspect the feature first.**
2. Treat `lib/features/session/**` and `lib/features/auth/**` as the reference
   implementation of the *current* standard (they use `UseCase<T, Params>` +
   `Either<Failure, T>` + typed `Failure`s from `lib/core/error/failure.dart`).
3. Do **not** copy the older ad-hoc pattern seen in some legacy features
   (e.g. `cashier`'s bare `class XyzUsecase { call() }` with a
   feature-local `XyzFailureEntity`). If you touch a legacy feature and need to
   add a new use case to it, prefer the modern pattern for the new code even if
   the surrounding old code hasn't been migrated yet — don't spread the old
   pattern further.

## 1. Layering rules (non-negotiable)

```
presentation  ──depends on──>  domain  <──depends on──  data
```

- `domain/` has **zero** imports from `data/` or `presentation/`, and zero
  imports of Dio, sqflite, Hive, GetIt, or flutter_bloc. It is pure Dart +
  `equatable` + `dartz`.
- `presentation/` never imports a datasource or a repository *implementation*
  directly — only use cases and domain entities/params. BLoCs depend on use
  cases, not on `data/`.
- `data/` implements the `domain/repositories` (or `repository/`) interfaces
  and is the only layer allowed to know about Dio/sqflite/Hive/JSON.

## 2. Per-feature structure

```
lib/features/<feature>/
  data/
    datasource/                 # <Feature>RemoteDatasource (Dio/ApiClient) and/or
                                 # <Feature>LocalDatasource (sqflite/Hive/secure_storage)
                                 # + their *Impl classes
    model/                      # <Thing>Model extends <Thing>Entity, fromJson/toJson
    repository(ies)/            # <Feature>RepositoryImpl implements domain interface
  domain/
    entities/                   # <Thing>Entity extends Equatable — plain, no logic
    params/                     # <UseCase>Params extends Equatable — when a use case
                                 # needs more than one primitive input
    repository(ies)/            # abstract <Feature>Repository
    usecase(s)/                 # one class per use case
  presentation/
    bloc/                       # <feature>_bloc.dart, _event.dart, _state.dart
    pages/                      # screens/dialogs
    widgets/                    # feature-local widgets
```

Check the sibling feature to know whether it's `repository` vs `repositories`
and `usecase` vs `usecases` before creating a new directory.

## 3. Entities and Models

- Entities (`domain/entities/`) extend `Equatable`, are `const` constructors,
  all fields `final`, and list every field in `props`. No JSON, no logic beyond
  simple getters.
- Models (`data/model/`) `extends` the matching entity and add `fromJson`
  (and `toJson` when the feature sends the shape back to the API). Models are
  what datasources return; repositories return the entity type upward (the
  model satisfies that by extension — don't re-map field by field unless the
  shapes genuinely diverge).

```dart
// domain/entities/cashier_entity.dart
class CashierEntity extends Equatable {
  final String id;
  final String name;
  const CashierEntity({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}

// data/model/cashier_model.dart
class CashierModel extends CashierEntity {
  const CashierModel({required super.id, required super.name});

  factory CashierModel.fromJson(Map<String, dynamic> json) => CashierModel(
        id: json['id'] as String,
        name: json['name'] as String,
      );
}
```

## 4. Params

Any use case that takes more than one primitive gets a
`domain/params/<use_case>_params.dart` class extending `Equatable`:

```dart
class AddCashMovementsParams extends Equatable {
  final MovementType movementType;
  final double amount;
  final String reason;
  final String sessionId;

  const AddCashMovementsParams({
    required this.movementType,
    required this.amount,
    required this.reason,
    required this.sessionId,
  });

  @override
  List<Object?> get props => [movementType, amount, reason, sessionId];
}
```

Single-input or no-input use cases take the primitive directly, or
`NoParams()` from `lib/core/usecase/usecase.dart`.

## 5. Use cases — always implement `UseCase<T, Params>`

```dart
class AddCashMovementUseCase
    implements UseCase<CashMovementEntity, AddCashMovementsParams> {
  final SessionRepository repository;
  const AddCashMovementUseCase({required this.repository});

  @override
  Future<Either<Failure, CashMovementEntity>> call(
      AddCashMovementsParams params) {
    return repository.addCashMovement(params: params);
  }
}
```

- Return type is always `Future<Either<Failure, T>>` using `dartz`, `Failure`
  from `lib/core/error/failure.dart` — **not** a feature-local failure class.
- A use case is a thin pass-through to the repository unless it genuinely
  needs to orchestrate more than one repository call. Don't put business logic
  that belongs in the repository or BLoC here, and don't skip the use case
  layer by calling a repository directly from a BLoC.

## 6. Repository interface + implementation

The interface lives in `domain/repository(ies)/` and returns
`Either<Failure, T>`:

```dart
abstract class SessionRepository {
  Future<Either<Failure, SessionEntity>> getSession();
  Future<Either<Failure, CashMovementEntity>> addCashMovement({
    required AddCashMovementsParams params,
  });
}
```

The implementation lives in `data/repository(ies)/`, depends on one or more
datasources, and is the seam where thrown exceptions become typed `Failure`s.
**Map specific exception types to specific failure types** — don't collapse
everything into `UnknownFailure`. `AppException` subtypes come from
`lib/core/error/app_exception.dart` (thrown by `dio_api_client.dart` for HTTP
errors); local datasource errors are typically `CacheException`.

```dart
class SessionRepositoryImpl implements SessionRepository {
  final SessionRemoteDatasource datasource;
  final SessionLocalDatasource localDatasource;
  const SessionRepositoryImpl({required this.datasource, required this.localDatasource});

  @override
  Future<Either<Failure, SessionEntity>> getSession() async {
    try {
      final result = await datasource.getSession();
      await localDatasource.saveSession(result);
      return Right(result);
    } on NotFoundException catch (e) {
      await localDatasource.deleteSession();
      return Left(NotFoundFailure(e.message.toString()));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message.toString()));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message.toString()));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
```

If offline fallback is relevant (this app is offline-first), fall back to the
local datasource on a network-shaped failure rather than surfacing it
immediately — see `sync_manager.dart` and the local/remote split in
`session`/`Orders` for the established pattern. Avoid leaving `print()` debug
statements in repository code you write — none of the new code you add should
introduce them even where an existing file has them.

## 7. Datasources

- Remote: constructor takes `ApiClient` (or a raw `Dio` if that's the sibling
  feature's convention), calls endpoints from an `ApiEndpoints`-style enum,
  returns `Model`s (not entities — though the type is compatible via
  extension), and lets exceptions propagate (don't catch here; the repository
  is the exception→failure boundary).
- Local: wraps `lib/core/database/database_helper.dart` (sqflite, relational
  data), `lib/core/hive_storage/local_data_manager.dart` (Hive, cart/pending
  state), or `lib/core/storage/secure_storage.dart` (tokens/cached user) —
  don't invent a fourth local storage mechanism without a clear reason.

## 8. BLoC

Three files, one BLoC. Events and States extend `Equatable`:

```dart
// event
abstract class SessionEvent extends Equatable {
  const SessionEvent();
  @override
  List<Object?> get props => [];
}
class GetSessionEvent extends SessionEvent {
  const GetSessionEvent();
}

// state
abstract class SessionState extends Equatable {
  const SessionState();
  @override
  List<Object?> get props => [];
}
class SessionLoading extends SessionState { const SessionLoading(); }
class SessionFailure extends SessionState {
  final String message;
  const SessionFailure({required this.message});
  @override
  List<Object?> get props => [message];
}
class SessionLoaded extends SessionState {
  final SessionEntity entity;
  const SessionLoaded({required this.entity});
  @override
  List<Object?> get props => [entity];
}
```

```dart
// bloc
class SessionBloc extends Bloc<SessionEvent, SessionState> {
  final GetSessionUseCase getSessionUseCase;

  SessionBloc({required this.getSessionUseCase}) : super(const InitialSession()) {
    on<GetSessionEvent>(_getSession);
  }

  Future<void> _getSession(GetSessionEvent event, Emitter<SessionState> emit) async {
    emit(const SessionLoading());
    final result = await getSessionUseCase(NoParams());
    result.fold(
      (failure) => emit(SessionFailure(message: failure.message)),
      (session) => emit(SessionLoaded(entity: session)),
    );
  }
}
```

Naming convention for states: `Initial<Feature>`, `<Feature>Loading`,
`<Feature>Loaded`, `<Feature>Failure` — match this instead of inventing new
suffixes. Keep `Emitter` handler methods private (`_verbNoun`) and one event ->
one handler. A BLoC method should never touch a raw exception — only the
`Either` returned by the use case.

## 9. Wiring it up

**DI** (`lib/core/di/dependency_injection.dart`, inside `init()`):
- Datasources and repositories: `getIt.registerLazySingleton<Interface>(() => Impl(...))`.
- Use cases: `getIt.registerLazySingleton(() => XUseCase(repository: getIt()))`.
- BLoCs: `getIt.registerFactory(() => XBloc(...))` — screen-scoped BLoCs are
  factories, not singletons.
- Add new imports near the existing feature's imports, keep the four
  registration groups (datasources / repositories / usecases / blocs) in the
  same relative order the file already uses.
- App-wide BLoCs that must live for the whole session (not just one screen) go
  in `MultiBlocProvider` in `lib/codezync_pos_app.dart` instead — only do this
  if the feature genuinely needs cross-screen state (see how session/auth are
  handled there), not by default.

**Routing** (`lib/core/router/app_router.dart` + `app_route.dart` +
`app_route_names.dart`):
- Add the path string to `app_route.dart`, the route name constant to
  `app_route_names.dart`, then a `GoRoute` in `app_router.dart`.
- If the screen needs its BLoC, wrap it with `BlocProvider(create: (context) =>
  getIt<XBloc>(), child: XScreen())` inline in the route builder — this project
  does **not** use a `MultiBlocProvider` per route.

## 10. UI conventions

- Use `CustomTextPoppins` (`lib/core/widgets/custom_text_poppins.dart`) instead
  of raw `Text` wherever the surrounding code already does — check the screen
  you're editing first.
- Use the responsive helpers in `lib/ResponsiveKit/` and
  `lib/core/design_system/responsive/` (`ResponsiveHelper.isTab/isDesktop/...`,
  `responsive_text.dart`) for sizing instead of hardcoded breakpoints — the app
  is landscape-locked tablet/phone POS UI, not general responsive web.
- Reuse existing buttons/text-fields under `lib/core/widgets/` before adding a
  new one-off widget.

## 11. Sanity checklist before calling a feature done

- [ ] Domain layer has no data/presentation/package imports beyond
      `equatable`/`dartz`.
- [ ] New use case implements `UseCase<T, Params>` and returns
      `Either<Failure, T>` using core `Failure` types.
- [ ] Repository impl maps specific exceptions to specific `Failure`s, not a
      single catch-all.
- [ ] BLoC states/events extend `Equatable` with correct `props`.
- [ ] Datasource, repository, use case, and BLoC are all registered in
      `dependency_injection.dart` with the right GetIt lifetime
      (singleton vs factory).
- [ ] Route + route name added if there's a new screen, and the screen's BLoC
      is provided via `BlocProvider` in the route builder.
- [ ] `flutter analyze` is clean and, if the feature is non-trivial, a basic
      unit test exists for the use case/repository under `test/`.
