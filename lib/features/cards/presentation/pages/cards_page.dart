import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/widgets/empty_state.dart';
import '../../../settings/presentation/bloc/settings_bloc.dart';
import '../../domain/card_number.dart';
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

    return MultiBlocListener(
      listeners: [
        BlocListener<CardsBloc, CardsState>(
          listenWhen: (a, b) =>
              a.revealedNumber == null && b.revealedNumber != null,
          listener: (context, state) => _showReveal(context, state),
        ),
        BlocListener<CardsBloc, CardsState>(
      listenWhen: (a, b) =>
          a.errorMessage != b.errorMessage &&
          b.errorMessage != null &&
          b.status != CardsStatus.failure,
      listener: (context, state) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(state.errorMessage!)));
      },
        ),
      ],
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
                  onReveal: () =>
                      bloc.add(CardNumberRevealRequested(item.card.id)),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _showReveal(BuildContext context, CardsState state) async {
    final bloc = context.read<CardsBloc>();
    final messenger = ScaffoldMessenger.of(context);
    final number = state.revealedNumber!;
    final nickname = state.items
            .where((i) => i.card.id == state.revealedCardId)
            .map((i) => i.card.nickname)
            .firstOrNull ??
        'Card number';
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(nickname),
        content: SelectableText(
          formatCardNumber(number),
          style: const TextStyle(
              fontFamily: 'monospace', fontSize: 18, letterSpacing: 1),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: number));
              messenger.showSnackBar(
                  const SnackBar(content: Text('Card number copied')));
            },
            child: const Text('Copy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
    bloc.add(const CardNumberRevealDismissed());
  }
}
