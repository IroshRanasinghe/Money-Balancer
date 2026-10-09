# Modern UI Redesign — Design & Implementation Brief (MB-UI)

Requested by the user on 2026-10-09: "change UI to modern UI". The direction comes from CLAUDE.md's UI goals: premium finance app, Material 3, modern and minimal, soft shadows, rounded corners, glassmorphism where appropriate, smooth animations, mobile-first, dark mode, and the existing palette.

## Non-negotiables
- **Presentation only.** No changes to domain/data layers, BLoC events/state semantics, use cases, routes, or DI, except what Phase 0 lists. Every existing behaviour, validation message, SnackBar text, confirm dialog, paywall trigger and navigation path keeps working exactly as before.
- Keep the user-visible copy unless this brief changes it.
- Light **and** dark mode must both look intentional. Never hard-code `Colors.white`/`Colors.black` for surfaces or text; use the theme and tokens.
- Mobile-first at 360–430 px wide. No overflow at 360 px or at 1.3× text scale.
- `const` wherever possible. Animations ≤ 350 ms with `Curves.easeOutCubic`. Respect `MediaQuery.disableAnimations` (skip animations when it's true).
- No test files. Verification: `flutter analyze` → "No issues found!" (build_runner only if a freezed file changes, which shouldn't happen).

## Visual language
- **Font:** Plus Jakarta Sans, **bundled** as assets (no runtime fetching): `assets/fonts/PlusJakartaSans[wght].ttf` from `https://github.com/google/fonts/raw/main/ofl/plusjakartasans/PlusJakartaSans%5Bwght%5D.ttf`, plus its `OFL.txt` license next to it. It's a variable font: declare it once in pubspec as family `PlusJakartaSans`, and in the TextTheme give each style both `fontWeight` and the matching `fontVariations: [FontVariation('wght', <weight>)]` so weights render on every platform.
- **Money figures:** `fontFeatures: [FontFeature.tabularFigures()]`, weight 700, slight negative letter-spacing on large sizes.
- **Type scale (TextTheme):** displaySmall 34/800 (hero balance), headlineSmall 24/800 (page titles), titleLarge 20/700, titleMedium 16/700, titleSmall 14/600, bodyLarge 16/500, bodyMedium 14/500, bodySmall 12/500, labelLarge 14/700, labelMedium 12/600, labelSmall 11/600 with letterSpacing 0.4.
- **Colours** (keep the existing palette roles, then extend):
  - Light: background `#F5F7FB`, surface `#FFFFFF`, surfaceAlt `#EEF2F8`, textPrimary `#0F172A`, textSecondary `#64748B`, border `#E2E8F0`.
  - Dark: background `#0B1120`, surface `#121A2B`, surfaceAlt `#1A2438`, textPrimary `#F1F5F9`, textSecondary `#94A3B8`, border `#24304A`.
  - Brand gradient: `#2563EB → #4F46E5 → #7C3AED` (topLeft→bottomRight). Premium gradient: `#F59E0B → #F97316`.
  - Semantic: success `#22C55E`, warning `#F59E0B`, danger `#EF4444`, each with a soft container at 12% alpha (light) or 18% (dark).
- **Radii:** 12 (chips/inputs), 16 (tiles), 24 (cards), 28 (hero cards and bottom sheets).
- **Spacing:** 4, 8, 12, 16, 20, 24, 32. Page gutter is 20.
- **Shadows (light only; dark uses a 1 px `border` instead):** card = `[BoxShadow(color: #0F172A @ 6%, blurRadius: 24, offset: (0, 8)), BoxShadow(color: #0F172A @ 3%, blurRadius: 4, offset: (0, 1))]`. Hero = brand-coloured shadow `#2563EB @ 30%`, blur 32, offset (0, 16).
- **Glass:** `BackdropFilter(ImageFilter.blur(sigmaX: 20, sigmaY: 20))` on a surface at 72% alpha (light) or 60% (dark), with a 1 px border of white at 40% (light) or 8% (dark). Use it only for the floating nav bar and sheet/overlay chrome. Never put lists inside blur.

## Phase 0 — Foundation (one agent, before any screen work)
Create `lib/core/theme/`, and move `theme.dart` there. Update imports; `AppColors` keeps its existing names, so nothing else breaks.
- `app_colors.dart`: palette above (the existing names stay, new ones added).
- `app_tokens.dart`: a `ThemeExtension<AppTokens>` holding background/surface/surfaceAlt/textPrimary/textSecondary/border, success/warning/danger and their containers, `brandGradient`, `premiumGradient`, `cardShadow`, `heroShadow`, `glassColor`, `glassBorder`, with `lerp`/`copyWith`. Add `extension AppTokensX on BuildContext { AppTokens get tokens => Theme.of(this).extension<AppTokens>()!; }`.
- `app_spacing.dart`: `AppSpacing` and `AppRadius` constants.
- `app_theme.dart`: rebuild light/dark `ThemeData` from the above. Cover: TextTheme with the font, `cardTheme` (radius 24, no elevation, surface colour), `inputDecorationTheme` (filled surfaceAlt, radius 16, no border, focused 1.5 px primary border, 16/16 content padding), `filledButtonTheme` (height 56, radius 18, labelLarge), `outlinedButtonTheme`, `textButtonTheme`, `segmentedButtonTheme` (pill), `chipTheme` (pill, surfaceAlt, no border), `bottomSheetTheme` (radius 28 top, surface, showDragHandle true), `dialogTheme` (radius 28), `snackBarTheme` (floating, radius 16, inverse surface), `switchTheme`, `progressIndicatorTheme`, `dividerTheme` (border colour, 1 px), `listTileTheme` (radius 16, 16 px horizontal padding), `appBarTheme` (transparent, no scroll tint, headlineSmall-ish 22/800 title, `centerTitle: false`), `floatingActionButtonTheme` (radius 20, primary), and `pageTransitionsTheme` (see below).
- **Shared UI kit** in `lib/shared/widgets/ui/` (each file small, documented, const-friendly):
  - `AppCard({child, padding = 20, onTap, gradient, color})`: surface, radius 24, card shadow (light) or border (dark), with an optional `PressableScale` when `onTap` is set.
  - `PressableScale({child, onTap, scale = 0.97})`: animated scale on press, with `HapticFeedback.selectionClick()` on tap.
  - `GlassSurface({child, radius, padding})`.
  - `IconBadge({icon, color, size = 44})`: rounded-square (radius 14) container at 14% alpha of `color`, with the icon in `color`.
  - `SectionHeader({title, actionLabel, onAction})`: titleMedium plus a TextButton.
  - `AmountText(amount, {currency, style, signed = false, type})`: formatCurrency, tabular figures; when `signed`, shows +/- and success/danger colour by transaction type.
  - `AnimatedCount({value, builder})`: TweenAnimationBuilder from the previous value, 600 ms.
  - `StaggeredFadeIn({index, child})`: fade + 12 px upward slide, 40 ms × index delay (capped at 8), then appears immediately.
  - `StatusPill({label, color})`: small pill with container colour and label.
  - `SheetScaffold({title, child, actions})`: the standard bottom-sheet layout (title row, scrollable body with keyboard insets, 20 px padding, safe area).
  - `SettingsGroup({title, children})` and `SettingsTile({icon, iconColor, title, subtitle, trailing, onTap})`: iOS-style grouped list. Coloured `IconBadge` (size 36), dividers inset to the text.
- **Restyle the existing shared widgets** in `lib/shared/widgets/`, keeping their constructors:
  - `EmptyState`: a soft circular gradient blob behind a 56 px icon, titleMedium message, bodySmall secondary colour.
  - `CategoryIcon`: becomes an `IconBadge` with a stable per-category colour (map every category in `AppCategories` to a distinct hue; unknown → primary).
  - `TransactionTile`: `IconBadge`, title (category) titleSmall, subtitle (payment/card/account · notes) bodySmall secondary, trailing `AmountText(signed: true)` with the date below in labelSmall. Keep the recurring icon. No ListTile chrome; padding 12/16.
  - `MonthSelector`: a pill with chevron buttons and an animated month label (AnimatedSwitcher with a slide).
- **Navigation shell:** replace `AppBottomNav` with a **floating glass nav bar**.
  - `GlassSurface`, radius 28, 12 px from the sides and bottom (above the safe area), height 68.
  - Each of the 5 destinations is an icon. The selected one animates into a pill (primary at 12%) with icon + label (labelMedium, primary). The others show the outlined icon in textSecondary.
  - `HapticFeedback.selectionClick()` on change. Same routes and behaviour as now.
  - `AppShell` uses `extendBody: true`. Expose `const kNavBarClearance = 96.0` from the shell, and pages add it as bottom list padding so content scrolls behind the bar.
- **Page transitions:** pushed GoRoutes (`cards`, `accounts`, `accountDetail`, `recurring`, `goals`, `premium`, add/edit income/expense) use a shared `CustomTransitionPage` helper in `lib/core/config/page_transitions.dart`: fade + 4% upward slide, 300 ms. Shell tabs stay `NoTransitionPage`, but the tab body cross-fades with `AnimatedSwitcher` keyed by location. This is the only router change allowed.
- **Demo data for screenshots:** `lib/core/data/dummy_data.dart` (the name CLAUDE.md already references), `Future<void> seedDummyDataIfEmpty()`.
  - It runs from `main.dart` only when `const bool.fromEnvironment('DEMO_DATA')` is true, and only when the transactions box is empty.
  - Through the existing use cases/repositories (via `sl`) it creates:
    - 2 accounts (`Everyday` bank, opening 1200; `Cash` cash, 150)
    - 1 card (`Visa Platinum` credit, last4 `4242`, no full number)
    - ~25 transactions spread over the current and previous 5 months across 8 categories (salary 3200/month on the 1st, plus varied expenses)
    - 4 budgets for the current month (Food 400 at ~85% used, Transport 150 at ~40%, Shopping 300 over budget, Bills 250 at ~60%)
    - 2 recurring rules (Salary monthly, Netflix 15.99 monthly)
    - 2 goals (`Emergency fund` 5000 with 3200 saved, target date 8 months out; `New laptop` 1800 with 450 saved)
  - Never runs in normal builds.
- Commit Phase 0 by itself.

## Phase 1 — Screens (three agents in parallel after Phase 0; disjoint file ownership)

### Workstream A — Home & money entry
Owns: `features/dashboard/presentation/**`, `features/transactions/presentation/**`, `features/expense/presentation/pages/**`, `features/income/presentation/pages/**`, `lib/shared/widgets/transaction_form.dart`.
- **Dashboard:**
  - Header: greeting by time of day (`Good morning` / `Good afternoon` / `Good evening`, local hour < 12 / < 18 / else), the month below in textSecondary, and on the right a 44 px circular avatar button (gradient, `Icons.person_rounded`, with a small amber crown dot when premium) → `/settings`.
  - **Hero balance card:** radius 28, brand gradient, hero shadow, two large blurred decorative circles, `Total balance` label, `AnimatedCount` displaySmall white balance, and an `Accounts →` pill (glass on gradient) as the existing tap target. Inside the card at the bottom, a row of two glass sub-pills: `↓ Income` and `↑ Expenses` this month, each with its amount. This replaces the separate summary cards.
  - **Quick actions row:** 4 equal circular-ish buttons (`IconBadge` 52 + labelMedium): `Expense` → add expense, `Income` → add income, `Transfer` → accounts page, `Goals` → goals. The existing Add FAB and sheet stay available (the FAB can become a smaller `FloatingActionButton` with `Icons.add_rounded`, placed above the floating nav).
  - **Savings goals:** `SectionHeader` plus a horizontal `PageView`/ListView of compact goal cards (220 px wide), each with a circular progress ring. Keep the existing empty and "all completed" behaviour.
  - **Recent transactions:** `SectionHeader`, then one `AppCard` containing the `TransactionTile`s separated by inset dividers, with `StaggeredFadeIn`.
- **Transactions page:**
  - Title `Transactions`.
  - A pill search/filter row in the existing filter widget (restyle the chips as pill `ChoiceChip`s and the type filter as a segmented pill).
  - The list is **grouped by day** with headers `Today` / `Yesterday` / `EEE, MMM d`, plus the day's net total in labelSmall on the right. Each group sits in an `AppCard`.
  - The sort menu becomes an `IconButton(Icons.swap_vert_rounded)` opening the same options in a bottom sheet with radio-style rows.
  - Keep swipe/tap behaviours exactly as they are.
- **Transaction form** (expense/income add/edit):
  - **Big amount entry** at the top: a centered currency-prefixed amount `TextField` (displaySmall, tabular, no fill/border), with the type shown as a coloured `StatusPill` (`Expense` danger / `Income` success) above it.
  - **Category** as a wrap/grid of selectable chips: `IconBadge` 40 + label, 4 per row, with the selected one ringed in primary.
  - Date, payment method, card and account as `SettingsTile`-style rows inside an `AppCard` (tap → existing pickers/dropdowns, or keep the dropdowns styled).
  - Notes field, then the full-width submit button pinned at the bottom with safe area.
  - Same validation and messages.

### Workstream B — Budget, Reports & Goals
Owns: `features/budget/presentation/**`, `features/reports/presentation/**`, `features/goals/presentation/**`.
- **Budget page:**
  - `MonthSelector` pill.
  - **Summary hero card:** a large circular ring (CustomPainter, stroke 14, rounded caps, gradient sweep primary→violet; amber when ≥ 80%, danger when > 100%) showing total spent ÷ total limit, the percent in the centre, and `<spent> of <limit>` plus `<remaining> left` beside it.
  - Each budget is an `AppCard` with `CategoryIcon`, category, a `StatusPill` (`On track` success / `Warning` warning / `Over` danger), a 10 px rounded progress bar (animated from 0 on load), and `<spent> / <limit>` plus `<remaining> left`.
  - Keep the existing add/edit/delete flows; restyle `BudgetFormSheet` with `SheetScaffold`.
- **Reports page:**
  - `MonthSelector` pill.
  - A summary row of 3 compact stat cards (Income success, Expenses danger, Net primary), each with an `IconBadge` and `AmountText`. Savings rate becomes a `StatusPill` under them.
  - The category donut becomes an `AppCard` with a **donut** (centerSpaceRadius ~62, sectionsSpace 2, rounded look) and the total in the centre. The legend below lists each category as `CategoryIcon` + name + amount + percent, with a thin percent bar. Tapping a legend row or slice highlights that slice (touch callback → enlarge radius).
  - Income vs expenses becomes an `AppCard` with rounded bars (radius 6, width 10, success/danger pairs), dashed horizontal grid lines in border colour, a minimal axis (bodySmall secondary), and a styled tooltip.
- **Goals page & widgets:** `GoalCard` becomes an `AppCard` with an `IconBadge` (flag, goal colour), name, a 56 px progress ring with the percent, `<saved> of <target>`, a `By <date> · Save <x>/month` row, and a `Completed` `StatusPill`. The action sheet, form sheet and amount sheet use `SheetScaffold`. Both the empty state and the paywall keep working.

### Workstream C — Settings, Accounts, Cards, Recurring, Premium
Owns: `features/settings/presentation/**`, `features/accounts/presentation/**`, `features/cards/presentation/**`, `features/recurring/presentation/**`, `features/premium/presentation/**`, `features/backup/presentation/**` (if it has widgets), `lib/shared/premium_gate.dart` (visual only).
- **Settings:**
  - Large title.
  - A **premium card** at the top: premium gradient, crown icon, `Go Premium` / `Premium · Active` text, a white pill `Upgrade` / `Manage`. Same tap target.
  - Then `SettingsGroup`s:
    - **Preferences:** Currency (trailing value + chevron opens a bottom sheet with radio rows), Dark mode (switch), and Budget alerts (the existing logic, `PRO` StatusPill when free, hidden when unsupported).
    - **Money:** Accounts, My cards, Recurring, Savings goals → `/goals`.
    - **Data:** Export CSV (PRO pill), Back up data (subtitle), Restore.
  - Each tile gets a distinct `IconBadge` colour. The version footer reads `Money Balance` in labelSmall secondary.
- **Accounts:**
  - Total header as a gradient hero card (`Total in accounts`).
  - Account tiles as `AppCard`s with an `IconBadge` (account colour), name, type, and the balance in `AmountText`.
  - A transfer action button in the hero card.
  - The detail page header becomes a hero card in the account colour, with activity grouped by day as on the Transactions page (reuse the same grouping helper by importing it from Workstream A's file. **If it doesn't exist yet**, write a local private helper; don't edit A's files).
  - Restyle the form sheets with `SheetScaffold`.
- **Cards:**
  - `BankCardTile` becomes a realistic card: aspect ratio 1.586, radius 24, the card's colour as a gradient with a subtle diagonal sheen and two decorative circles, a chip glyph (rounded rect in gold gradient), the network label top-right in bold italic, `•••• 4242` in the middle with wide letter spacing (tabular), and nickname, expiry and `This month` along the bottom.
  - Cards in a vertical list with a 16 px gap.
  - The form sheet uses `SheetScaffold` and shows a live preview of the card at the top.
- **Recurring:** tiles become `AppCard`s with `CategoryIcon`, category, a frequency `StatusPill`, `Next <date>`, a signed amount, and the switch. The form sheet uses `SheetScaffold`, with frequency as a segmented pill.
- **Premium page:**
  - Full-bleed brand-gradient hero with a glass crown badge and the title.
  - Benefits as rows with success check `IconBadge`s.
  - Package cards as selectable `AppCard`s with an animated border (2 px primary when selected), the price in titleLarge, the period, and a `Best value` premium-gradient pill.
  - The CTA uses a gradient-filled 56 px button.
  - The loading, error/retry, unavailable and debug states are all restyled but kept.

## Process rules for Phase 1 agents
- Touch **only** the files you own, plus new files under your own feature folders. If you need a new shared component, build it privately inside your feature, not in `lib/shared/` (Phase 0 owns that).
- Commit with a **pathspec** so you never pick up another agent's changes: `git add <your paths> && git commit -m ... -- <your paths>`. If `.git/index.lock` exists, wait 5 s and retry (up to 10 times).
- Don't run `flutter build web`; the controller builds once at the end. Do run `flutter analyze` on the whole project; if errors are in files you don't own, report them and don't fix them.

## Out of scope
New features, copy rewrites, localization, app icons and splash screens, tablet-specific layouts.
