---
name: flutter-networking-errors
description: Use when adding a new API call, a new remote datasource method, or any error-handling code in CodeZync POS — wiring ApiEndpoints, using ApiClient.regular()/ApiClient.auth(), or deciding where an HTTP/Dio error should be caught and translated. Enforces the exception boundary (datasources throw AppException, repositories are the only layer that catches and maps to Failure) and keeps the AppException/Failure taxonomies symmetric.
---

# Networking & Error Taxonomy (CodeZync POS)

The networking stack has one job: turn every possible failure mode (bad status
code, timeout, no internet, malformed body) into one of a small, closed set of
typed `AppException`s at the HTTP boundary, then let the data layer turn those
into typed `Failure`s. Nothing above the repository should ever see a
`DioException`, a status code, or a raw string error.

## 1. `ApiClient`: which factory to use

`lib/core/network/dio_api_client.dart` exposes two configurations via
`ApiClientType`:

- `ApiClient.regular(dio)` — base URL from `dotenv.env['BASE_URL']`, JSON
  headers. This is what almost every feature datasource uses (menu, orders,
  sessions, tables, terminals, users, locations — anything under
  `lib/core/network/api_endpoints.dart`).
- `ApiClient.auth()` — base URL from `dotenv.env['AUTH_URL']`,
  `application/x-www-form-urlencoded` headers, builds its own internal `Dio()`
  instance. Only use this for Keycloak-style auth/token endpoints, not for
  ordinary API resources.

Both configurations get the same two interceptors attached in `_setupDio()`:
`AppLoggingInterceptor` (debug-only) and `AuthInterceptor` (always). Get the
right `ApiClient` instance from `getIt` in DI rather than constructing a new
`Dio()`/`ApiClient` inline in a datasource — check how sibling datasources
receive it in their constructor.

## 2. Adding a new endpoint

1. Add a value to the `ApiEndpoints` enum in `lib/core/network/api_endpoints.dart`:
   ```dart
   enum ApiEndpoints {
     ...
     tables("/tables"),
     orders("/orders"),
     myNewResource("/my-new-resource"),   // <-- add here, keep grouped by feature
   }
   ```
2. Call it from the feature's remote datasource via `ApiClient`'s
   `getResponse`/`postResponse`/`putResponse`/`deleteResponse`/`patchResponse`
   (or `networkRequest` directly for a method not covered), using
   `pathSuffix` for path params (e.g. `pathSuffix: id` for
   `GET /tables/{id}`), `query` for query params, `data` for the body:
   ```dart
   final json = await apiClient.getResponse(
     ApiEndpoints.tables,
     pathSuffix: tableId,
   );
   return TableModel.fromJson(json as Map<String, dynamic>);
   ```
3. Let whatever `ApiClient` throws propagate out of the datasource unchanged —
   do not wrap it in a try/catch here (see §3).

## 3. The exception boundary — where try/catch is allowed

```
ApiClient        throws AppException subtypes (never lets DioException escape)
  ↓
Datasource       does NOT catch — exceptions propagate as-is
  ↓
Repository       is the ONLY place that catches AppException and returns Either<Failure, T>
  ↓
UseCase / BLoC   only ever sees Either<Failure, T> — never a raw exception
```

`ApiClient.networkRequest` already does the DioException → AppException
translation for you (`_handleDioError` for transport-level errors —
timeouts, connection errors, cancellation — and `_handleResponse` for
status-code-level errors — 400/401/403/404/409/500). **Don't duplicate that
logic in a datasource or repository.** A datasource method should look like:

```dart
Future<TerminalModel> pairTerminal({required String pairingCode}) async {
  final json = await apiClient.postResponse(
    ApiEndpoints.terminalPair,
    data: {'pairingCode': pairingCode},
  );
  return TerminalModel.fromJson(json as Map<String, dynamic>);
}
```

No try/catch. If the server returns 404, `ApiClient` already threw
`NotFoundException` — let it fly up to the repository.

## 4. Repository: map every AppException you handle to a specific Failure

`on SpecificException catch (e) { return Left(SpecificFailure(...)) }` for
every case that needs distinct handling upstream, with a final generic
`catch (error) => Left(UnknownFailure(error.toString()))` as the safety net —
**never** make the generic catch the only branch. Real examples from this
codebase:

```dart
// lib/features/terminal/data/repository/terminal_repository_impl.dart
} on NotFoundException catch (error) {
  await terminalLocalDatasource.deleteTerminal();
  await secureStorage.clearToken();
  return Left(NotFoundFailure(error.toString()));
} on UnauthorisedException catch (error) {
  await terminalLocalDatasource.deleteTerminal();
  await secureStorage.clearToken();
  return Left(TerminalInvalidFailure("Terminal is no longer valid"));
} catch (error) {
  // fall back to cached/offline state here if the feature is offline-first
  return Left(UnknownFailure(error.toString()));
}
```

Notice the mapping isn't always 1:1 by name — `UnauthorisedException` here
becomes a domain-specific `TerminalInvalidFailure`, not `AuthFailure`, because
that's what the terminal-validation flow actually means. Map to the failure
that describes what happened *for this call*, not just the HTTP-shaped
default.

**Anti-pattern — do not replicate this** (from
`lib/features/cashier/data/repositories/cashier_list_repository_impl.dart`):

