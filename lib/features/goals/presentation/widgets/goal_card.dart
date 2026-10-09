import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/ui/app_card.dart';
import '../../../../shared/widgets/ui/icon_badge.dart';
import '../../../../shared/widgets/ui/status_pill.dart';
import '../../domain/entities/savings_goal.dart';

const goalSwatches = <int>[
  0xFF2563EB,
  0xFF0F172A,
  0xFF7C3AED,
  0xFF059669,
  0xFFDC2626,
  0xFFD97706,
];

class GoalCard extends StatelessWidget {
  const GoalCard({
    super.key,
    required this.goal,
    required this.currencyCode,
    this.onTap,
  });

  final SavingsGoal goal;
  final String currencyCode;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.tokens;
    final color = Color(goal.colorValue);
    // A near-black swatch would vanish on the dark surface.
    final accent = t.isDark && color.computeLuminance() < 0.08
        ? t.textPrimary
        : color;
    final date = goal.targetDate;
    final monthly = goal.monthlyNeeded(DateTime.now());
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: t.textSecondary,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconBadge(icon: Icons.flag_rounded, color: accent),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${formatCurrency(goal.savedAmount, currencyCode)} of '
                      '${formatCurrency(goal.targetAmount, currencyCode)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: muted,
                    ),
                    if (goal.isCompleted) ...[
                      const SizedBox(height: 6),
                      const StatusPill(
                        label: 'Completed',
                        color: AppColors.success,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _ProgressRing(progress: goal.progress, color: accent),
            ],
          ),
          if (date != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'By ${formatDate(date)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: muted,
                  ),
                ),
                if (monthly != null) ...[
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Save ${formatCurrency(monthly, currencyCode)}/month',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: muted,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ProgressRing extends StatelessWidget {
  const _ProgressRing({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final animate = !MediaQuery.disableAnimationsOf(context);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: animate ? 0 : progress, end: progress),
      duration: animate ? const Duration(milliseconds: 350) : Duration.zero,
      curve: Curves.easeOutCubic,
      builder: (context, value, _) => SizedBox(
        width: 56,
        height: 56,
        child: CustomPaint(
          painter: _RingPainter(
            progress: value,
            color: color,
            track: color.withValues(alpha: 0.15),
          ),
          child: Center(
            child: Text(
              '${(progress * 100).round()}%',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
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
    required this.color,
    required this.track,
  });

  final double progress;
  final Color color;
  final Color track;

  static const _stroke = 6.0;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(_stroke / 2);
    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _stroke
      ..color = track;
    canvas.drawArc(rect, 0, math.pi * 2, false, base);
    if (progress <= 0) return;
    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _stroke
      ..strokeCap = StrokeCap.round
      ..color = color;
    canvas.drawArc(rect, -math.pi / 2, math.pi * 2 * progress, false, arc);
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.color != color || old.track != track;
}
