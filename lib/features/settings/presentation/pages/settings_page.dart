import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/constants.dart';
import '../bloc/settings_bloc.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) => BlocListener<SettingsBloc, SettingsState>(
        listenWhen: (a, b) =>
            a.errorMessage != b.errorMessage && b.errorMessage != null,
        listener: (context, state) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        },
        child: Scaffold(
          appBar: AppBar(title: const Text('Settings')),
          body: BlocBuilder<SettingsBloc, SettingsState>(
            builder: (context, state) {
              final bloc = context.read<SettingsBloc>();
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          title: const Text('Currency'),
                          trailing: DropdownButton<String>(
                            value: state.settings.currency,
                            items: [
                              for (final code in SupportedCurrencies.codes)
                                DropdownMenuItem(value: code, child: Text(code)),
                            ],
                            onChanged: (value) {
                              if (value != null) bloc.add(CurrencyChanged(value));
                            },
                          ),
                        ),
                        SwitchListTile(
                          title: const Text('Dark mode'),
                          value: state.settings.darkMode,
                          onChanged: (value) => bloc.add(DarkModeToggled(value)),
                        ),
                        ListTile(
                          title: const Text('Language'),
                          trailing: DropdownButton<String>(
                            value: state.settings.language,
                            items: const [
                              DropdownMenuItem(value: 'en', child: Text('English')),
                            ],
                            onChanged: (value) {
                              if (value != null) bloc.add(LanguageChanged(value));
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.account_balance_wallet),
                          title: const Text('Accounts'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.push(AppRoutes.accounts),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.credit_card),
                          title: const Text('My cards'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.push(AppRoutes.cards),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.event_repeat),
                          title: const Text('Recurring'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.push(AppRoutes.recurring),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      );
}
