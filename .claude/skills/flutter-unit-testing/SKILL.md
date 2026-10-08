---
name: flutter-unit-testing
description: Conventions for writing unit tests in codezync_pos — mocktail + bloc_test setup, test/ directory structure mirroring lib/features, and patterns for testing a use case, repository impl, and bloc. Use when adding tests for a use case, repository, datasource, or bloc, or when asked to write or run unit tests.
---

**There is currently no real test suite.** `test/` contains only the
default `test/widget_test.dart` boilerplate from `flutter create` (a
counter smoke test referencing `CodezyncPosApp` — it doesn't test anything
about this POS app). `pubspec.yaml`'s `dev_dependencies` has only
`flutter_test` and `flutter_lints` — **`mocktail` and `bloc_test` are not
installed.** This skill establishes conventions to follow when adding
tests, not documentation of an existing suite.

## Setup — do this before writing the first real test

Add to `pubspec.yaml` `dev_dependencies`:

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
  mocktail: ^1.0.0
  bloc_test: ^9.0.0
```

Then `flutter pub get`. `equatable` and `dartz` are already regular
dependencies, which matters for assertions below (Equatable gives value
equality for free on entities/failures/states).

## Directory structure

Mirror `lib/features/<feature>/...` exactly, **including the lib layer's
own folder-naming quirks** — e.g. `auth`'s domain layer uses singular
`domain/repository/` where most other features use plural
`domain/repositories/`. Don't normalize it in `test/`; a dev should be
able to find a class's test by mentally swapping `lib` → `test` on the
class's actual path, not on what the path "should" be:

```
test/
  features/
    auth/
      domain/usecase/login_usecase_test.dart
      data/repository/auth_repository_impl_test.dart
      presentation/bloc/login_bloc_test.dart
```

Naming: `<original_filename>_test.dart`. `group('ClassName', () { ... })`
wrapping `test('does X', () { ... })` (or `blocTest(...)` for blocs, which
supplies its own grouping).

## Use case test — thin pass-through, mock the repository

```dart
// test/features/auth/domain/usecase/login_usecase_test.dart
class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repository;
  late LoginUseCase useCase;

  setUp(() {
    repository = MockAuthRepository();
    useCase = LoginUseCase(repository: repository);
  });

  test('returns Right(LoginEntity) on successful login', () async {
    final entity = LoginEntity(/* ... */);
    when(() => repository.login(employeeId: 'e1', pinCode: '1234'))
        .thenAnswer((_) async => Right(entity));

    final result = await useCase(employeeId: 'e1', pinCode: '1234');

    expect(result, Right(entity));
    verify(() => repository.login(employeeId: 'e1', pinCode: '1234')).called(1);
  });

  test('returns Left(Failure) when repository fails', () async {
    when(() => repository.login(employeeId: any(named: 'employeeId'), pinCode: any(named: 'pinCode')))
        .thenAnswer((_) async => const Left(InvalidCredentialsFailure('bad creds')));

    final result = await useCase(employeeId: 'e1', pinCode: 'wrong');

    expect(result, const Left(InvalidCredentialsFailure('bad creds')));
  });
}
```

Since `Failure` subclasses are `Equatable` (see
`lib/core/error/failure.dart`), `Left(NotFoundFailure('x')) ==
Left(NotFoundFailure('x'))` holds — assert the concrete `Failure`
subtype and message directly, don't settle for `isA<Failure>()`.

## Repository impl test — mock every collaborator, assert the specific Failure

Repository impls often take more than one collaborator.
`AuthRepositoryImpl` takes four: `AuthRemoteDatasource`,
`TerminalLocalDatasource`, `SecureStorage`, `CustomizationStorageManager`
— mock all of them, not just the datasource that "obviously" matters:

```dart
// test/features/auth/data/repository/auth_repository_impl_test.dart
class MockAuthRemoteDatasource extends Mock implements AuthRemoteDatasource {}
class MockTerminalLocalDatasource extends Mock implements TerminalLocalDatasource {}
class MockSecureStorage extends Mock implements SecureStorage {}
class MockCustomizationStorageManager extends Mock implements CustomizationStorageManager {}

