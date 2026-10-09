import 'package:flutter/material.dart';

import '../../../core/theme/app_tokens.dart';
import 'app_card.dart';
import 'icon_badge.dart';
import 'pressable_scale.dart';

/// iOS-style grouped list: optional small caps [title] above an [AppCard]
/// holding [children] (normally [SettingsTile]s) with dividers inset to the
/// text column.
class SettingsGroup extends StatelessWidget {
  const SettingsGroup({super.key, this.title, required this.children});

  final String? title;
  final List<Widget> children;

  /// Left inset of dividers: 16 padding + 36 badge + 12 gap.
  static const dividerInset = 64.0;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 8),
            child: Text(
              title!.toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: t.textSecondary,
                letterSpacing: 0.8,
              ),
            ),
          ),
        AppCard(
          padding: EdgeInsets.zero,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Column(
              children: [
                for (var i = 0; i < children.length; i++) ...[
                  if (i > 0)
                    Divider(height: 1, indent: dividerInset, color: t.border),
                  children[i],
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// A row in a [SettingsGroup]: coloured [IconBadge] (36), title, optional
/// subtitle, trailing widget (defaults to a chevron when [onTap] is set).
class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.iconColor,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final Color? iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final theme = Theme.of(context);
    final row = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconBadge(
            icon: icon,
            color: iconColor ?? theme.colorScheme.primary,
            size: 36,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleSmall),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: t.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            trailing!,
          ] else if (onTap != null)
            Icon(Icons.chevron_right_rounded, color: t.textSecondary),
        ],
      ),
    );
    if (onTap == null) return row;
    return PressableScale(scale: 0.99, onTap: onTap, child: row);
  }
}
