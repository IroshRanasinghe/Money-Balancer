import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_tokens.dart';

/// Frosted-glass container (blur 20, translucent fill, hairline border).
/// Use only for floating chrome such as the nav bar and overlays; never wrap
/// scrolling lists in it.
class GlassSurface extends StatelessWidget {
  const GlassSurface({
    super.key,
    required this.child,
    this.radius = AppRadius.xl,
    this.padding = EdgeInsets.zero,
  });

  final Widget child;
  final double radius;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final borderRadius = BorderRadius.circular(radius);
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: t.glassColor,
            borderRadius: borderRadius,
            border: Border.all(color: t.glassBorder),
          ),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