```dart
// BAD: single catch-all, feature-local failure type instead of core Failure
return await datasource.fetchCashier().then((value) async {
  try {
    return Right(value);
  } catch (error) {
    return Left(CashierFailureEntity(message: error.toString()));
  }
});
```

This throws away the exception type entirely and invents a parallel failure
hierarchy (`CashierFailureEntity`) instead of using `lib/core/error/failure.dart`.
If you're adding a new use case to a legacy feature like this, use the modern
pattern for your new code — see `flutter-clear-architecture` for the full
Clean Architecture rules.

## 5. The taxonomy today — pick from this before inventing a new pair

`AppException` (`lib/core/error/app_exception.dart`) ↔
`Failure` (`lib/core/error/failure.dart`) are meant to mirror each other:

| AppException | Typical trigger | Matching Failure |
|---|---|---|
| `FetchDataException` | Dio timeout, connection error, unknown transport error | `FetchDataFailure` / `NetworkFailure` |
| `BadRequestException` | HTTP 400 | `BadRequestFailure` |
| `UnauthorisedException` | HTTP 401 | `AuthFailure` (or a domain-specific failure like `TerminalInvalidFailure` if 401 means something specific in that flow) |
| `ForbiddenException` | HTTP 403 | `ForbiddenFailure` |
| `NotFoundException` | HTTP 404 | `NotFoundFailure` |
| `DuplicateUserException` | HTTP 409 | `DuplicateUserFailure` |
| `ServerException` | HTTP 500 | `ServerFailure` |
| `InvalidCredentialsException` | login-specific invalid creds | `InvalidCredentialsFailure` |
| `InvalidInputException` | client-side/validation | `InvalidInputFailure` / `ValidationFailure` |
| `CacheException` | local datasource (sqflite/Hive/secure_storage) failure | `CacheFailure` |
| `PaymobPaymentException` | payment gateway failure | `PaymobPaymentFailure` |
| — (no matching exception; computed in repository, e.g. offline lease expiry) | — | `TerminalInvalidFailure`, `OfflineLeaseExpiredFailure`, `PlatformFailure` |
| — | anything not classified above | `UnknownFailure` |

**Adding a brand-new error case**: add both halves — `XException extends
AppException` in `app_exception.dart` *and* `XFailure extends Failure` in
`failure.dart` — with matching names, even if only one repository needs it
today. Throw the exception from the lowest layer that detects the condition
(usually `ApiClient._handleResponse`/`_handleDioError` for HTTP, or the local
datasource for storage), and catch/map it in the repository, exactly like the
existing pairs.

## 6. Interceptors: transport concerns only, never error translation

- `AuthInterceptor` (`lib/core/network/interceptors/auth_interceptor.dart`):
  attaches `Authorization: Bearer <token>` (from `SecureStorage`) and
  `X-Terminal-Key` (from `TerminalLocalDatasource`) to every request except
  `publicPaths` (`pinLogin`, `terminalPair`). On a 401/403 response it clears
  the stored token — *unless* the failing path is a terminal-validation call,
  where the terminal repository itself needs to see the error to run its own
  offline-lease fallback (see `flutter-offline-sync`). If you add a new public
  (no-auth) endpoint, add it to `publicPaths`.
- `AppLoggingInterceptor` (`logging_interceptor.dart`): full
  request/response/error logging, gated by `kDebugMode` — never gets attached
  in release builds, so don't rely on it for anything functional.
- **Do not** add status-code branching, retry logic, or exception translation
  inside an interceptor. `onError` may react to a status code (as
  `AuthInterceptor` does for token clearing) but must still call
  `handler.next(err)` so the error continues to `ApiClient._handleDioError` /
  `_handleResponse` — interceptors observe, they don't replace the boundary.
- Avoid adding new `print()` debug statements in interceptors — both existing
  interceptors already do this for request/response/error, which is
  acceptable there since it's the designated debug logging point, but don't
  spread ad-hoc `print()` logging into datasources or repositories.

## 7. User-facing error messages

`Failure.message` is what a BLoC state ultimately surfaces to a dialog/snackbar
— keep it a short, safe sentence, not `error.toString()` of an unexpected
exception dumped to the UI. `ApiClient._extractErrorMessage` already prefers
the server's `detail`/`msg`/`message`/`title` field and falls back to
"Something went wrong. Please try again later." for 401/403/500 specifically —
don't override that with a raw stack trace when mapping to `Failure` unless
you have a genuinely more specific and still-safe message for that case (as
`TerminalInvalidFailure("Terminal is no longer valid")` does).

## 8. Sanity checklist

- [ ] New endpoint added to `ApiEndpoints`, called through `ApiClient`, not a
      bespoke `Dio()` instance.
- [ ] Datasource method has no try/catch — exceptions propagate to the
      repository untouched.
- [ ] Repository catches specific `AppException` subtypes and maps each to a
      specific `Failure`, with a generic catch only as the final fallback.
- [ ] If you introduced a new failure condition, both an `XException` and a
      matching `XFailure` exist, named symmetrically.
- [ ] No new error-translation or retry logic added inside an interceptor.
- [ ] The `Failure.message` a user could see is a short, safe sentence — never
      a raw exception `toString()` for unexpected/server errors.
