import 'package:flutter/material.dart';

/// Rounded-square (radius 14) tile tinted with [color] at 14% alpha, holding
/// [icon] in [color].
class IconBadge extends StatelessWidget {
  const IconBadge({
    super.key,
    required this.icon,
    required this.color,
    this.size = 44,
  });

  final IconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.14),
      borderRadius: BorderRadius.circular(size < 40 ? 11 : 14),
    ),
    alignment: Alignment.center,
    child: Icon(icon, color: color, size: size * 0.5),
  );
}
