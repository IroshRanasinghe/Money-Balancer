---
name: flutter-offline-sync
description: Use when touching anything offline-first in CodeZync POS — local caching, pending-write queues, connectivity-driven sync, or terminal offline-lease validation. Covers which storage backend (sqflite/Hive/secure_storage) owns which kind of data, the remote-first-then-local-fallback pattern used by repositories, how SyncManager queues and flushes pending orders/cancellations, and the TerminalInvalidFailure vs OfflineLeaseExpiredFailure distinction. Load before adding a new offline-capable feature or debugging sync/lease behavior.
---

# Offline-First & Sync (CodeZync POS)

This is a restaurant/retail POS that must keep taking orders with no
connectivity. "Offline-first" here is not one abstraction — it's three
concrete mechanisms that a feature picks from. Know which one fits before you
write storage code.

## 1. Pick the right storage backend

| Backend | File | What actually lives there today |
|---|---|---|
| `sqflite` | `lib/core/database/database_helper.dart` | Structured, queryable *read* caches with a real schema and migrations: `terminal`, `menu_cache`, `tables_cache`, `session_cache` tables (see `onCreate`/`onUpgrade` with versioned migrations up to v7). Use this for data you cache to read offline and that has real columns/relations. |
| `Hive` | `lib/core/hive_storage/local_data_manager.dart` (`CustomizationStorageManager`) | Unstructured, per-key blobs: the cart (`product_items_customization` box, keyed by customer id), pinned items, the active order snapshot, and the **pending-sync queue** (`pending_sync` box: `pending_order_params`, `pending_cancel_order_id`). Use this for write-side/working state that's naturally a JSON-ish map, not a queryable table. |
| `flutter_secure_storage` | `lib/core/storage/secure_storage.dart` (`SecureStorage`) | Only the session token and the cached-user JSON blob. Never put cache/queue data here — it's for credentials only. |

Decision rule: if you need to *query/filter/join* it → sqflite. If it's a
single blob you read/write wholesale by key (cart, pending write, active
order) → Hive. If it's a secret → secure storage. Don't invent a fourth
mechanism.

## 2. Repository read pattern: remote-first, fall back to local cache

The canonical example is `SessionRepositoryImpl.getSession()`
(`lib/features/session/data/repository/session_repository_impl.dart`):

```dart
Future<Either<Failure, SessionEntity>> getSession() async {
  try {
    final result = await datasource.getSession();      // remote first
    await localDatasource.saveSession(result);          // refresh cache on success
    return Right(result);
  } catch (error) {
    final errorStr = error.toString().toLowerCase();

    // Server reachable, explicitly says "no session" -> that's real, not offline.
    if (errorStr.contains("no active session") ||
        errorStr.contains("not found") ||
        errorStr.contains("204")) {
      await localDatasource.deleteSession();
      return const Left(NotFoundFailure("No active session"));
    }

    // Only fall back to cache for connectivity-shaped errors.
    if (errorStr.contains("connection error") ||
        errorStr.contains("socketexception") ||
        errorStr.contains("failed host lookup") ||
        errorStr.contains("timeout")) {
      final cachedSession = await localDatasource.getSession();
      if (cachedSession != null) return Right(cachedSession);
    }

    return Left(UnknownFailure(error.toString()));
  }
}
```

The rule this encodes, and that any new offline-capable read should follow:
1. Always try remote first; on success, refresh the local cache.
2. A **real** negative answer from a reachable server (not-found, 204, a
   business rejection) must surface as a real `Failure` — never silently
   swallowed into a stale cache hit.
3. Only a **connectivity-shaped** exception (string-matched today against
   `connection error` / `socketexception` / `failed host lookup` /
   `timeout` — see also `terminal_repository_impl.dart` and
   `order_action_bloc.dart`, which all repeat this same substring check)
   should trigger the local-cache fallback.
4. If there's no cache to fall back to, surface the original failure —
   don't fabricate a success.

`TerminalRepositoryImpl.validateTerminal()` follows the same shape but keyed
off exception *types* (`on NotFoundException`, `on UnauthorisedException`)
rather than string matching, because the remote datasource throws typed
`AppException`s there — prefer typed `on SomeException catch` over string
matching in new code; the string-matching form is a legacy pattern several
features share, not something to imitate on purpose.

## 3. Pending-write queue: `SyncManager`

`lib/core/sync/sync_manager.dart` is the one and only sync engine today. It
is **not** a generic queue abstraction — it hardcodes two flows (create
order, cancel order) directly against `CustomizationStorageManager`'s
`pending_sync` Hive box. There is no reusable "queue any offline write"
helper — if you add a new offline-writable action, you extend `SyncManager`
itself following this shape, you don't build a parallel mechanism.

Flow for queuing a write (`order_action_bloc.dart`):
```dart
result.fold(
  (failure) {
    final isConnectivityIssue = failure.message.toLowerCase().contains("connection error") || ...;
    if (isConnectivityIssue) {
      getIt<SyncManager>().queueOrder(event.params); // persist to Hive + optimistic UI state
    } else {
      emit(OrderActionFailure(message: failure.message)); // real rejection, show it now
    }
  },
  (order) => emit(OrderActionSuccess(order)),
);
```

