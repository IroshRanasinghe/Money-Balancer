---
name: flutter-bloc-discipline
description: Use when writing or reviewing BLoC *behavior* in CodeZync POS beyond basic file layout — deciding BlocBuilder vs a narrower rebuild strategy, handling rapid repeated UI events (quantity steppers, search, taps), coordinating two BLoCs reacting to the same real-world event, or deciding whether a new BLoC belongs in the app-wide MultiBlocProvider vs a screen-scoped route BlocProvider. Assumes flutter-clear-architecture's event/state/bloc file-splitting and state-naming conventions are already followed.
---

# Flutter BLoC Discipline (CodeZync POS)

This skill covers BLoC *runtime* behavior — the things that go wrong after the
event/state/bloc files are correctly split (see `flutter-clear-architecture`
for that part, not repeated here).

## 1. Rebuild scope: this codebase does not use `BlocSelector` / `context.select` yet

A repo-wide search turns up **zero** uses of `BlocSelector` or `context.select`
in `lib/`. Every screen rebuilds via `BlocBuilder`/`BlocListener` on the whole
state object. That's the existing convention — don't introduce
`BlocSelector` as a lone exception in one new widget, because it creates an
inconsistent mental model (some screens rebuild granularly, most don't) for no
real payoff unless the state you're adding is large and the rebuild is
provably expensive.

- Default to `BlocBuilder<XBloc, XState>` matching the rest of the codebase.
- Reach for `BlocSelector` only when a state class is large (e.g.
  `CartLoaded` with `items`/`subTotal`/`totalTax`/`grandTotal`) **and** you're
  adding a widget that only cares about one field and sits next to other
  widgets that rebuild often — e.g. a cart badge that only needs `items.length`
  shouldn't rebuild every time an unrelated field changes. If you do introduce
  it, say so explicitly in the PR/commit — it's a deliberate, currently-rare
  pattern here, not the default.

## 2. Rapid repeated events: no transformer/debounce today — decide per case

`bloc_concurrency` is not a dependency (check `pubspec.yaml`) and no BLoC uses
`transformer:` on `on<Event>()`. Every handler runs with flutter_bloc's
default **concurrent** processing.

That's fine for one-shot actions (`OpenSessionEvent`, `CloseSessionEvent`,
`ValidateTerminalRequestedEvent`) where a user can't meaningfully fire the same
event twice in quick succession through normal UI flow. It's a real risk for
UI-driven bursts:

- **Quantity steppers** — `customization_qty_increment_tile.dart` and cart
  quantity controls fire one event per tap. `CartBloc._onUpdateCart` reads the
  full cart from `CustomizationStorageManager` and re-`emit`s on every call;
  rapid taps launch concurrent reads of the same evolving data with no
  ordering guarantee, so a fast double-tap can land stale data last.
- **Search-as-you-type** (if/when added to a list screen) — each keystroke
  would otherwise dispatch a new event and race an old, slower request against
  a newer one.

When you're adding or touching a handler that fires from rapid, repeatable UI
interaction (steppers, search fields, barcode-scan bursts), add
`bloc_concurrency` and pick the transformer that matches the semantics:

```dart
// pubspec.yaml: bloc_concurrency: ^0.3.0

on<UpdateCartEvent>(_onUpdateCart, transformer: sequential());
// sequential() — process taps in order, one at a time; correct for a
// stepper where each event depends on the latest persisted state.

on<SearchMenuEvent>(_onSearch, transformer: restartable());
// restartable() — cancel the in-flight search when a newer one arrives;
// correct for search-as-you-type where only the latest query matters.
```

Don't add a transformer speculatively to every handler — only where the event
can realistically fire faster than its handler resolves.

## 3. Cross-BLoC coordination: compose at the widget level, never have one BLoC call another

No BLoC in this codebase holds a reference to another BLoC or calls a method
on one — that's confirmed by grepping every `presentation/bloc/*.dart` for a
`Bloc` field/constructor param typed as another feature's BLoC. Keep it that
way. The established pattern is: stack multiple `BlocListener`s on one widget
(via `MultiBlocListener` or nested `BlocListener`s) and let each BLoC react
independently to the same real-world trigger, coordinating through explicit
widget state when ordering matters.

