import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/injection_container.dart';
import '../backup/presentation/bloc/backup_bloc.dart';
import 'presentation/pages/settings_page.dart';

/// SettingsBloc is app-wide (provided in app.dart); BackupBloc is scoped to
/// this route.
Widget settingsRouteBuilder(BuildContext context, GoRouterState state) =>
    BlocProvider(
      create: (_) => sl<BackupBloc>(),
      child: const SettingsPage(),
    );
