import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/transaction.dart';
import '../../theme/app_theme.dart';

class ChartWidgets {
  // Pie Chart for expense/income by category using fl_chart
  static Widget categoryDistributionChart(List<Transaction> transactions, String type) {
    // Filter transactions by type (income/expense)
    final filteredTransactions = transactions.where((t) => t.type == type).toList();

    // Group by category and sum amounts
    Map<String, double> categoryAmounts = {};
    for (var transaction in filteredTransactions) {
      final category = transaction.category?.name ?? 'Uncategorized';
      final amount = double.tryParse(transaction.amount) ?? 0;
      categoryAmounts[category] = (categoryAmounts[category] ?? 0) + amount;
    }

    // Prepare pie chart data
    List<PieChartSectionData> sections = [];
    List<Color> colors = [
      AppTheme.primaryColor,
      AppTheme.incomeColor,
      AppTheme.expenseColor,
      Colors.orange,
      Colors.purple,
      Colors.green,
      Colors.brown,
      Colors.pink,
    ];

    double total = categoryAmounts.values.fold(0, (a, b) => a + b);
    int colorIndex = 0;

    categoryAmounts.forEach((category, amount) {
      final percentage = total > 0 ? (amount / total * 100) : 0;

      sections.add(
        PieChartSectionData(
          color: colors[colorIndex % colors.length],
          value: amount,
          title: '${percentage.toStringAsFixed(1)}%',
          radius: 50,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
      colorIndex++;
    });

    return Container(
      height: 300,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                type == 'income' ? 'Income by Category' : 'Expense by Category',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: PieChart(
                  PieChartData(
                    sections: sections,
                    centerSpaceRadius: 40,
                    sectionsSpace: 2,
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        // Handle touch events if needed
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Bar Chart for monthly income/expense using fl_chart
  static Widget monthlyBarChart(List<Transaction> transactions) {
    // Group transactions by month and calculate totals
    Map<String, Map<String, double>> monthlyTotals = {};

    for (var transaction in transactions) {
      if (transaction.date == null) continue;

      // Extract year-month from date (e.g., "2023-05")
      final yearMonth = transaction.date!.split('-').take(2).join('-');

      if (!monthlyTotals.containsKey(yearMonth)) {
        monthlyTotals[yearMonth] = {'income': 0, 'expense': 0};
      }

      final amount = double.tryParse(transaction.amount) ?? 0;
      if (transaction.type == 'income') {
        monthlyTotals[yearMonth]!['income'] = monthlyTotals[yearMonth]!['income']! + amount;
      } else {
        monthlyTotals[yearMonth]!['expense'] = monthlyTotals[yearMonth]!['expense']! + amount;
      }
    }

    // Prepare bar chart data
    List<BarChartGroupData> barGroups = [];
    List<String> monthLabels = monthlyTotals.keys.toList()..sort();

    for (int i = 0; i < monthLabels.length; i++) {
      final monthData = monthlyTotals[monthLabels[i]]!;

      barGroups.add(
        BarChartGroupData(
          x: i,
          barsSpace: 4,
          barRods: [
            BarChartRodData(
              toY: monthData['income']!,
              color: AppTheme.incomeColor,
              width: 14,
              borderRadius: BorderRadius.zero,
            ),
            BarChartRodData(
              toY: monthData['expense']!,
              color: AppTheme.expenseColor,
              width: 14,
              borderRadius: BorderRadius.zero,
            ),
          ],
        ),
      );
    }

    // Generate month labels
    List<String> monthShortNames = monthLabels.map((label) {
      final parts = label.split('-');
      return '${parts[1]}/${parts[0].substring(2)}';
    }).toList();

    return Container(
      height: 300,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text(
                'Monthly Overview (Income vs Expense)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: BarChart(
                  BarChartData(
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            int index = value.toInt();
                            if (index >= 0 && index < monthShortNames.length) {
                              return SideTitleWidget(
                                meta: meta,
                                axisSide: AxisSide.bottom,
                                child: Text(monthShortNames[index]),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          interval: 1000,
                        ),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    barGroups: barGroups,
                    barTouchData: BarTouchData(
                      touchCallback: (FlTouchEvent event, barTouchResponse) {
                        // Handle touch events if needed
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}