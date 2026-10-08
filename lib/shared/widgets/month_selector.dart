import 'package:flutter/material.dart';

import '../../core/utils/formatters.dart';

class MonthSelector extends StatelessWidget {
  const MonthSelector({
    super.key,
    required this.month,
    required this.year,
    required this.onShift,
  });

  final int month;
  final int year;
  final ValueChanged<int> onShift;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => onShift(-1),
          ),
          Text(
            formatMonthYear(month, year),
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => onShift(1),
          ),
        ],
      );
}
