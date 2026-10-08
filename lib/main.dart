import 'package:flutter/material.dart';

import 'app.dart';
import 'core/di/injection_container.dart';
import 'features/recurring/domain/usecases/process_due_recurring.dart';
import 'features/settings/domain/entities/app_settings.dart';
import 'features/settings/domain/usecases/get_settings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  // Catch up on recurring items; a failure must not block startup.
  await sl<ProcessDueRecurring>()(DateTime.now());
  final initial =
      (await sl<GetSettings>()()).getOrElse(() => const AppSettings());
  runApp(MoneyBalanceApp(initialSettings: initial));
}
