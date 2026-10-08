import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/month_selector.dart';
import '../../../settings/presentation/bloc/settings_bloc.dart';
import '../bloc/reports_bloc.dart';
import '../widgets/category_pie_chart.dart';
import '../widgets/income_expense_bar_chart.dart';
import '../widgets/report_summary_row.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ReportsBloc>();
    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: Column(
        children: [
          BlocBuilder<ReportsBloc, ReportsState>(
            buildWhen: (a, b) => a.month != b.month || a.year != b.year,
            builder: (context, state) => MonthSelector(
              month: state.month,
              year: state.year,
              onShift: (d) => bloc.add(ReportsMonthShifted(d)),
            ),
          ),
          const Expanded(child: _Body()),
        ],
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ReportsBloc>();
    final currency =
        context.select((SettingsBloc b) => b.state.settings.currency);
    return BlocBuilder<ReportsBloc, ReportsState>(
      builder: (context, state) {
        final report = state.report;
        if (state.status == ReportsStatus.failure) {
          return EmptyState(
            icon: Icons.error_outline,
            message: state.errorMessage ?? 'Something went wrong.',
            action: TextButton(
              onPressed: () => bloc.add(const ReportsLoadRequested()),
              child: const Text('Retry'),
            ),
          );
        }
        if (report == null) {
          return const Center(child: CircularProgressIndicator());
        }
        final theme = Theme.of(context);
        return RefreshIndicator(
          onRefresh: () async {
            bloc.add(const ReportsLoadRequested());
            await bloc.stream.firstWhere(
              (s) => s.status != ReportsStatus.loading,
              orElse: () => bloc.state,
            );
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              ReportSummaryRow(report: report, currencyCode: currency),
              const SizedBox(height: 16),
              Text('Spending by category', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: CategoryPieChart(
                    data: report.expenseByCategory,
                    currencyCode: currency,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Income vs expenses', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: IncomeExpenseBarChart(
                    trend: report.trend,
                    currencyCode: currency,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
