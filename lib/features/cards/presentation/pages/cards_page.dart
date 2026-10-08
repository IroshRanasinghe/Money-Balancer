import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/widgets/empty_state.dart';
import '../../../settings/presentation/bloc/settings_bloc.dart';
import '../bloc/cards_bloc.dart';
import '../widgets/bank_card_tile.dart';
import '../widgets/card_form_sheet.dart';

class CardsPage extends StatelessWidget {
  const CardsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currency =
        context.select((SettingsBloc b) => b.state.settings.currency);
    final bloc = context.read<CardsBloc>();

    return BlocListener<CardsBloc, CardsState>(
      listenWhen: (a, b) =>
          a.errorMessage != b.errorMessage &&
          b.errorMessage != null &&
          b.status != CardsStatus.failure,
      listener: (context, state) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(state.errorMessage!)));
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('My cards')),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => CardFormSheet.show(context),
          icon: const Icon(Icons.add),
          label: const Text('Add card'),
        ),
        body: BlocBuilder<CardsBloc, CardsState>(
          builder: (context, state) {
            if (state.status == CardsStatus.loading && state.items.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.status == CardsStatus.failure) {
              return EmptyState(
                icon: Icons.error_outline,
                message: state.errorMessage ?? 'Something went wrong.',
                action: TextButton(
                  onPressed: () => bloc.add(const CardsLoadRequested()),
                  child: const Text('Retry'),
                ),
              );
            }
            if (state.items.isEmpty) {
              return const EmptyState(
                icon: Icons.credit_card_off,
                message: 'No cards saved yet.\nTap Add card to save one.',
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
              itemCount: state.items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final item = state.items[i];
                return BankCardTile(
                  key: ValueKey(item.card.id),
                  item: item,
                  currencyCode: currency,
                  onTap: () =>
                      CardFormSheet.show(context, existing: item.card),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
