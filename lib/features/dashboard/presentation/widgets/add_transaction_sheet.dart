import 'package:flutter/material.dart';

import '../../../../core/config/constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/ui/settings_group.dart';
import '../../../../shared/widgets/ui/sheet_scaffold.dart';

class AddTransactionSheet {
  const AddTransactionSheet._();

  /// Resolves to the route to push, or null if dismissed.
  static Future<String?> show(BuildContext context) =>
      showModalBottomSheet<String>(
        context: context,
        isScrollControlled: true,
        builder: (ctx) => SheetScaffold(
          title: 'Add transaction',
          child: SettingsGroup(
            children: [
              SettingsTile(
                icon: Icons.arrow_upward_rounded,
                iconColor: AppColors.danger,
                title: 'Add expense',
                onTap: () => Navigator.pop(ctx, AppRoutes.addExpense),
              ),
              SettingsTile(
                icon: Icons.arrow_downward_rounded,
                iconColor: AppColors.success,
                title: 'Add income',
                onTap: () => Navigator.pop(ctx, AppRoutes.addIncome),
              ),
            ],
          ),
        ),
      );
}
