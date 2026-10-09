import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/category_icon.dart';
import '../../../../shared/widgets/empty_state.dart';

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

  void _setTouched(int index) {
    if (index != _touchedIndex) setState(() => _touchedIndex = index);
  }

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
    final theme = Theme.of(context);
    final t = context.tokens;
    final figures = [const FontFeature.tabularFigures()];

    return Column(
      children: [
        SizedBox(
          height: 220,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  centerSpaceRadius: 62,
                  sectionsSpace: 2,
                  sections: [
                    for (var i = 0; i < entries.length; i++)
                      PieChartSectionData(
                        value: entries[i].value,
                        color: categoryColor(entries[i].key),
                        radius: i == _touchedIndex ? 34 : 26,
                        showTitle: false,
                      ),
                  ],
                  pieTouchData: PieTouchData(
                    touchCallback: (event, response) {
                      final index =
                          response?.touchedSection?.touchedSectionIndex ?? -1;
                      if (!event.isInterestedForInteractions) {
                        _setTouched(-1);
                        return;
                      }
                      _setTouched(index);
                    },
                  ),
                ),
              ),
              IgnorePointer(
                child: SizedBox(
                  width: 110,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _touchedIndex >= 0 && _touchedIndex < entries.length
                            ? entries[_touchedIndex].key
                            : 'Total',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: t.textSecondary,
                        ),
                      ),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          formatCurrency(
                            _touchedIndex >= 0 && _touchedIndex < entries.length
                                ? entries[_touchedIndex].value
                                : total,
                            widget.currencyCode,
                          ),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontFeatures: figures,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        for (var i = 0; i < entries.length; i++)
          _LegendRow(
            category: entries[i].key,
            amount: entries[i].value,
            fraction: entries[i].value / total,
            currencyCode: widget.currencyCode,
            highlighted: i == _touchedIndex,
            onTap: () => _setTouched(i == _touchedIndex ? -1 : i),
          ),
      ],
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.category,
    required this.amount,
    required this.fraction,
    required this.currencyCode,
    required this.highlighted,
    required this.onTap,
  });

  final String category;
  final double amount;
  final double fraction;
  final String currencyCode;
  final bool highlighted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.tokens;
    final color = categoryColor(category);
    final figures = [const FontFeature.tabularFigures()];
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: highlighted
              ? color.withValues(alpha: 0.10)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            CategoryIcon(category: category, size: 36),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          category,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        formatCurrency(amount, currencyCode),
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontFeatures: figures,
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 36,
                        child: Text(
                          '${(fraction * 100).round()}%',
                          textAlign: TextAlign.end,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: t.textSecondary,
                            fontFeatures: figures,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: fraction.clamp(0.0, 1.0),
                      minHeight: 4,
                      color: color,
                      backgroundColor: color.withValues(alpha: 0.12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
