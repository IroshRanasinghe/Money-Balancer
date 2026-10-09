import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app_bottom_nav.dart';

/// Bottom space (nav bar height + margins) that tab pages should add as list
/// padding so content can scroll behind the floating nav bar.
const double kNavBarClearance = 96.0;

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final animate = !MediaQuery.disableAnimationsOf(context);
    return Scaffold(
      extendBody: true,
      body: AnimatedSwitcher(
        duration: animate ? const Duration(milliseconds: 250) : Duration.zero,
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeOutCubic,
        child: KeyedSubtree(key: ValueKey(location), child: child),
      ),
      bottomNavigationBar: AppBottomNav(location: location),
    );
  }
}
