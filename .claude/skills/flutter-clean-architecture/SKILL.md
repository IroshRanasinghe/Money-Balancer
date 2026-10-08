---
name: flutter-clean-architecture
description: Guidance and checklist for implementing features in codezync_pos's clean architecture (feature-first, data/domain/presentation, get_it DI, dartz Either, flutter_bloc). Use when adding a new feature, use case, repository, datasource, or bloc, or when reviewing whether new code follows this project's layering.
---

This project (`codezync_pos`) organizes code by **feature**, and every
feature is split into three layers: `data`, `domain`, `presentation`.
Shared infrastructure lives in `lib/core/`. This skill documents the
*actual* conventions used in this codebase (verified against
`lib/features/auth/`, `lib/features/menu/`, `lib/features/terminal/`,
and `lib/core/di/dependency_injection.dart`) — follow these, not
generic clean-architecture tutorials, when the two disagree.

## Layer responsibilities

```
lib/features/<feature>/
  domain/
    entities/<x>_entity.dart        # plain value objects, no serialization
    repositories/<x>_repository.dart# abstract interface, returns Either<Failure, T>
    usecase/<x>_usecase.dart        # one class per use case, calls the repository
  data/
    model/<x>_model.dart            # fromJson/toJson + toEntity() mapping
    datasource/<x>_datasource.dart  # interface + Impl, talks to Dio/sqflite/Hive
    repositories/<x>_repository_impl.dart # implements the domain interface
  presentation/
    bloc/<x>_bloc.dart, <x>_event.dart, <x>_state.dart
    pages/, widgets/
```

Dependency direction is inward: `presentation` → `domain` ←
`data`. `domain` never imports from `data` or `presentation`.
`presentation` never talks to a datasource or Dio/sqflite directly —
only to a use case.

### domain/entities

Plain classes, usually `extends Equatable`, with no `fromJson`/`toJson`.
See [auth_entity.dart](../../../lib/features/auth/domain/entities/auth_entity.dart).
If a value needs to come from JSON or go into local storage, that's a
`data/model`, not an entity.

### domain/repositories

An abstract class declaring the feature's operations, every method
returning `Future<Either<Failure, T>>`:

```dart
abstract class AuthRepository {
  Future<Either<Failure, LoginEntity>> login({required String employeeId, required String pinCode});
  Future<Either<Failure, LoginEntity?>> getCachedUser();
}
```

### domain/usecase

One class per use case. Most use cases in this codebase are **plain
classes with a `call()` method and named parameters** — they do
*not* extend the `UseCase<T, Params>` base in
[core/usecase/usecase.dart](../../../lib/core/usecase/usecase.dart).
That base class exists but only a minority of use cases use it. Match
whichever style the sibling use cases in the feature you're touching
already use; default to the plain-class style if there's no
precedent, since it's the majority pattern:

```dart
class LoginUseCase {
  final AuthRepository repository;
  const LoginUseCase({required this.repository});

  Future<Either<Failure, LoginEntity>> call({required String employeeId, required String pinCode}) async {
    return await repository.login(employeeId: employeeId, pinCode: pinCode);
  }
}
```

A use case does not catch exceptions or contain business branching
beyond simple orchestration (e.g. `AuthLoginBloc` chains
`LoginUseCase` → `GetTerminalUseCase` → `ValidateTerminalUseCase`, but
each use case itself stays a thin pass-through to its repository).

### data/model

Extends or wraps the entity shape and adds serialization plus a
`toEntity()` mapper:

```dart
class LoginModel { ... 
  factory LoginModel.fromJson(Map<String, dynamic> json) => ...;
  Map<String, dynamic> toJson() => ...;
  LoginEntity toEntity() => LoginEntity(...);
}
```

Never return a `Model` from a repository method — always map to the
`Entity` before returning `Right(...)`.

### data/datasource

Interface + `Impl`, one per remote/local pair when a feature needs
both (e.g. `AuthRemoteDatasource`, `TerminalLocalDatasource`). A
datasource **throws** — it never returns `Either`. On failure it
throws one of the typed exceptions from
[core/error/app_exception.dart](../../../lib/core/error/app_exception.dart)
(`NotFoundException`, `ServerException`, `UnauthorisedException`,
`InvalidCredentialsException`, `CacheException`, ...), not a raw
`Exception`.

### data/repositories (`*_repository_impl.dart`)

Implements the domain interface. This is the **only** place that
converts exceptions into `Failure`s — wrap the datasource call in
try/catch, `on <SpecificException> catch` first for cases that need
special handling, then a general `catch` mapped to `UnknownFailure`:

```dart
@override
Future<Either<Failure, LoginEntity>> login({required String employeeId, required String pinCode}) async {
  try {
    final result = await authRemoteDatasource.login(...);
    return Right(result.toEntity());
  } on NotFoundException catch (error) {
    return Left(NotFoundFailure(error.toString()));
  } catch (error) {
    return Left(UnknownFailure(error.toString()));
  }
}
```

