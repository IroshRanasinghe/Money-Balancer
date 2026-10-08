---
name: flutter-ui-development
description: Conventions for building pages and widgets in codezync_pos — BlocProvider wiring at the router, the design system (AppColors, breakpoints, ResponsiveHelper), the shared widget library in core/widgets, and the go_router checklist for adding a page. Use when adding or modifying a page, screen, or widget.
---

Every feature's `presentation/` splits into `pages/` (screen-level
widgets, one per route) and `widgets/` (feature-local reusable pieces).
This app is a **maximized desktop window** — see
[run-codezync-pos](../run-codezync-pos/SKILL.md), whose driver explicitly
maximizes the launched app because the default window size clips content
— so design and test new screens assuming a wide desktop viewport, not a
phone-sized one.

## Providing a bloc to a page

**Preferred: wrap at the `go_router` route builder**, not inside the page
widget:

```dart
// lib/core/router/app_router.dart
GoRoute(
  path: AppRoute.login,
  name: AppRouteNames.login,
  builder: (context, state) => BlocProvider(
    create: (context) => getIt<AuthLoginBloc>(),
    child: LoginScreen(),
  ),
),
```

The page then only consumes the bloc in `build()` via
`BlocBuilder`/`BlocConsumer`/`context.read` — it never calls `getIt` for
its own bloc.

**Known inconsistency — don't copy for new pages:**
`lib/features/cashier/presentation/pages/cashier_screen.dart` does the
opposite: `CashierScreen` is a `StatefulWidget` that calls
`getIt<CashierScreenBloc>()` in `initState()`, manually `.close()`s it in
`dispose()`, and wraps its own `Scaffold` in `BlocProvider.value(value:
_cashierScreenBloc, ...)` inside `build()`. The `AppRoute.cashier` route
builder just does `const CashierScreen()` — no provider at the router at
all. This directly contradicts the preferred pattern above. Only reach
for the cashier-screen shape if a bloc genuinely needs its lifecycle tied
to one specific widget's `initState`/`dispose` (rare); default to the
router-provided pattern for new pages.

## Consuming bloc state

- `BlocBuilder<X, XState>` to rebuild on every state change.
- `BlocConsumer<X, XState>` when a page needs both a rebuild *and* a
  one-shot side effect (snackbar, navigation) — e.g. `LoginScreen`.
- `BlocListener<X, XState>` alone when only the side effect is needed,
  with no local rebuild.
- These nest freely when a page reacts to multiple blocs — `base_screen.dart`
  nests `BlocBuilder<NavigationDrawerBloc,_>` → `BlocBuilder<CustomerBloc,_>`
  → `BlocListener<OrderActionBloc,_>`.
- Dispatch events / read current state imperatively via
  `context.read<XBloc>()`. Don't use `context.watch<XBloc>()` — it isn't
  used anywhere in this codebase; `BlocBuilder`/`BlocConsumer` are the
  rebuild mechanism instead.

See [flutter-bloc](../flutter-bloc/SKILL.md) for the
`BlocListener`-as-cross-bloc-orchestrator pattern this feeds into.

## Design system

**Colors — `lib/res/app_colors.dart`.** One static `AppColors` class with
~19 named constants. Names are branded/visual, not semantic
(`sharkColor`, `bondiBlueColor`, `selectiveYellowColor`,
`wildSandColor`) rather than `primary`/`error` — there's no
`ThemeData`/`ColorScheme` in use anywhere. Always reference
`AppColors.xxx`; never a raw `Color(0x...)` literal in feature code.

**Assets — `lib/res/assets.dart`.** Very sparse (2 constants) — most asset
paths in the codebase are inlined as string literals rather than routed
through this file. It exists but is underused; don't treat its current
emptiness as "this project doesn't use a constants file for assets," but
also don't be surprised to find raw path strings elsewhere.

**Typography.** No `TextTheme`/`ThemeData` font config — `'Poppins'` is
hardcoded per-widget. See the three competing text/scaling utilities
below.

## Responsive breakpoints — three competing utilities, no single winner

`lib/core/design_system/responsive/breakpoint.dart` defines the constants:

```dart
const kLargeDesktopBreakpoint = 1920.0;
const kMediumDesktopBreakpoint = 1440.0;
const kSmallDesktopBreakpoint = 1350.0;
const kSmallTabletBreakpoint = 850.0;
const kMediumTabletBreakpoint = 1099.5;
const kLargeTabletBreakpoint = 1340.0;
const kSideMenuWidth = 300.0;
const kNavigationRailWidth = 72.0;
```

