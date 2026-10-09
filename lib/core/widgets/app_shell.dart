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
    // [child] is go_router's nested Navigator, which owns a GlobalKey: never
    // wrap it in an AnimatedSwitcher (two copies during the cross-fade cause a
    // "Duplicate GlobalKey" crash). Tab fades live in the route pages instead.
    return Scaffold(
      extendBody: true,
      body: child,
      bottomNavigationBar: AppBottomNav(
        location: GoRouterState.of(context).uri.path,
      ),
    );
  }
}
