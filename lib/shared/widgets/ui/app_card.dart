import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_tokens.dart';
import 'pressable_scale.dart';

/// Standard surface: radius 24, soft shadow in light mode, 1 px border in dark.
/// Set [gradient] or [color] to override the fill; [onTap] adds press feedback.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.onTap,
    this.gradient,
    this.color,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Gradient? gradient;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final card = DecoratedBox(
      decoration: BoxDecoration(
        color: gradient == null ? (color ?? t.surface) : null,
        gradient: gradient,
        borderRadius: AppRadius.lgAll,
        border: t.isDark ? Border.all(color: t.border) : null,
        boxShadow: t.cardShadow,
      ),
      child: Padding(padding: padding, child: child),
    );
    return PressableScale(onTap: onTap, child: card);
  }
}
