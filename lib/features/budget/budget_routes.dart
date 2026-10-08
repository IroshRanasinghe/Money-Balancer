import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/injection_container.dart';
import 'presentation/bloc/budget_bloc.dart';
import 'presentation/pages/budget_page.dart';

Widget budgetRouteBuilder(BuildContext context, GoRouterState state) =>
    BlocProvider(
      create: (_) => sl<BudgetBloc>()..add(const BudgetLoadRequested()),
      child: const BudgetPage(),
    );