The reference example is
`lib/features/terminal/presentation/page/terminal_gate.dart`. It listens to
**four** independently-owned BLoCs (`TerminalBloc`, `UserSessionBloc`,
`SessionBloc`, and the PIN `LoginBloc`) on one screen, and has to solve a real
race: `SessionBloc` is an app-lifetime singleton (registered in
`codezync_pos_app.dart`'s `MultiBlocProvider`), so right after a terminal
re-pair it can still be sitting on a stale `SessionLoaded` from a *previous*
terminal, because refreshing it involves a real async gap (a secure-storage
platform-channel call). `TerminalGate` solves this with an explicit boolean
flag, not by reaching into `SessionBloc` from `TerminalBloc`:

```dart
// True from the instant a terminal validates until SessionBloc has
// produced a fresh result for THAT terminal identity. _performNavigation()
// must not act on session state while this is true...
bool _awaitingSessionRefresh = false;
```

The flag is set synchronously the moment the terminal-validation state
arrives, *before* the async gap starts, so no other `BlocListener` reading
stale state can race in ahead of it. This is the template to follow whenever
two BLoCs' states both feed one navigation/UI decision and their timing isn't
naturally synchronized: own the ordering with explicit widget state, don't
let one BLoC dispatch into or read another BLoC directly.

## 4. Lifetime: app-wide `MultiBlocProvider` vs screen-scoped route `BlocProvider`

Check `lib/codezync_pos_app.dart` before assuming a new BLoC should be
screen-scoped — in practice **most BLoCs in this app are already app-wide**.
The `MultiBlocProvider` there currently holds ~16 BLoCs (`NavigationDrawerBloc`,
`AppbarBloc`, `ItemBaseScreenBloc`, `AssignWaiterBloc`, `TableDialogPopupBloc`,
`TableBloc`, `CustomerBloc`, `DrawerTableBloc`, `DrawerCustomerBloc`,
`TerminalBloc`, `SessionBloc`, `UserSessionBloc`, `PinnedItemsBloc`,
`CartBloc`, `ActiveOrderBloc`, `OrderActionBloc`), several of them started
eagerly with an initial event (`..add(LoadPinnedItemsEvent())`,
`..add(LoadActiveOrderEvent())`). Only a handful of BLoCs are actually
screen-scoped via an inline `BlocProvider` in `app_router.dart`'s route
builders (e.g. `MenuBloc`, `AuthLoginBloc`, `LocationBloc`).

Decision rule for a **new** BLoC:

- **App-wide (`MultiBlocProvider` in `codezync_pos_app.dart`)** only if its
  state must survive navigating away from the screen that created it —
  because another screen reads it (cart badge in the app bar, active-order
  indicator, terminal/session status gating every route) or because it holds
  state for the current shift/session that outlives any one screen.
- **Screen-scoped (`BlocProvider` inline in the route's `GoRoute` builder)**
  by default for anything that only matters while one screen is open (a list
  filter, a single dialog's form state, a one-shot fetch-and-display screen).

Given how many BLoCs are already app-wide here, treat that as the *existing*
shape of this app, not necessarily the ideal to keep extending — before adding
a 17th app-wide BLoC, check whether the new feature's state is genuinely
needed outside its own screen. If it isn't, prefer the route-scoped factory;
every app-wide entry is memory and an eagerly-built widget subtree for the
lifetime of the app.

## 5. Keep BLoCs unit-testable

None of the BLoCs read import `BuildContext`, `Widget`, or any Flutter UI
class — they depend only on use cases/repositories and plain Dart. Keep it
that way: no `context.read()` calls inside a BLoC, no navigation triggered
from inside a BLoC handler (navigation belongs in the widget's
`BlocListener`, reacting to a state, as `terminal_gate.dart` and
`add_session_screen.dart` already do). This is what keeps a BLoC testable
without a widget harness — see `flutter-testing-strategy` for the actual test
patterns; this skill only owns the "why" the boundary matters.

## 6. Checklist

- [ ] Rebuild strategy matches the surrounding code (`BlocBuilder` by default;
      `BlocSelector` only for a deliberately large, high-churn state class).
- [ ] Any handler reachable via rapid repeated taps/keystrokes has a
      considered transformer (`sequential()`/`restartable()`/`droppable()`)
      or an explicit note that the default concurrent behavior is safe here.
- [ ] No BLoC holds a reference to, or calls a method on, another BLoC —
      cross-BLoC coordination happens via `BlocListener`(s) + explicit widget
      state, per `terminal_gate.dart`.
- [ ] New BLoC's lifetime (app-wide vs screen-scoped) was a deliberate choice
      against the rule in §4, not a default copy of the nearest example.
- [ ] The BLoC has zero `Widget`/`BuildContext`/navigation imports.
