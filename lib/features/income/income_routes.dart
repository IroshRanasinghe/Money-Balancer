import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/injection_container.dart';
import '../transactions/domain/entities/transaction.dart';
import 'presentation/bloc/income_bloc.dart';
import 'presentation/pages/income_form_page.dart';

Widget addIncomeRouteBuilder(BuildContext context, GoRouterState state) =>
    BlocProvider(
      create: (_) => sl<IncomeBloc>(param1: null),
      child: const IncomeFormPage(),
    );

Widget editIncomeRouteBuilder(BuildContext context, GoRouterState state) {
  final initial = state.extra is Transaction
      ? state.extra as Transaction
      : null;
  return BlocProvider(
    create: (_) => sl<IncomeBloc>(param1: initial),
    child: IncomeFormPage(initial: initial),
  );
}
