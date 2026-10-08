import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/config/router.dart';
import 'core/config/theme.dart';
import 'core/di/injection_container.dart';
import 'features/premium/presentation/bloc/premium_bloc.dart';
import 'features/settings/domain/entities/app_settings.dart';
import 'features/settings/presentation/bloc/settings_bloc.dart';

class MoneyBalanceApp extends StatelessWidget {
  const MoneyBalanceApp({super.key, required this.initialSettings});

  final AppSettings initialSettings;

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
        providers: [
          BlocProvider<SettingsBloc>(
            create: (_) => sl<SettingsBloc>(param1: initialSettings),
          ),
          BlocProvider<PremiumBloc>(
            create: (_) => sl<PremiumBloc>()..add(const PremiumStarted()),
          ),
        ],
        child: BlocBuilder<SettingsBloc, SettingsState>(
          buildWhen: (a, b) => a.settings.darkMode != b.settings.darkMode,
          builder: (context, state) => MaterialApp.router(
            title: 'Money Balance',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: state.settings.darkMode ? ThemeMode.dark : ThemeMode.light,
            routerConfig: appRouter,
          ),
        ),
      );
}
