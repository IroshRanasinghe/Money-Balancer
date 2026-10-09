import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../shared/widgets/ui/app_card.dart';
import '../../../../shared/widgets/ui/icon_badge.dart';
import '../../../../shared/widgets/ui/pressable_scale.dart';
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
    list.sort(
      (a, b) => (b.period == 'yearly' ? 1 : 0) - (a.period == 'yearly' ? 1 : 0),
    );
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
          listener: (context, state) => ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message!))),
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
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: const Text('Premium'),
          foregroundColor: Colors.white,
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
        body: BlocBuilder<PremiumBloc, PremiumState>(
          builder: (context, state) {
            final ordered = _ordered(state.packages);
            final selected = _selected(ordered);
            final busy = state.busy != PremiumBusy.none;
            return ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                _Hero(reason: widget.reason),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.gutter,
                    AppSpacing.xxl,
                    AppSpacing.gutter,
                    0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppCard(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Column(
                          children: [
                            for (final b in _benefits) _Benefit(text: b),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      if (!state.status.storeAvailable)
                        ..._unavailable(context, state)
                      else if (state.status.isPremium)
                        _ActiveCard(expiresAt: state.status.expiresAt)
                      else if (state.loadFailed)
                        ..._loadError(context)
                      else
                        ..._offer(context, state, ordered, selected, busy),
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

  List<Widget> _loadError(BuildContext context) => [
    AppCard(
      child: Column(
        children: [
          IconBadge(
            icon: Icons.cloud_off_rounded,
            color: context.tokens.danger,
            size: 52,
          ),
          const SizedBox(height: 12),
          const Text(
            "Couldn't load Premium options.",
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          FilledButton.tonal(
            onPressed: () =>
                context.read<PremiumBloc>().add(const PremiumStarted()),
            child: const Text('Try again'),
          ),
        ],
      ),
    ),
  ];

  List<Widget> _unavailable(BuildContext context, PremiumState state) => [
    if (state.status.isPremium) _ActiveCard(expiresAt: state.status.expiresAt),
    AppCard(
      child: Column(
        children: [
          IconBadge(
            icon: Icons.storefront_rounded,
            color: context.tokens.textSecondary,
            size: 52,
          ),
          const SizedBox(height: 12),
          const Text(
            "Purchases aren't available on this device.",
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
    if (kDebugMode) ...[
      const SizedBox(height: AppSpacing.md),
      AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: SwitchListTile(
          title: const Text('Debug: premium enabled'),
          value: state.status.isPremium,
          onChanged: (v) =>
              context.read<PremiumBloc>().add(PremiumDebugToggled(v)),
        ),
      ),
    ],
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
      return const [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }
    if (ordered.isEmpty) {
      return [
        AppCard(
          child: Text(
            'No plans available right now. Try again later.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: context.tokens.textSecondary,
            ),
          ),
        ),
      ];
    }
    final hasTrial = selected?.introOffer != null;
    return [
      for (final p in ordered)
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: _PackageCard(
            package: p,
            selected: p.id == selected?.id,
            onTap: busy ? null : () => setState(() => _selectedId = p.id),
          ),
        ),
      const SizedBox(height: 4),
      _GradientButton(
        enabled: !(busy || selected == null),
        onPressed: selected == null
            ? null
            : () => bloc.add(PremiumPurchaseRequested(selected.id)),
        child: state.busy == PremiumBusy.purchasing
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(hasTrial ? 'Start free trial' : 'Continue'),
      ),
      const SizedBox(height: 8),
      TextButton(
        onPressed: busy
            ? null
            : () => bloc.add(const PremiumRestoreRequested()),
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
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: context.tokens.textSecondary),
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
    final top = MediaQuery.paddingOf(context).top + kToolbarHeight;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: context.tokens.brandGradient,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(AppRadius.xl + 4),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(AppRadius.xl + 4),
        ),
        child: Stack(
          children: [
            Positioned(right: -60, top: -40, child: _blob(200, 0.10)),
            Positioned(left: -50, bottom: -60, child: _blob(160, 0.08)),
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.gutter,
                top + AppSpacing.sm,
                AppSpacing.gutter,
                AppSpacing.xxxl,
              ),
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.4),
                        ),
                      ),
                      child: const Icon(
                        Icons.workspace_premium_rounded,
                        size: 46,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Money Balance Premium',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    if (reason != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        reason!.paywallReason,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _blob(double size, double alpha) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white.withValues(alpha: alpha),
    ),
  );
}

class _Benefit extends StatelessWidget {
  const _Benefit({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        const IconBadge(
          icon: Icons.check_rounded,
          color: AppColors.success,
          size: 32,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    ),
  );
}

class _ActiveCard extends StatelessWidget {
  const _ActiveCard({this.expiresAt});

  final DateTime? expiresAt;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      gradient: context.tokens.premiumGradient,
      child: Row(
        children: [
          const Icon(
            Icons.workspace_premium_rounded,
            color: Colors.white,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "You're Premium",
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                  ),
                ),
                if (expiresAt != null)
                  Text(
                    'Active until ${formatDate(expiresAt!)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  const _GradientButton({
    required this.enabled,
    required this.onPressed,
    required this.child,
  });

  final bool enabled;
  final VoidCallback? onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: PressableScale(
        onTap: enabled ? onPressed : null,
        child: Container(
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: context.tokens.brandGradient,
            borderRadius: BorderRadius.circular(18),
            boxShadow: enabled ? context.tokens.heroShadow : null,
          ),
          child: DefaultTextStyle(
            style: theme.textTheme.labelLarge!.copyWith(color: Colors.white),
            child: child,
          ),
        ),
      ),
    );
  }
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
    final t = context.tokens;
    final primary = theme.colorScheme.primary;
    final yearly = package.period == 'yearly';
    final disable = MediaQuery.disableAnimationsOf(context);
    return PressableScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: disable ? Duration.zero : const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: AppRadius.lgAll,
          color: selected
              ? Color.alphaBlend(primary.withValues(alpha: 0.06), t.surface)
              : t.surface,
          boxShadow: t.cardShadow,
          border: Border.all(
            color: selected ? primary : t.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: selected ? primary : t.textSecondary,
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
                      Text(_title(), style: theme.textTheme.titleMedium),
                      if (yearly) const _BestValuePill(),
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(package.priceString, style: theme.textTheme.titleLarge),
                if (_period() != null)
                  Text(
                    _period()!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: t.textSecondary,
                    ),
                  ),
              ],
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

  String? _period() => switch (package.period) {
    'yearly' => 'per year',
    'monthly' => 'per month',
    _ => null,
  };
}

class _BestValuePill extends StatelessWidget {
  const _BestValuePill();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      gradient: context.tokens.premiumGradient,
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(
      'Best value',
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, this.color = AppColors.warning});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(999),
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
