import 'package:flutter/material.dart';

import 'app.dart';
import 'core/di/injection_container.dart';
import 'features/settings/domain/entities/app_settings.dart';
import 'features/settings/domain/usecases/get_settings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  final initial =
      (await sl<GetSettings>()()).getOrElse(() => const AppSettings());
  runApp(MoneyBalanceApp(initialSettings: initial));
}
