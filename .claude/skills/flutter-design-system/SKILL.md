---
name: flutter-design-system
description: Use when building or editing any screen, dialog, or widget in CodeZync POS — choosing between text/scaling helpers, picking a reusable button/field/image widget from lib/core/widgets, building a new dialog, or touching color/theme. Documents which of the app's two competing responsive systems is actually dominant, the real reusable-widget catalog with constructor signatures, the showDialog + BackgroundBlur dialog pattern, and the AppColors-driven (not ThemeData-driven) color convention.
---

# Flutter Design System (CodeZync POS)

This app has **two parallel responsive systems and two parallel text widgets**
that grew up side by side. This skill tells you which one is actually load-bearing
today so new screens don't add a third variant.

## 1. Text: `ResponsiveText` is the dominant pattern, not `CustomTextPoppins`

Despite `CustomTextPoppins` (`lib/core/widgets/custom_text_poppins.dart`) looking
like "the" text widget, it's used in only a handful of files. The pattern actually
used across ~20+ feature screens (table, item, appbar, base_screen, receipt,
payment_details, order_details_pannel, navigation_drawer, …) is
**`ResponsiveText`** from `lib/ResponsiveKit/responsive_text.dart`:

```dart
ResponsiveText(
  'Total',
  fontSize: 16.0,       // required — scaled internally, pass your design-spec px value
  weight: FontWeight.w600,
  fontcolor: AppColors.sharkColor,
  textAlign: TextAlign.start,  // default is TextAlign.center — override for left-aligned text
  maxline: 2,                  // default 1
)
```

It scales `fontSize` by `MediaQuery.of(context).size.width / 1920` — i.e. sizes
are authored against a 1920px-wide reference canvas.

**Rule:** in a file that already uses `ResponsiveText`, keep using it. In a brand
new file, default to `ResponsiveText` for consistency with the majority of the
codebase. Only reach for `CustomTextPoppins` if the surrounding widget is one of
the small number of files that already use it (currently: `custom_appbar.dart`
and a few others) — don't mix both in the same screen. Never use raw `Text(...)`
with a manually-typed `fontFamily: 'Poppins'` for new code; that duplicates what
both wrappers already do and is easy to typo.

## 2. Sizing: `SizeConfig` vs `ResponsiveHelper` — different jobs

Both live in the codebase and are both current — they are **not** duplicates of
each other, they answer different questions:

- **`SizeConfig`** (`lib/ResponsiveKit/responsive_config.dart`) — "how big should
  this dimension be on *this* screen, scaled from a 1920×1080 design reference?"
  Used for paddings, radii, explicit widths/heights inside a widget's `build()`:

  ```dart
  final sizeConfig = SizeConfig(context);
  Padding(
    padding: sizeConfig.padding(12.0),          // EdgeInsets.all(scaled)
    child: Container(
      width: sizeConfig.width(200.0),
      height: sizeConfig.height(48.0),
      decoration: BoxDecoration(
        borderRadius: sizeConfig.borderRadius(8.0),
      ),
    ),
  )
  ```

  This is the dominant sizing mechanism — used in 20+ files including most of
  `core/widgets/`. Instantiate it once at the top of `build()`, don't call
  `SizeConfig(context)` repeatedly per widget subtree.

- **`ResponsiveHelper`** (`lib/core/design_system/responsive/responsive_helper.dart`)
  — "which *layout variant* am I in?" (`isTab`, `isDesktop`, `isSmallDesktop`,
  `isMediumDesktop`, `isLargeDesktop`, `isMobilePhone`, `isWeb`), backed by the
  breakpoint constants in `breakpoint.dart` (`kSmallTabletBreakpoint = 850`,
  `kMediumTabletBreakpoint = 1099.5`, `kLargeTabletBreakpoint = 1340`,
  `kSmallDesktopBreakpoint = 1350`, `kMediumDesktopBreakpoint = 1440`,
  `kLargeDesktopBreakpoint = 1920`). Used for branching between materially
  different widget trees per form factor (see `table_screen.dart`,
  `table_tablet_screen.dart`, `table_desktop_screen.dart` as a real example of
  one feature with size-specific screen variants), not for scaling a single
  tree's dimensions.