`ResponsiveHelper` (`responsive_helper.dart`) exposes boolean checks
against them (`isMobile`, `isSmallDesktop`, `isMediumTablet`, etc.) via
`MediaQuery.of(context).size.width` — used ~30 times for
branch-by-breakpoint layout, e.g.
`ResponsiveHelper.isMobile(context) ? ... : ...` in `cashier_screen.dart`.
**Known inconsistency:** `isTab`/`isDesktop` in that same file use
hardcoded `1300`/`650` literals instead of the `k*Breakpoint` constants
sitting right next to them in `breakpoint.dart` — if you touch either of
those two methods, migrate them to the named constants rather than adding
a third hardcoded number nearby.

Beyond breakpoint checks, **three separate scaling/typography utilities
coexist** with comparable usage counts — pick whichever the sibling code
you're editing already uses, don't introduce a fourth:

- `lib/ResponsiveKit/responsive_config.dart` → `SizeConfig(context)`:
  `widthScaleFactor = screenWidth/1920`, `heightScaleFactor =
  screenHeight/1080`, with `.scale()`/`.width()`/`.height()`/`.padding()`/
  `.borderRadius()` helpers (~31 usages).
- `lib/ResponsiveKit/responsive_text.dart` → `ResponsiveText(text, {fontSize,
  weight, fontcolor, ...})`, a widget that scales `fontSize` by
  `screenWidth/1920` and hardcodes `fontFamily: 'Poppins'` (~25 usages).
- `lib/core/widgets/custom_text_poppins.dart` → `CustomTextPoppins({text,
  fontSize, fontWeight, color, ...})`, a plain non-scaling `Text` with
  `fontFamily: "Poppins"` (~5 usages).

Both `SizeConfig` and `ResponsiveText` calibrate against a **1920×1080**
reference canvas — treat that as the effective design-target resolution
for new screens, consistent with this being a maximized desktop app.

## Reusable shared widgets — check these before building a new one

`lib/core/widgets/` (a `widgets.dart` barrel file re-exports only a
subset — buttons and text fields — so import directly from the specific
file for anything else):

- **Buttons:** `buttons/elevated_button_widget.dart`
  (`ElevatedButtonWidget`, `AppColors` defaults baked in),
  `buttons/bubble_button_widget.dart`, `buttons/bubble_icon_button_widget.dart`,
  `buttons/elevated_icon_button_widget.dart`, `buttons/text_button_widget.dart`.
- **Text fields:** `text_fields/text_field_widget.dart`,
  `text_field_widget_2.dart`, `text_form_field_widget.dart`,
  `text_fields/phone_number_form_field_widget.dart`.
- **Text/app bar:** `custom_text_poppins.dart` (`CustomTextPoppins`),
  `custom_appbar.dart` (`CustomAppbar`, used as a `PreferredSize` app bar).
- **Other:** `loading_overlay_widget.dart`, `guests_count_dialog.dart`,
  `image_view_widget.dart`, `image/fading_network_image.dart`,
  `image/mc_donalds_logo.dart`, `items/item_tile.dart`,
  `table_item_tile.dart`, `background_blur/background_blur.dart`.

**Don't confuse `core/widgets/` with `core/widgets_helper/`** — the
latter currently contains only `TrianglePainter.dart` (a `CustomPainter`,
not a widget). Despite the similar name, it's a different, much smaller
directory for painter/helper classes, not another widget catalog.

## Adding a new page — checklist

1. Add a path constant to `AppRoute` (`lib/core/router/app_route.dart`).
2. Add a matching name constant to `AppRouteNames`
   (`lib/core/router/app_route_names.dart`).
3. Add a `GoRoute(path: AppRoute.x, name: AppRouteNames.x, builder: ...)`
   entry to `AppRouter.router.routes` in `app_router.dart`.
4. If the page needs a bloc, wrap it there:
   `builder: (context, state) => BlocProvider(create: (context) => getIt<TheBloc>(), child: ThePage())`
   (see the cashier-screen exception above — this is the rule for new
   code, not a universal truth about existing code).
5. Pass route params via `state.extra` (cast at the call site, e.g.
   `state.extra as TerminalEntity?`) — there are no typed route-data
   classes in this router.
6. Navigate with `context.goNamed(AppRouteNames.x)`, not `context.go(path)`.

## Verifying a UI change

Type-checking and widget tests don't confirm a screen actually renders
correctly. Use [run-codezync-pos](../run-codezync-pos/SKILL.md) to build,
launch, and screenshot the real Windows app after a UI change.
