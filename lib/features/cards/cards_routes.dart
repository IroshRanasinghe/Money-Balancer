import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/injection_container.dart';
import 'presentation/bloc/cards_bloc.dart';
import 'presentation/pages/cards_page.dart';

Widget cardsRouteBuilder(BuildContext context, GoRouterState state) =>
    BlocProvider(
      create: (_) => sl<CardsBloc>()..add(const CardsLoadRequested()),
      child: const CardsPage(),
    );