Failure types live in
[core/error/failure.dart](../../../lib/core/error/failure.dart) — add
a new `Failure` subclass there (and a matching `AppException`
subclass in `app_exception.dart`) rather than reusing `UnknownFailure`
when the bloc needs to branch on the failure kind (see
`TerminalInvalidFailure` handling in `AuthLoginBloc` below).

### presentation/bloc

`flutter_bloc` `Bloc<Event, State>`. Constructor takes the use
case(s) it needs. Handlers call the use case, then `.fold(onFailure,
onSuccess)` to emit state — including branching on the concrete
`Failure` subtype when the UI needs to react differently:

```dart
class AuthLoginBloc extends Bloc<LoginEvent, AuthLoginState> {
  final LoginUseCase loginUseCase;
  AuthLoginBloc({required this.loginUseCase}) : super(InitialLogin()) {
    on<AuthLoginEvent>((event, emit) async {
      emit(const LoginLoading());
      final result = await loginUseCase(employeeId: event.employeeId, pinCode: event.pinCode);
      result.fold(
        (failure) => failure is TerminalInvalidFailure
            ? emit(TerminalInvalidState(message: failure.message))
            : emit(LoginFailure(message: failure.message)),
        (entity) => emit(LoginSuccess(entity: entity)),
      );
    });
  }
}
```

## Wiring it up: `lib/core/di/dependency_injection.dart`

One `Future<void> init()` function, `get_it`, registered strictly in
dependency order — **datasource → repository → usecase → bloc** — in
that grouping (the file literally has `// Datasource...` / `//
repository...` / `// Usecase...` / `// Bloc...` section comments; keep
new registrations under the matching section):

- `registerLazySingleton` for datasources, repositories, and use
  cases (one shared instance for the app's lifetime).
- `registerFactory` for blocs that are recreated per screen/widget
  (most blocs). A few long-lived blocs that need to survive
  navigation are `registerLazySingleton` instead (e.g. `AppbarBloc`,
  `ActiveOrderBloc`) — only do this if the bloc genuinely needs to
  outlive the screen that created it.

Adding a feature means adding one line per datasource/repository/usecase/bloc here — there is no auto-registration or code generation for DI in this project.

## Adding a new feature — checklist

1. `domain/entities/<x>_entity.dart` — plain `Equatable` value object.
2. `domain/repositories/<x>_repository.dart` — abstract interface, `Either<Failure, T>` return types.
3. `domain/usecase/<x>_usecase.dart` — one class per operation, thin pass-through to the repository.
4. `data/model/<x>_model.dart` — `fromJson`/`toJson`/`toEntity()`.
5. `data/datasource/<x>_datasource.dart` (+ `Impl`) — throws typed `AppException`s from `core/error/app_exception.dart`.
6. `data/repositories/<x>_repository_impl.dart` — implements the domain interface, catches exceptions, maps to `Failure`s from `core/error/failure.dart`.
7. `presentation/bloc/<x>_bloc.dart` + `_event.dart` + `_state.dart` — calls the use case(s), `.fold()`s the result into state.
8. Register datasource → repository → usecase → bloc in `lib/core/di/dependency_injection.dart`, in that order, under the matching section comment.
9. Wire the bloc into a page via `BlocProvider(create: (_) => getIt<YourBloc>())`.

## Known inconsistencies (don't copy these into new code)

- **Duplicate auth features.** Both `lib/features/auth/` and
  `lib/features/login/` implement login (repository, use case, bloc
  named `LoginBloc`/`AuthLoginBloc`, models named `AuthModel`). Only
  `features/auth` is wired into DI in `dependency_injection.dart` and
  used by the router — `features/login` appears to be superseded/dead
  code. If you're touching login, work in `features/auth`; don't add
  parallel logic to `features/login`. If you get a chance, flag this
  duplication for cleanup rather than extending it further.
- **`core/usecase/usecase.dart`'s `UseCase<T, Params>` base class is
  mostly unused.** Most concrete use cases (`LoginUseCase`,
  `CashierListUsecase`, `MenuUseCase`, ...) are plain classes with a
  `call()` that takes named parameters rather than a single `Params`
  object. Don't "fix" existing use cases to extend the base class as
  a drive-by change — it would touch every call site for no behavior
  change.

## Related shared infrastructure

- `core/network/` — `ApiClient` (Dio wrapper) + interceptors; datasources take an `ApiClient`/`Dio` instance via constructor injection.
- `core/storage/` — `SecureStorage` (flutter_secure_storage) for tokens/session.
- `core/hive_storage/` — `CustomizationStorageManager` (Hive) for cart/customization local cache.
- `core/database/` — `DatabaseHelper` (sqflite, ffi on Windows/Linux) for structured local storage (tables, menu cache, etc).
- `core/sync/` — `SyncManager`, initialized in `main.dart` after DI, drives offline-first sync of orders created while offline.
- `core/router/` — `go_router` setup (`app_router.dart`, `app_route.dart`, route name constants in `app_route_names.dart`).

To actually run the app and see a feature working end-to-end, use
[run-codezync-pos](../run-codezync-pos/SKILL.md).
