import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/placeholder_page.dart';

Widget addExpenseRouteBuilder(BuildContext context, GoRouterState state) =>
    const PlaceholderPage(title: 'Add Expense');

Widget editExpenseRouteBuilder(BuildContext context, GoRouterState state) =>
    const PlaceholderPage(title: 'Edit Expense');