Flow for flushing (`SyncManager.initialize()`):
- Checks connectivity on startup and subscribes to
  `Connectivity().onConnectivityChanged`; any non-`none` result triggers
  `_processPendingOrder()` and `_processPendingCancel()`.
- A `_isSyncing` / `_isSyncingCancel` guard flag prevents re-entrant flushes
  from overlapping connectivity events.

**The critical discard rule**, from `_processPendingOrder`:
```dart
if (isConnectivityIssue) {
  // still offline (or a fresh drop) — leave it queued, retry next time
} else {
  // a validation/business-rule rejection will never succeed by resending
  // the same payload — drop it instead of retrying forever
  _storageManager.deletePendingOrder();
}
```
Retry forever only on connectivity failure. Any other failure (bad
`customerId`, validation error, etc.) is permanent for that payload and must
be discarded, or the queue retries a doomed request on every reconnect
indefinitely.

**Known inconsistency, don't propagate it**: `_processPendingCancel()` does
*not* apply this rule — it retries on every failure type and never discards.
If you touch that method, bring it in line with `_processPendingOrder`'s
discard-on-non-connectivity-failure behavior rather than copying its current
retry-forever behavior into new code.

Idempotency note: pending order lines carry a client-generated
`clientLineId` (`generateClientLineId()` in `local_data_manager.dart`) so a
resent create-order payload doesn't produce duplicate lines server-side if
the first attempt actually landed before the connection dropped. Any new
queued write that could plausibly have partially succeeded before the
failure needs the same kind of idempotency key — don't assume "the call
threw" means "the server did nothing."

## 4. Terminal offline lease: two failures that look similar but aren't

`lib/core/error/failure.dart` defines both, and the doc comment on
`OfflineLeaseExpiredFailure` states the distinction explicitly:

- **`TerminalInvalidFailure`** — the server was reached and explicitly said
  the terminal is no longer valid (decommissioned / unauthorised). Thrown
  from `TerminalRepositoryImpl.validateTerminal()`'s `on
  UnauthorisedException` branch. The pairing is genuinely gone.
- **`OfflineLeaseExpiredFailure`** — the server could not be reached at all,
  and the local **24-hour lease** (`offlineLeaseHours` constant in
  `terminal_repository_impl.dart`) since the last successful validation has
  also passed. This does **not** mean the server rejected anything — it
  means we simply couldn't ask, for too long.

```dart
catch (error) {
  final localTerminal = await terminalLocalDatasource.getTerminal();
  if (localTerminal?.lastValidationAt != null) {
    final difference = DateTime.now().difference(localTerminal!.lastValidationAt!);
    if (difference.inHours < offlineLeaseHours) {
      return Right(localTerminal.toEntity()); // within lease — keep working offline
    }
    return const Left(OfflineLeaseExpiredFailure("Offline lease expired (24h)..."));
  }
  return Left(UnknownFailure(error.toString()));
}
```

`TerminalBloc._validateTerminal` branches on failure *type*, not message, and
this is the pattern to copy anywhere else that needs to react differently to
"rejected" vs "unreachable":

```dart
if (failure is NotFoundFailure || failure is TerminalInvalidFailure) {
  // genuinely invalid — send the user back to pairing/login
} else {
  // OfflineLeaseExpiredFailure, UnknownFailure from a dropped connection, etc.
  // — terminal was never invalidated, keep using the cached terminal
}
```

Never conflate the two: don't throw `TerminalInvalidFailure` for a network
timeout, and don't let an `OfflineLeaseExpiredFailure` silently deregister a
terminal that the server never actually rejected.

## 5. Checklist for a new offline-capable feature

- [ ] Does it need a **read cache**? If the data is relational/queryable, add
      a table + migration in `database_helper.dart` (bump `version` and add
      an `oldVersion <` branch — never mutate an existing migration step).
      If it's a simple blob, add a Hive box method to
      `CustomizationStorageManager` instead.
- [ ] Does the repository need remote-first/local-fallback? Follow section 2
      — prefer typed `on XException catch` over string matching in new code.
- [ ] Does it need a **pending-write queue** (an action a cashier can trigger
      while offline that must reach the server eventually)? Extend
      `SyncManager` with a `queueX()` / `_processPendingX()` pair modeled on
      `queueOrder`/`_processPendingOrder`, including the connectivity-vs-permanent
      discard rule from section 3, and give the payload an idempotency key if
      partial success before failure is possible.
- [ ] Does a failure from this feature need to distinguish "server said no"
      from "couldn't reach server"? Add/reuse typed `Failure` subclasses
      (section 4) instead of string-matching `failure.message` at the call
      site.
- [ ] If it touches the terminal/session gate, don't invalidate local state
      (`deleteTerminal`, `clearToken`, `clearAllCartData`) on anything but a
      confirmed server rejection.
