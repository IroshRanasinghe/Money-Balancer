import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/placeholder_page.dart';

Widget addIncomeRouteBuilder(BuildContext context, GoRouterState state) =>
    const PlaceholderPage(title: 'Add Income');

Widget editIncomeRouteBuilder(BuildContext context, GoRouterState state) =>
    const PlaceholderPage(title: 'Edit Income');
