import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/injection_container.dart';
import '../cards/presentation/bloc/cards_bloc.dart';
import '../transactions/domain/entities/transaction.dart';
import 'presentation/bloc/expense_bloc.dart';
import 'presentation/pages/expense_form_page.dart';

Widget addExpenseRouteBuilder(BuildContext context, GoRouterState state) =>
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<ExpenseBloc>(param1: null)),
        BlocProvider(
          create: (_) => sl<CardsBloc>()..add(const CardsLoadRequested()),
        ),
      ],
      child: const ExpenseFormPage(),
    );

Widget editExpenseRouteBuilder(BuildContext context, GoRouterState state) {
  final initial = state.extra is Transaction
      ? state.extra as Transaction
      : null;
  return MultiBlocProvider(
    providers: [
      BlocProvider(create: (_) => sl<ExpenseBloc>(param1: initial)),
      BlocProvider(
        create: (_) => sl<CardsBloc>()..add(const CardsLoadRequested()),
      ),
    ],
    child: ExpenseFormPage(initial: initial),
  );
}
