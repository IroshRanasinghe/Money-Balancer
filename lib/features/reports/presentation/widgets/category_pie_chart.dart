import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/config/theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/empty_state.dart';

const _palette = [
  AppColors.primary,
  AppColors.success,
  AppColors.warning,
  AppColors.danger,
  Color(0xFF8B5CF6),
  Color(0xFF06B6D4),
  Color(0xFFEC4899),
  Color(0xFF64748B),
];

class CategoryPieChart extends StatefulWidget {
  const CategoryPieChart({
    super.key,
    required this.data,
    required this.currencyCode,
  });

  final Map<String, double> data;
  final String currencyCode;

  @override
  State<CategoryPieChart> createState() => _CategoryPieChartState();
}

class _CategoryPieChartState extends State<CategoryPieChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final entries = widget.data.entries.toList();
    final total = entries.fold<double>(0, (sum, e) => sum + e.value);
    if (entries.isEmpty || total <= 0) {
      return const EmptyState(
        icon: Icons.pie_chart_outline,
        message: 'No expenses this month',
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 220,
          child: PieChart(
            PieChartData(
              centerSpaceRadius: 48,
              sectionsSpace: 2,
              sections: [
                for (var i = 0; i < entries.length; i++)
                  PieChartSectionData(
                    value: entries[i].value,
                    color: _palette[i % _palette.length],
                    radius: i == _touchedIndex ? 64 : 54,
                    title: entries[i].value / total >= 0.05
                        ? '${(entries[i].value / total * 100).round()}%'
                        : '',
                    titleStyle: TextStyle(
                      color: _palette[i % _palette.length].computeLuminance() >
                              0.4
                          ? Colors.black87
                          : Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
              pieTouchData: PieTouchData(
                touchCallback: (event, response) {
                  final index =
                      response?.touchedSection?.touchedSectionIndex ?? -1;
                  if (!event.isInterestedForInteractions) {
                    if (_touchedIndex != -1) setState(() => _touchedIndex = -1);
                    return;
                  }
                  if (index != _touchedIndex) {
                    setState(() => _touchedIndex = index);
                  }
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        for (var i = 0; i < entries.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _palette[i % _palette.length],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(entries[i].key)),
                Text(formatCurrency(entries[i].value, widget.currencyCode)),
                const SizedBox(width: 8),
                SizedBox(
                  width: 44,
                  child: Text(
                    '${(entries[i].value / total * 100).round()}%',
                    textAlign: TextAlign.end,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
