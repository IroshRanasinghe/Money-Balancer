import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/injection_container.dart';
import 'presentation/bloc/account_detail_bloc.dart';
import 'presentation/bloc/accounts_bloc.dart';
import 'presentation/pages/account_detail_page.dart';
import 'presentation/pages/accounts_page.dart';

Widget accountsRouteBuilder(BuildContext context, GoRouterState state) =>
    BlocProvider(
      create: (_) => sl<AccountsBloc>()..add(const AccountsLoadRequested()),
      child: const AccountsPage(),
    );

Widget accountDetailRouteBuilder(BuildContext context, GoRouterState state) {
  final accountId = state.extra is String ? state.extra as String : '';
  return MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (_) => sl<AccountsBloc>()..add(const AccountsLoadRequested()),
      ),
      BlocProvider(
        create: (_) =>
            sl<AccountDetailBloc>()..add(AccountDetailLoadRequested(accountId)),
      ),
    ],
    child: AccountDetailPage(accountId: accountId),
  );
}
