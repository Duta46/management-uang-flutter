import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../models/financial_summary.dart';

class MonthlyComparisonChart extends StatelessWidget {
  final List<FinancialSummary> financialData;
  final int currentYear;
  final bool showYearComparison; // Tambahkan parameter untuk mode perbandingan tahunan

  const MonthlyComparisonChart({
    Key? key,
    required this.financialData,
    required this.currentYear,
    this.showYearComparison = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (showYearComparison) {
      return _buildYearComparisonChart();
    } else {
      return _buildMonthlyComparisonChart();
    }
  }

  // Chart perbandingan bulanan dalam satu tahun
  Widget _buildMonthlyComparisonChart() {
    final List<BarChartGroupData> chartData = [];

    // Ambil data untuk 12 bulan dalam tahun berjalan
    for (int month = 1; month <= 12; month++) {
      // Cari data keuangan untuk bulan ini
      final monthData = financialData.firstWhere(
        (data) =>
            int.parse(data.month) == month &&
            data.year == currentYear,
        orElse: () => FinancialSummary(
          month: month.toString().padLeft(2, '0'),
          year: currentYear,
          totalIncome: 0,
          totalExpense: 0,
          netTotal: 0,
          totalSaving: 0,
        ),
      );

      // Buat bar chart group data
      chartData.add(
        BarChartGroupData(
          x: month - 1, // index bulan (0-11)
          barRods: [
            // Pemasukan bar
            BarChartRodData(
              toY: monthData.totalIncome,
              width: 10,
              color: Colors.green,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
            // Pengeluaran bar
            BarChartRodData(
              toY: monthData.totalExpense,
              width: 10,
              color: Colors.red,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
            // Tabungan bar
            BarChartRodData(
              toY: monthData.totalSaving,
              width: 10,
              color: Colors.blue,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
          ],
        ),
      );
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Perbandingan Keuangan Tahun $currentYear',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 300, // Tinggi chart lebih besar untuk menampung 12 bulan
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: _getMaxValue(chartData),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          // Menampilkan nama bulan di bawah
                          final monthIndex = value.toInt();
                          if (monthIndex >= 0 && monthIndex < 12) {
                            final monthName = DateFormat('MMM').format(DateTime(0, monthIndex + 1));

                            return SideTitleWidget(
                              meta: meta,
                              space: 4,
                              child: RotatedBox(
                                quarterTurns: -45, // Rotasi teks agar tidak terlalu panjang
                                child: Text(
                                  monthName,
                                  style: const TextStyle(fontSize: 10),
                                ),
                              ),
                            );
                          }
                          return SideTitleWidget(
                            meta: meta,
                            child: Text(''),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return SideTitleWidget(
                            meta: meta,
                            space: 4,
                            child: Text(
                              'Rp${(value ~/ 1000000)}M', // Format dalam jutaan
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        },
                        reservedSize: 50,
                      ),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: false,
                  ),
                  gridData: FlGridData(
                    show: true,
                    horizontalInterval: 100000,
                    drawHorizontalLine: true,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.withOpacity(0.1),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  barGroups: chartData,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        String title = '';
                        double value = 0;

                        switch (rodIndex) {
                          case 0:
                            title = 'Pemasukan';
                            value = rod.toY;
                            break;
                          case 1:
                            title = 'Pengeluaran';
                            value = rod.toY;
                            break;
                          case 2:
                            title = 'Tabungan';
                            value = rod.toY;
                            break;
                        }

                        return BarTooltipItem(
                          '${DateFormat('MMM').format(DateTime(0, groupIndex + 1))}\n$title: Rp${value.toStringAsFixed(0)}',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Legenda
            Wrap(
              spacing: 16,
              children: [
                _buildLegendItem(Colors.green, 'Pemasukan'),
                _buildLegendItem(Colors.red, 'Pengeluaran'),
                _buildLegendItem(Colors.blue, 'Tabungan'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Chart perbandingan tahunan
  Widget _buildYearComparisonChart() {
    // Kita perlu mengelompokkan data bulanan berdasarkan tahun
    Map<int, YearlyFinancialData> yearlyData = {};

    // Kelompokkan data bulanan menjadi data tahunan
    for (var monthlySummary in financialData) {
      int year = monthlySummary.year;
      if (!yearlyData.containsKey(year)) {
        yearlyData[year] = YearlyFinancialData(
          year: year,
          totalIncome: 0,
          totalExpense: 0,
          netTotal: 0,
          totalSaving: 0,
        );
      }

      // Tambahkan data bulanan ke data tahunan
      YearlyFinancialData yearly = yearlyData[year]!;
      yearlyData[year] = YearlyFinancialData(
        year: year,
        totalIncome: yearly.totalIncome + monthlySummary.totalIncome,
        totalExpense: yearly.totalExpense + monthlySummary.totalExpense,
        netTotal: yearly.netTotal + monthlySummary.netTotal,
        totalSaving: yearly.totalSaving + monthlySummary.totalSaving,
      );
    }

    // Urutkan tahun dari yang terlama ke terbaru
    List<int> sortedYears = yearlyData.keys.toList()..sort();

    // Buat data chart
    final List<BarChartGroupData> chartData = [];
    for (int i = 0; i < sortedYears.length; i++) {
      int year = sortedYears[i];
      YearlyFinancialData yearlySummary = yearlyData[year]!;

      chartData.add(
        BarChartGroupData(
          x: i,
          barRods: [
            // Pemasukan bar
            BarChartRodData(
              toY: yearlySummary.totalIncome,
              width: 14,
              color: Colors.green,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
            // Pengeluaran bar
            BarChartRodData(
              toY: yearlySummary.totalExpense,
              width: 14,
              color: Colors.red,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
            // Tabungan bar
            BarChartRodData(
              toY: yearlySummary.totalSaving,
              width: 14,
              color: Colors.blue,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
          ],
        ),
      );
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Perbandingan Keuangan Tahunan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: _getMaxValue(chartData),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final yearIndex = value.toInt();
                          if (yearIndex >= 0 && yearIndex < sortedYears.length) {
                            final year = sortedYears[yearIndex];
                            return SideTitleWidget(
                              meta: meta,
                              space: 4,
                              child: Text('$year'),
                            );
                          }
                          return SideTitleWidget(
                            child: Text(''),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return SideTitleWidget(
                            meta: meta,
                            space: 4,
                            child: Text(
                              'Rp${(value ~/ 1000000)}M',
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        },
                        reservedSize: 50,
                      ),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: false,
                  ),
                  gridData: FlGridData(
                    show: true,
                    horizontalInterval: 100000,
                    drawHorizontalLine: true,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.withOpacity(0.1),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  barGroups: chartData,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        if (groupIndex >= sortedYears.length) return null;

                        String title = '';
                        double value = 0;
                        int year = sortedYears[groupIndex];

                        switch (rodIndex) {
                          case 0:
                            title = 'Pemasukan';
                            value = rod.toY;
                            break;
                          case 1:
                            title = 'Pengeluaran';
                            value = rod.toY;
                            break;
                          case 2:
                            title = 'Tabungan';
                            value = rod.toY;
                            break;
                        }

                        return BarTooltipItem(
                          '$year\n$title: Rp${value.toStringAsFixed(0)}',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Legenda
            Wrap(
              spacing: 16,
              children: [
                _buildLegendItem(Colors.green, 'Pemasukan'),
                _buildLegendItem(Colors.red, 'Pengeluaran'),
                _buildLegendItem(Colors.blue, 'Tabungan'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  double _getMaxValue(List<BarChartGroupData> chartData) {
    double max = 0;
    for (var group in chartData) {
      for (var rod in group.barRods) {
        if (rod.toY > max) max = rod.toY;
      }
    }
    // Tambahkan sedikit padding di atas
    return max * 1.1;
  }

  Widget _buildLegendItem(Color color, String title) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          title,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}