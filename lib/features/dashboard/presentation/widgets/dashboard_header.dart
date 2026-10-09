import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/ui/pressable_scale.dart';
import '../../../premium/presentation/bloc/premium_bloc.dart';

/// Greeting by time of day, the month below, and a circular avatar button.
class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key, required this.onAvatarTap});

  final VoidCallback onAvatarTap;

  static String greeting(DateTime now) {
    if (now.hour < 12) return 'Good morning';
    if (now.hour < 18) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.tokens;
    final now = DateTime.now();
    final isPremium = context.select(
      (PremiumBloc b) => b.state.status.isPremium,
    );
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting(now),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.headlineSmall,
              ),
              Text(
                formatMonthYear(now.month, now.year),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: t.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        PressableScale(
          onTap: onAvatarTap,
          child: Semantics(
            button: true,
            label: 'Settings',
            child: SizedBox(
              width: 44,
              height: 44,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: t.brandGradient,
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  if (isPremium)
                    Positioned(
                      right: -2,
                      top: -2,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.warning,
                          border: Border.all(color: t.background, width: 2),
                        ),
                        child: const Icon(
                          Icons.workspace_premium_rounded,
                          color: Colors.white,
                          size: 10,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
