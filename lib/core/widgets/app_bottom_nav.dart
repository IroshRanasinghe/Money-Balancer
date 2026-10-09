import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../shared/widgets/ui/glass_surface.dart';
import '../config/constants.dart';
import '../theme/app_tokens.dart';

/// Floating glass navigation bar. The selected destination expands into a
/// tinted pill with its label; the others show an outlined icon.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({super.key, required this.location});

  final String location;

  static const _tabs = [
    (AppRoutes.dashboard, 'Home', Icons.home_outlined, Icons.home_rounded),
    (
      AppRoutes.transactions,
      'Transactions',
      Icons.receipt_long_outlined,
      Icons.receipt_long_rounded,
    ),
    (AppRoutes.budget, 'Budget', Icons.savings_outlined, Icons.savings_rounded),
    (
      AppRoutes.reports,
      'Reports',
      Icons.bar_chart_outlined,
      Icons.bar_chart_rounded,
    ),
    (
      AppRoutes.settings,
      'Settings',
      Icons.settings_outlined,
      Icons.settings_rounded,
    ),
  ];

  int get _selectedIndex {
    final index = _tabs.indexWhere(
      (t) => t.$1 == AppRoutes.dashboard
          ? location == t.$1
          : location.startsWith(t.$1),
    );
    return index < 0 ? 0 : index;
  }

  void _select(BuildContext context, int i) {
    if (i == _selectedIndex) return;
    HapticFeedback.selectionClick();
    context.go(_tabs[i].$1);
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selectedIndex;
    final t = context.tokens;
    final primary = Theme.of(context).colorScheme.primary;
    final animate = !MediaQuery.disableAnimationsOf(context);
    final duration = animate
        ? const Duration(milliseconds: 300)
        : Duration.zero;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: SizedBox(
          height: 68,
          child: GlassSurface(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                for (var i = 0; i < _tabs.length; i++)
                  Expanded(
                    flex: i == selected ? 3 : 1,
                    child: Semantics(
                      button: true,
                      selected: i == selected,
                      label: _tabs[i].$2,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => _select(context, i),
                        child: Center(
                          child: AnimatedContainer(
                            duration: duration,
                            curve: Curves.easeOutCubic,
                            height: 44,
                            padding: EdgeInsets.symmetric(
                              horizontal: i == selected ? 12 : 8,
                            ),
                            decoration: BoxDecoration(
                              color: i == selected
                                  ? primary.withValues(alpha: 0.12)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  i == selected ? _tabs[i].$4 : _tabs[i].$3,
                                  size: 24,
                                  color: i == selected
                                      ? primary
                                      : t.textSecondary,
                                ),
                                if (i == selected) ...[
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      _tabs[i].$2,
                                      maxLines: 1,
                                      overflow: TextOverflow.fade,
                                      softWrap: false,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium
                                          ?.copyWith(color: primary),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
