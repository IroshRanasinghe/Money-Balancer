import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/premium/premium_feature.dart';
import '../../domain/entities/premium_package.dart';
import '../bloc/premium_bloc.dart';

const _benefits = [
  'Unlimited accounts, cards, budgets and goals',
  'Unlimited recurring items',
  'Budget alerts',
  'CSV export',
  'Support future features',
];

class PremiumPage extends StatefulWidget {
  const PremiumPage({super.key, this.reason});

  final PremiumFeature? reason;

  @override
  State<PremiumPage> createState() => _PremiumPageState();
}

class _PremiumPageState extends State<PremiumPage> {
  String? _selectedId;

  /// Yearly first.
  List<PremiumPackage> _ordered(List<PremiumPackage> packages) {
    final list = [...packages];
    list.sort((a, b) =>
        (b.period == 'yearly' ? 1 : 0) - (a.period == 'yearly' ? 1 : 0));
    return list;
  }

  PremiumPackage? _selected(List<PremiumPackage> ordered) {
    if (ordered.isEmpty) return null;
    for (final p in ordered) {
      if (p.id == _selectedId) return p;
    }
    return ordered.first;
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<PremiumBloc, PremiumState>(
          listenWhen: (a, b) => a.message != b.message && b.message != null,
          listener: (context, state) => ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.message!))),
        ),
        BlocListener<PremiumBloc, PremiumState>(
          listenWhen: (a, b) =>
              a.busy != PremiumBusy.none &&
              b.busy == PremiumBusy.none &&
              b.status.isPremium,
          listener: (context, state) => Navigator.of(context).maybePop(),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(title: const Text('Premium')),
        body: BlocBuilder<PremiumBloc, PremiumState>(
          builder: (context, state) {
            final ordered = _ordered(state.packages);
            final selected = _selected(ordered);
            final busy = state.busy != PremiumBusy.none;
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              children: [
                _Hero(reason: widget.reason),
                const SizedBox(height: 20),
                for (final b in _benefits) _Benefit(text: b),
                const SizedBox(height: 20),
                if (!state.status.storeAvailable)
                  ..._unavailable(context, state)
                else if (state.status.isPremium)
                  _ActiveCard(expiresAt: state.status.expiresAt)
                else if (state.loadFailed)
                  ..._loadError(context)
                else
                  ..._offer(context, state, ordered, selected, busy),
              ],
            );
          },
        ),
      ),
    );
  }

  List<Widget> _loadError(BuildContext context) => [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text(
            "Couldn't load Premium options.",
            textAlign: TextAlign.center,
          ),
        ),
        TextButton(
          onPressed: () =>
              context.read<PremiumBloc>().add(const PremiumStarted()),
          child: const Text('Try again'),
        ),
      ];

  List<Widget> _unavailable(BuildContext context, PremiumState state) => [
        if (state.status.isPremium)
          _ActiveCard(expiresAt: state.status.expiresAt),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text(
            "Purchases aren't available on this device.",
            textAlign: TextAlign.center,
          ),
        ),
        if (kDebugMode)
          SwitchListTile(
            title: const Text('Debug: premium enabled'),
            value: state.status.isPremium,
            onChanged: (v) =>
                context.read<PremiumBloc>().add(PremiumDebugToggled(v)),
          ),
      ];

  List<Widget> _offer(
    BuildContext context,
    PremiumState state,
    List<PremiumPackage> ordered,
    PremiumPackage? selected,
    bool busy,
  ) {
    final bloc = context.read<PremiumBloc>();
    if (state.packagesLoading && ordered.isEmpty) {
      return const [Center(child: CircularProgressIndicator())];
    }
    if (ordered.isEmpty) {
      return const [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'No plans available right now. Try again later.',
            textAlign: TextAlign.center,
          ),
        ),
      ];
    }
    final hasTrial = selected?.introOffer != null;
    return [
      for (final p in ordered)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _PackageCard(
            package: p,
            selected: p.id == selected?.id,
            onTap: busy ? null : () => setState(() => _selectedId = p.id),
          ),
        ),
      const SizedBox(height: 4),
      FilledButton(
        onPressed: busy || selected == null
            ? null
            : () => bloc.add(PremiumPurchaseRequested(selected.id)),
        child: state.busy == PremiumBusy.purchasing
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(hasTrial ? 'Start free trial' : 'Continue'),
      ),
      const SizedBox(height: 8),
      TextButton(
        onPressed: busy ? null : () => bloc.add(const PremiumRestoreRequested()),
        child: state.busy == PremiumBusy.restoring
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text('Restore purchases'),
      ),
      const SizedBox(height: 8),
      Text(
        'Subscriptions renew automatically until cancelled in your store '
        'account settings.',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
    ];
  }
}

class _Hero extends StatelessWidget {
  const _Hero({this.reason});

  final PremiumFeature? reason;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, Color(0xFF1E3A8A)],
        ),
      ),
      child: Column(
        children: [
          const Icon(Icons.workspace_premium, size: 56, color: Colors.white),
          const SizedBox(height: 12),
          Text(
            'Money Balance Premium',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (reason != null) ...[
            const SizedBox(height: 8),
            Text(
              reason!.paywallReason,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: Colors.white.withValues(alpha: 0.9)),
            ),
          ],
        ],
      ),
    );
  }
}

class _Benefit extends StatelessWidget {
  const _Benefit({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.success, size: 22),
            const SizedBox(width: 12),
            Expanded(child: Text(text)),
          ],
        ),
      );
}

class _ActiveCard extends StatelessWidget {
  const _ActiveCard({this.expiresAt});

  final DateTime? expiresAt;

  @override
  Widget build(BuildContext context) => Card(
        child: ListTile(
          leading: const Icon(Icons.workspace_premium, color: AppColors.warning),
          title: const Text("You're Premium"),
          subtitle: expiresAt == null
              ? null
              : Text('Active until ${formatDate(expiresAt!)}'),
        ),
      );
}

class _PackageCard extends StatelessWidget {
  const _PackageCard({
    required this.package,
    required this.selected,
    required this.onTap,
  });

  final PremiumPackage package;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final yearly = package.period == 'yearly';
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: selected ? scheme.primary.withValues(alpha: 0.08) : null,
          border: Border.all(
            color: selected ? scheme.primary : scheme.outlineVariant,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? scheme.primary : scheme.outline,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        _title(),
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      if (yearly) const _Chip(label: 'Best value'),
                    ],
                  ),
                  if (package.introOffer != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: _Chip(
                        label: package.introOffer!,
                        color: AppColors.success,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              package.priceString,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  String _title() => switch (package.period) {
        'yearly' => 'Yearly',
        'monthly' => 'Monthly',
        _ => package.title,
      };
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, this.color = AppColors.warning});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
        ),
      );
}
