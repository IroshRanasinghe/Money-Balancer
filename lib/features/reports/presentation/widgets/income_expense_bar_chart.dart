import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../domain/entities/report_data.dart';

class IncomeExpenseBarChart extends StatelessWidget {
  const IncomeExpenseBarChart({
    super.key,
    required this.trend,
    required this.currencyCode,
  });

  final List<MonthlyTotal> trend;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    final maxValue = trend.fold<double>(
        0, (m, t) => math.max(m, math.max(t.income, t.expense)));
    if (maxValue <= 0) {
      return const EmptyState(
        icon: Icons.bar_chart,
        message: 'No data for the last 6 months',
      );
    }
    final maxY = maxValue * 1.2;
    final theme = Theme.of(context);
    final labelStyle = theme.textTheme.labelSmall;

    return Column(
      children: [
        SizedBox(
          height: 240,
          child: BarChart(
            BarChartData(
              maxY: maxY,
              alignment: BarChartAlignment.spaceAround,
              borderData: FlBorderData(show: false),
              gridData: const FlGridData(
                show: true,
                drawVerticalLine: false,
              ),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(),
                rightTitles: const AxisTitles(),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final i = value.toInt();
                      if (i < 0 || i >= trend.length) {
                        return const SizedBox.shrink();
                      }
                      return SideTitleWidget(
                        meta: meta,
                        child: Text(
                          formatShortMonth(trend[i].month, trend[i].year),
                          style: labelStyle,
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 44,
                    getTitlesWidget: (value, meta) {
                      if (value == meta.max) return const SizedBox.shrink();
                      return SideTitleWidget(
                        meta: meta,
                        child: Text(
                          NumberFormat.compact().format(value),
                          style: labelStyle,
                        ),
                      );
                    },
                  ),
                ),
              ),
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                      BarTooltipItem(
                    formatCurrency(rod.toY, currencyCode),
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              barGroups: [
                for (var i = 0; i < trend.length; i++)
                  BarChartGroupData(
                    x: i,
                    barRods: [
                      _rod(trend[i].income, AppColors.success),
                      _rod(trend[i].expense, AppColors.danger),
                    ],
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _LegendItem(color: AppColors.success, label: 'Income'),
            SizedBox(width: 16),
            _LegendItem(color: AppColors.danger, label: 'Expenses'),
          ],
        ),
      ],
    );
  }

  BarChartRodData _rod(double value, Color color) => BarChartRodData(
        toY: value,
        color: color,
        width: 10,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
      );
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(label),
        ],
      );
}
