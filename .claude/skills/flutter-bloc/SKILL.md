---
name: flutter-bloc
description: Deeper bloc/state-management conventions in codezync_pos, beyond what flutter-clean-architecture covers (constructor-takes-usecases, .fold() into state) — state-shape choices, bloc-to-bloc communication, event/state naming, and DI-registration quirks. Use when adding a bloc, event, or state, or wiring cross-bloc behavior.
---

This extends
[flutter-clean-architecture](../flutter-clean-architecture/SKILL.md)'s bloc
section with patterns verified across multiple features
(`auth`, `menu`, `cart`, `coins`, `Orders`, `table`) — including real
inconsistencies between them. Where a feature disagrees with another, match
the **sibling bloc in the feature you're touching**, not whichever pattern
below looks "more correct."

## How many blocs per feature

Most features have exactly one bloc (event/state file trio). A few have
2–3: `item_screen` (`ItemBloc` + `pinned_items/PinnedItemsBloc`), `auth`
(`AuthLoginBloc` + `UserSessionBloc`), `table` (`DrawerTableBloc` +
`tables/TableBloc`), `Orders` (`ActiveOrderBloc`, `OrderActionBloc`,
`OrderBloc`). No feature has more than 3 — if you find yourself adding a
4th to one feature, it's a sign the feature boundary itself may be too
wide.

## State shape: two patterns, pick by whether the bloc can fail

**Majority pattern — one abstract state + a subclass per status.** Use
this whenever the bloc calls a use case (i.e. does anything async that can
fail):

```dart
abstract class AuthLoginState extends Equatable { ... }
class InitialLogin extends AuthLoginState { ... }
class LoginLoading extends AuthLoginState { ... }
class LoginFailure extends AuthLoginState { final String message; ... }
class LoginSuccess extends AuthLoginState { final LoginEntity entity; ... }
class TerminalInvalidState extends AuthLoginState { ... }
```

Seen consistently in `AuthLoginState` (`login_state.dart`), `MenuState`
(`Initial`/`Loading`/`Loaded`/`Failure`), `ActiveOrderState`,
`OrderActionState`, `TableState` — each with 4–8 subclasses.

**Minority pattern — single concrete state + `copyWith`.** Only
appropriate for a bloc with **no async/failure path at all** — pure
synchronous local state:

```dart
// lib/features/coins/presentation/bloc/coin_state.dart
class CoinState extends Equatable {
  final List<CoinEntity> coins;
  final Map<String, int> countMap;
  final double total;
  const CoinState({required this.coins, required this.countMap, required this.total});
  CoinState copyWith({...}) => CoinState(...);
  @override
  List<Object?> get props => [coins, countMap, total];
}
```

`CoinBloc` never calls a use case — `IncrementCoinEvent`/
`DecrementCoinEvent`/`ResetCoinsEvent` are pure arithmetic on local state,
so there's no loading/failure state to model. Don't use this shape as a
shortcut for a bloc that *does* hit a repository — see "known
inconsistency" below for the one place this rule is already broken.

**Known inconsistency — don't copy:** `CartBloc`/`CartState` only has
`CartInitial`/`CartLoaded`, no loading/failure states, even though
`CartBloc` does async Hive I/O via `CustomizationStorageManager`. This
means the cart feature has no loading/error UI feedback where auth/menu
do. If you're touching `CartBloc`, this is a pre-existing gap, not a
pattern to extend into new blocs.

## Events

Always `abstract class XEvent extends Equatable` with concrete
subclasses, every event and state Equatable-based (this part *is*
consistent across every bloc checked). Naming is inconsistent between
"verb+Noun+Event" (`SetActiveOrderEvent`, `IncrementCoinEvent`,
`AuthLoginEvent`) and "Noun+Verb+Event" (`CashierListFetchEvent`,
`WaiterListFetchEvent`) — match whichever style the sibling events in the
feature you're touching already use.

## Bloc-to-bloc communication

Two distinct, both-legitimate mechanisms exist — don't invent a third
without checking these first:

**1. Constructor injection of a live bloc instance into a service class.**
Used by core infrastructure, not feature widgets:

```dart
// lib/core/sync/sync_manager.dart
class SyncManager {
  final ActiveOrderBloc _activeOrderBloc;
  SyncManager({required ActiveOrderBloc activeOrderBloc, ...}) : _activeOrderBloc = activeOrderBloc;
  // later, driven by a connectivity_plus stream, not by any widget:
  _activeOrderBloc.add(SetActiveOrderEvent(order));
}
```

Registered in DI as `SyncManager(..., activeOrderBloc: getIt())`. Note it
only takes `ActiveOrderBloc` — `OrderActionBloc` is not wired into
`SyncManager` at all.

**2. Widget-level cross-bloc reaction via `BlocListener` + `context.read`.**
This is the dominant orchestration pattern in the app — one bloc's success
state triggers events on 2–3 sibling blocs, glued together in a page, not
bloc-to-bloc directly:

```dart
// lib/features/base_screen/presentation/pages/base_screen.dart
BlocListener<OrderActionBloc, OrderActionState>(
  listener: (context, state) {
    if (state is OrderCancelSuccess) {
      context.read<ActiveOrderBloc>().add(ClearActiveOrderEvent());
      final customerId = context.read<CustomerBloc>().state. /* ... */;
      // await a Hive call, then:
      context.read<CartBloc>().add(/* ... */);
    }
  },
  child: ...,
)
```

Prefer this pattern for new cross-feature reactions triggered from a page.
Reach for constructor injection (pattern 1) only for core/infra classes
that aren't widgets and need to react to non-UI events like connectivity.

## No `BlocObserver`

There is no global `BlocObserver`/`Bloc.observer` setup anywhere in the
codebase (`main.dart` or otherwise). If you add one for debugging or
logging, you're introducing new infrastructure, not restoring an existing
convention — don't assume transitions are already logged anywhere.

## DI section comments are aspirational, not enforced

`flutter-clean-architecture` documents DI as registered strictly under
`// Datasource...` / `// Usecase...` / `// Bloc...` section comments. In
practice, `CashierScreenBloc`, `CustomerBloc`, and `ActiveOrderBloc` are
all registered under the `// Usecase...` comment in
`lib/core/di/dependency_injection.dart`, not under `// Bloc...` where
every other bloc lives. When looking for or adding a registration, search
by class name rather than assuming it's under the "correct" section
comment — and when adding a new one, put it under the correct section
even though existing code doesn't always do so.
