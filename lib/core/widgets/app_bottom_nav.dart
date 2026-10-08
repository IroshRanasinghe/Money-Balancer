import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../config/constants.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({super.key, required this.location});

  final String location;

  static const _tabs = [
    (AppRoutes.dashboard, 'Home', Icons.home_outlined, Icons.home),
    (
      AppRoutes.transactions,
      'Transactions',
      Icons.receipt_long_outlined,
      Icons.receipt_long
    ),
    (AppRoutes.budget, 'Budget', Icons.savings_outlined, Icons.savings),
    (AppRoutes.reports, 'Reports', Icons.bar_chart_outlined, Icons.bar_chart),
    (AppRoutes.settings, 'Settings', Icons.settings_outlined, Icons.settings),
  ];

  int get _selectedIndex {
    final index = _tabs.indexWhere((t) => t.$1 == AppRoutes.dashboard
        ? location == t.$1
        : location.startsWith(t.$1));
    return index < 0 ? 0 : index;
  }

  @override
  Widget build(BuildContext context) => NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => context.go(_tabs[i].$1),
        destinations: [
          for (final t in _tabs)
            NavigationDestination(
              icon: Icon(t.$3),
              selectedIcon: Icon(t.$4),
              label: t.$2,
            ),
        ],
      );
}
