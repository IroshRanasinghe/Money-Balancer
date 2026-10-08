import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/injection_container.dart';
import '../transactions/domain/entities/transaction.dart';
import 'presentation/bloc/expense_bloc.dart';
import 'presentation/pages/expense_form_page.dart';

Widget addExpenseRouteBuilder(BuildContext context, GoRouterState state) =>
    BlocProvider(
      create: (_) => sl<ExpenseBloc>(param1: null),
      child: const ExpenseFormPage(),
    );

Widget editExpenseRouteBuilder(BuildContext context, GoRouterState state) {
  final initial = state.extra is Transaction
      ? state.extra as Transaction
      : null;
  return BlocProvider(
    create: (_) => sl<ExpenseBloc>(param1: initial),
    child: ExpenseFormPage(initial: initial),
  );
}
