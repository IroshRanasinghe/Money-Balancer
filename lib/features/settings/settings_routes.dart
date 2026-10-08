import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'presentation/pages/settings_page.dart';

/// SettingsBloc is app-wide (provided in app.dart), so no BlocProvider here.
Widget settingsRouteBuilder(BuildContext context, GoRouterState state) =>
    const SettingsPage();
