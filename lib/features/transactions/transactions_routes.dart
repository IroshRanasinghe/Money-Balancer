import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/injection_container.dart';
import 'presentation/bloc/transaction_bloc.dart';
import 'presentation/pages/transaction_list_page.dart';

Widget transactionsRouteBuilder(BuildContext context, GoRouterState state) =>
    BlocProvider(
      create: (_) => sl<TransactionBloc>()..add(const TransactionsLoadRequested()),
      child: const TransactionListPage(),
    );
