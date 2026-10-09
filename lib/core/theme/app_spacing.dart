import 'package:flutter/widgets.dart';

/// Spacing scale (logical px). Page gutter is [AppSpacing.gutter].
class AppSpacing {
  const AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;

  /// Horizontal page padding.
  static const double gutter = 20;
}

/// Corner radii.
class AppRadius {
  const AppRadius._();

  /// Chips, inputs.
  static const double sm = 12;

  /// Tiles.
  static const double md = 16;

  /// Cards.
  static const double lg = 24;

  /// Hero cards and bottom sheets.
  static const double xl = 28;

  static const BorderRadius smAll = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdAll = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgAll = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius xlAll = BorderRadius.all(Radius.circular(xl));
}
