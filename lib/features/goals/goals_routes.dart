import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/injection_container.dart';
import 'presentation/bloc/goals_bloc.dart';
import 'presentation/pages/goals_page.dart';

Widget goalsRouteBuilder(BuildContext context, GoRouterState state) =>
    BlocProvider(
      create: (_) => sl<GoalsBloc>()..add(const GoalsLoadRequested()),
      child: const GoalsPage(),
    );
