import 'package:flutter/material.dart';

import '../../../../core/config/constants.dart';
import '../../../../core/config/theme.dart';

class AddTransactionSheet {
  const AddTransactionSheet._();

  /// Resolves to the route to push, or null if dismissed.
  static Future<String?> show(BuildContext context) =>
      showModalBottomSheet<String>(
        context: context,
        builder: (ctx) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.remove_circle_outline,
                    color: AppColors.danger),
                title: const Text('Add expense'),
                onTap: () => Navigator.pop(ctx, AppRoutes.addExpense),
              ),
              ListTile(
                leading: const Icon(Icons.add_circle_outline,
                    color: AppColors.success),
                title: const Text('Add income'),
                onTap: () => Navigator.pop(ctx, AppRoutes.addIncome),
              ),
            ],
          ),
        ),
      );
}
