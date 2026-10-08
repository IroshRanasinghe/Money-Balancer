import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/injection_container.dart';
import 'presentation/bloc/reports_bloc.dart';
import 'presentation/pages/reports_page.dart';

Widget reportsRouteBuilder(BuildContext context, GoRouterState state) =>
    BlocProvider(
      create: (_) => sl<ReportsBloc>()..add(const ReportsLoadRequested()),
      child: const ReportsPage(),
    );
