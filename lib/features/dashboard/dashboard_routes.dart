import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/injection_container.dart';
import '../goals/presentation/bloc/goals_bloc.dart';
import 'presentation/bloc/dashboard_bloc.dart';
import 'presentation/bloc/dashboard_event.dart';
import 'presentation/pages/dashboard_page.dart';

Widget dashboardRouteBuilder(BuildContext context, GoRouterState state) =>
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              sl<DashboardBloc>()..add(const DashboardLoadRequested()),
        ),
        BlocProvider(
          create: (_) => sl<GoalsBloc>()..add(const GoalsLoadRequested()),
        ),
      ],
      child: const DashboardPage(),
    );
