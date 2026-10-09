import 'package:flutter/material.dart';

import '../../core/theme/app_tokens.dart';
import '../../core/utils/formatters.dart';

/// Pill with previous/next chevrons and an animated month label.
/// [onShift] is called with -1 / +1.
class MonthSelector extends StatefulWidget {
  const MonthSelector({
    super.key,
    required this.month,
    required this.year,
    required this.onShift,
  });

  final int month;
  final int year;
  final ValueChanged<int> onShift;

  @override
  State<MonthSelector> createState() => _MonthSelectorState();
}

class _MonthSelectorState extends State<MonthSelector> {
  int _direction = 1;

  void _shift(int delta) {
    setState(() => _direction = delta);
    widget.onShift(delta);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final label = formatMonthYear(widget.month, widget.year);
    final animate = !MediaQuery.disableAnimationsOf(context);
    return Center(
      child: Container(
        decoration: BoxDecoration(
          color: t.surfaceAlt,
          borderRadius: BorderRadius.circular(999),
        ),
        padding: const EdgeInsets.all(4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              visualDensity: VisualDensity.compact,
              tooltip: 'Previous month',
              icon: const Icon(Icons.chevron_left_rounded),
              onPressed: () => _shift(-1),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 148),
              child: AnimatedSwitcher(
                duration: animate
                    ? const Duration(milliseconds: 250)
                    : Duration.zero,
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeOutCubic,
                transitionBuilder: (child, animation) {
                  final incoming = child.key == ValueKey(label);
                  final begin = Offset((incoming ? 0.4 : -0.4) * _direction, 0);
                  return ClipRect(
                    child: FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: begin,
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    ),
                  );
                },
                child: Text(
                  label,
                  key: ValueKey(label),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              tooltip: 'Next month',
              icon: const Icon(Icons.chevron_right_rounded),
              onPressed: () => _shift(1),
            ),
          ],
        ),
      ),
    );
  }
}
