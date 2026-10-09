import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';

/// Circular progress ring with a gradient sweep and rounded caps. The ring
/// animates from 0 on first build. Amber when [ratio] >= 0.8, red when > 1.
class BudgetRing extends StatelessWidget {
  const BudgetRing({super.key, required this.ratio, this.size = 124});

  /// spent / limit (may exceed 1).
  final double ratio;
  final double size;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final animate = !MediaQuery.disableAnimationsOf(context);
    final List<Color> colors;
    if (ratio > 1) {
      colors = [AppColors.danger, AppColors.danger];
    } else if (ratio >= 0.8) {
      colors = [AppColors.warning, AppColors.orange];
    } else {
      colors = [AppColors.primary, AppColors.violet];
    }
    final clamped = ratio.clamp(0.0, 1.0);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: animate ? 0 : clamped, end: clamped),
      duration: animate ? const Duration(milliseconds: 350) : Duration.zero,
      curve: Curves.easeOutCubic,
      builder: (context, value, _) => SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _RingPainter(
            progress: value,
            colors: colors,
            track: t.surfaceAlt,
          ),
          child: Center(
            child: Text(
              '${(ratio * 100).round()}%',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.colors,
    required this.track,
  });

  final double progress;
  final List<Color> colors;
  final Color track;

  static const _stroke = 14.0;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final arcRect = rect.deflate(_stroke / 2);
    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _stroke
      ..color = track;
    canvas.drawArc(arcRect, 0, math.pi * 2, false, trackPaint);
    if (progress <= 0) return;
    final sweep = math.pi * 2 * progress;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _stroke
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: 0,
        endAngle: math.pi * 2,
        colors: colors,
        transform: const GradientRotation(-math.pi / 2),
      ).createShader(rect);
    canvas.drawArc(arcRect, -math.pi / 2, sweep, false, paint);
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress ||
      old.track != track ||
      old.colors.first != colors.first ||
      old.colors.last != colors.last;
}