void main() {
  late AuthRepositoryImpl repositoryImpl;
  late MockAuthRemoteDatasource remoteDatasource;
  late MockTerminalLocalDatasource terminalLocalDatasource;
  late MockSecureStorage secureStorage;
  late MockCustomizationStorageManager storageManager;

  setUp(() {
    remoteDatasource = MockAuthRemoteDatasource();
    terminalLocalDatasource = MockTerminalLocalDatasource();
    secureStorage = MockSecureStorage();
    storageManager = MockCustomizationStorageManager();
    repositoryImpl = AuthRepositoryImpl(
      authRemoteDatasource: remoteDatasource,
      terminalLocalDatasource: terminalLocalDatasource,
      secureStorage: secureStorage,
      storageManager: storageManager,
    );
  });

  test('maps a "terminal" NotFoundException to TerminalInvalidFailure and clears state', () async {
    when(() => terminalLocalDatasource.getTerminal()).thenAnswer((_) async => testTerminal);
    when(() => remoteDatasource.login(employeeId: any(named: 'employeeId'), pinCode: any(named: 'pinCode'), deviceKey: any(named: 'deviceKey')))
        .thenThrow(NotFoundException('Terminal not found'));
    when(() => terminalLocalDatasource.deleteTerminal()).thenAnswer((_) async {});
    when(() => secureStorage.clearToken()).thenAnswer((_) async {});
    when(() => storageManager.clearAllCartData()).thenAnswer((_) async {});

    final result = await repositoryImpl.login(employeeId: 'e1', pinCode: '1234');

    expect(result, isA<Left>());
    result.fold(
      (failure) => expect(failure, isA<TerminalInvalidFailure>()),
      (_) => fail('expected Left'),
    );
    verify(() => terminalLocalDatasource.deleteTerminal()).called(1);
  });
}
```

This exercises `AuthRepositoryImpl.login`'s actual branching (see
`lib/features/auth/data/repository/auth_repository_impl.dart`): it
string-matches inside a single `on NotFoundException catch` block to
decide between `TerminalInvalidFailure` (terminal-related, wipes local
state) and a plain `NotFoundFailure` — a repository test should cover
both branches, not just "throws → returns Left".

## Bloc test — `bloc_test`'s `blocTest`, mock every use case the constructor takes

```dart
// test/features/auth/presentation/bloc/login_bloc_test.dart
class MockLoginUseCase extends Mock implements LoginUseCase {}
class MockValidateTerminalUseCase extends Mock implements ValidateTerminalUseCase {}
class MockGetTerminalUseCase extends Mock implements GetTerminalUseCase {}

void main() {
  late MockLoginUseCase loginUseCase;
  late MockValidateTerminalUseCase validateTerminalUseCase;
  late MockGetTerminalUseCase getTerminalUseCase;

  setUp(() {
    loginUseCase = MockLoginUseCase();
    validateTerminalUseCase = MockValidateTerminalUseCase();
    getTerminalUseCase = MockGetTerminalUseCase();
  });

  AuthLoginBloc buildBloc() => AuthLoginBloc(
        loginUseCase: loginUseCase,
        validateTerminalUseCase: validateTerminalUseCase,
        getTerminalUseCase: getTerminalUseCase,
      );

  blocTest<AuthLoginBloc, AuthLoginState>(
    'emits [LoginLoading, LoginSuccess] on a full successful chain',
    setUp: () {
      when(() => loginUseCase(employeeId: any(named: 'employeeId'), pinCode: any(named: 'pinCode')))
          .thenAnswer((_) async => Right(testEmployee));
      when(() => getTerminalUseCase()).thenAnswer((_) async => Right(testTerminal));
      when(() => validateTerminalUseCase(testTerminal.terminalId))
          .thenAnswer((_) async => const Right(unit));
    },
    build: buildBloc,
    act: (bloc) => bloc.add(AuthLoginEvent(employeeId: 'e1', pinCode: '1234')),
    expect: () => [
      const LoginLoading(),
      LoginSuccess(entity: testEmployee),
    ],
  );

  blocTest<AuthLoginBloc, AuthLoginState>(
    'emits [LoginLoading, TerminalInvalidState] when login fails with TerminalInvalidFailure',
    setUp: () {
      when(() => loginUseCase(employeeId: any(named: 'employeeId'), pinCode: any(named: 'pinCode')))
          .thenAnswer((_) async => const Left(TerminalInvalidFailure('re-pair needed')));
    },
    build: buildBloc,
    act: (bloc) => bloc.add(AuthLoginEvent(employeeId: 'e1', pinCode: '1234')),
    expect: () => [
      const LoginLoading(),
      const TerminalInvalidState(message: 're-pair needed'),
    ],
  );
}
```

`AuthLoginBloc` chains three use cases with nested `.fold()`
(`login_bloc.dart`) — a real bloc under test will often need a
`setUp:`/`seed:` per `blocTest` case to control which branch of that chain
executes, not just one mock per use case.

Since states are `Equatable`, `expect: () => [...]` compares by value —
no custom matchers needed as long as every state class's `props` includes
every field the test differs on.

## Running

```bash
flutter test                            # everything
flutter test test/features/auth/presentation/bloc/login_bloc_test.dart   # one file
```