**Rule:** use `SizeConfig` to scale dimensions within one layout. Use
`ResponsiveHelper` only when you need to pick between structurally different
layouts (e.g. tablet screen vs desktop screen vs a side panel appearing only on
wide layouts). Don't use `ResponsiveHelper.isDesktop(context)` as a substitute
for scaling a single value — that's what `SizeConfig` is for.

## 3. Reusable widget catalog (`lib/core/widgets/`)

Check this list before writing a raw Material widget. `widgets.dart` is a
partial barrel file (only exports buttons/text-fields) — the rest are imported
directly by path.

| Widget | File | Purpose | Key params |
|---|---|---|---|
| `ElevatedButtonWidget` | `buttons/elevated_button_widget.dart` | Primary bordered button, static (non-scaled) sizing, optional icon or SVG leading | `text`, `onPressed`, `textColor`/`backgroundColor`/`borderColor` (default to `AppColors`), `radius`, `icon`, `svgPicturePath` |
| `TextButtonWidget` | `buttons/text_button_widget.dart` | Same shape as above but `SizeConfig`-scaled and uses `ResponsiveText` internally | same as above, plus scales via internal `SizeConfig` |
| `BubbleButtonWidget` | `buttons/bubble_button_widget.dart` | Pill button with a downward-pointing triangle tail (tooltip/callout style) | `text`, `onPressed`, `downArrowWidth/Height`, `marginBottom` |
| `TextFieldWidget` (in `text_fields/text_field_widget_2.dart`, class name is `TextFieldWidget`) | stateless `TextField` wrapper | `controller`, `hintText`, `prefix`/`suffix`, `borderColor`, `radius`, `keyboardType`, `onSubmitted` |
| `TextFormFieldWidget` | `text_fields/text_form_field_widget.dart` | Same shape, wraps `TextFormField` for `validator` support | adds `validator`, `prefixIcon`/`sufixIcon` (note the typo'd param name — match it) |
| `CustomAppbar` | `custom_appbar.dart` | The branded top bar with the pos logo + bottom accent line | no params — screen-specific content is composed around it, not passed in |
| `CustomTextPoppins` | `custom_text_poppins.dart` | Minimal Poppins `Text` wrapper — low adoption, see §1 | `text`, `fontSize`, `fontWeight`, `color`, `overflow`, `textDecoration` |
| `ImageViewWidget` | `image_view_widget.dart` | Bordered/rounded image card with placeholder icon fallback for empty URLs | `width`, `height`, `imageUrl`, `borderRadius`, `borderColor`, `placeholderIcon` |
| `FadingNetworkImage` | `image/fading_network_image.dart` | Disk-cached network image (via `cached_network_image`) with fade-in + spinner; used internally by `ImageViewWidget` when `imageUrl` is non-empty | `imageUrl`, `width`, `height`, `fit`, `errorBuilder` |
| `McDonaldsLogo` | `image/mc_donalds_logo.dart` | Circular branded logo badge | `radius`, `borderWidth` |
| `LoadingOverlayWidget` | `loading_overlay_widget.dart` | Full-screen transparent scaffold with a blurred background + centered spinner, for blocking async operations | no params |
| `BackgroundBlur` | `background_blur/background_blur.dart` | `BackdropFilter` blur wrapper — the backing primitive `LoadingOverlayWidget` and several dialogs use to dim/blur content behind an overlay | `widget`, `sigmaX`/`sigmaY` |

Feature-specific tiles/dialogs that aren't generic enough to be "core" (e.g.
`items/item_tile.dart`, `table_item_tile.dart`, `guests_count_dialog.dart`) still
live under `core/widgets/` in this codebase even though they're closer to
feature widgets — check there too before assuming something doesn't exist yet.

## 4. Dialog pattern

