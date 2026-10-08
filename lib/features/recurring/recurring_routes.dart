import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/injection_container.dart';
import '../accounts/presentation/bloc/accounts_bloc.dart';
import 'presentation/bloc/recurring_bloc.dart';
import 'presentation/pages/recurring_page.dart';

Widget recurringRouteBuilder(BuildContext context, GoRouterState state) =>
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              sl<RecurringBloc>()..add(const RecurringLoadRequested()),
        ),
        BlocProvider(
          create: (_) => sl<AccountsBloc>()..add(const AccountsLoadRequested()),
        ),
      ],
      child: const RecurringPage(),
    );