Dialogs in this app are plain widgets shown via the standard Flutter API —
there is no custom dialog-transition wrapper:

```dart
showDialog(
  context: context,
  builder: (context) => const AssignWaiterDialog(),
);
```

called from a `GestureDetector`/`onTap` on the field it's replacing (see
`order_details_panel.dart`'s table/guests/waiter fields, each wrapped in
`AbsorbPointer` around a `TextFieldWidget` so the field looks interactive but
only opens the dialog).

Internally, a non-trivial dialog (see `CoinsDialog`) is its own
`StatefulWidget`:

```dart
class XDialog extends StatefulWidget {
  final Function(...) onConfirm;   // result callback, not Navigator.pop(result)
  const XDialog({super.key, required this.onConfirm, ...});
  @override
  State<XDialog> createState() => _XDialogState();
}

class _XDialogState extends State<XDialog> {
  late final XBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = XBloc(...);       // note: some dialog-local BLoCs are constructed
  }                            // directly here, NOT resolved via getIt — this is
                                // an accepted exception to the usual DI rule for
                                // ephemeral, dialog-scoped state.

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }
  ...
}
```

Use `widget.onConfirm(result)` + `Navigator.pop(context)` to return data,
rather than `Navigator.pop(context, result)` + `.then()` on the caller — that's
the convention `CoinsDialog` follows. Wrap dimmed/blurred backgrounds with the
shared `BackgroundBlur` widget instead of a custom `BackdropFilter`. Use
`ResponsiveHelper` inside the dialog if it needs a materially different layout
on tablet vs desktop, and `SizeConfig` for internal scaling either way.

## 5. Color: `AppColors`, not `ThemeData`

`lib/res/app_colors.dart` is the actual color source of truth — a flat list of
named static `Color` constants (`AppColors.primaryColor`, `sharkColor`,
`selectiveYellowColor`, `grayColor`, `lightGrayColor`, `whiteColor`,
`alabasterColor`, `activeColor`, etc.). Nearly every widget takes its colors as
constructor defaults pointing at `AppColors.*`, or has the caller pass one in
explicitly.

`ThemeData` in `lib/codezync_pos_app.dart` (`ColorScheme.fromSeed(seedColor:
Colors.deepPurple)`) is the Flutter-generated Material 3 default — it is
**not** meaningfully consumed by feature widgets. Don't add a new color by
reaching for `Theme.of(context).colorScheme...`; add or reuse a constant in
`AppColors` instead, matching the existing naming style (a descriptive/brand
name, e.g. `bondiBlueColor`, `cinnabarColor`, rather than a semantic name like
`errorColor`) so it's consistent with what's already there.

## 6. Landscape lock

Set once in `main.dart` after `runApp` is prepared:

```dart
SystemChrome.setPreferredOrientations([
  DeviceOrientation.landscapeLeft,
  DeviceOrientation.landscapeRight,
]);
```

This is app-wide and global — don't add per-screen orientation overrides. Every
new screen should be designed and tested in landscape only; portrait layouts
are not a supported target for phone/tablet.

## 7. Checklist for a new screen/dialog

- [ ] Text goes through `ResponsiveText` (default) or `CustomTextPoppins` only
      if the file already standardized on it — never raw `Text` with a manual
      `fontFamily`.
- [ ] Dimensions/padding/radius scaled via `SizeConfig(context)`, instantiated
      once per `build()`.
- [ ] Layout branching (tablet vs desktop vs phone) via `ResponsiveHelper`, not
      raw `MediaQuery` width checks.
- [ ] Buttons/fields/images reused from `lib/core/widgets/` (see table in §3)
      before writing a new one-off widget.
- [ ] Colors come from `AppColors` constants, not inline hex values or
      `Theme.of(context)`.
- [ ] Dialogs use `showDialog` + a dedicated `StatefulWidget`, return data via
      an `onConfirm`-style callback, and blur their background with
      `BackgroundBlur` if the design calls for a dimmed backdrop.
- [ ] Screen is designed for landscape only.
