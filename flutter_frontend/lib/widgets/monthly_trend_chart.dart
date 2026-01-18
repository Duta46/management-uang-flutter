import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class MonthlyTrendChart extends StatefulWidget {
  final Map<String, dynamic>? reportData;
  final String selectedMonth;
  final Function(String) onMonthChanged;

  const MonthlyTrendChart({
    Key? key,
    required this.reportData,
    required this.selectedMonth,
    required this.onMonthChanged,
  }) : super(key: key);

  @override
  State<MonthlyTrendChart> createState() => _MonthlyTrendChartState();
}

class _MonthlyTrendChartState extends State<MonthlyTrendChart> {
  late List<BarChartGroupData> _chartBars;
  late List<String> _months;

  @override
  void initState() {
    super.initState();
    _months = [];
    _chartBars = [];
    _generateChartData();
  }

  @override
  void didUpdateWidget(MonthlyTrendChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.reportData != oldWidget.reportData || widget.selectedMonth != oldWidget.selectedMonth) {
      _generateChartData();
    }
  }

  void _generateChartData() {
    // Extract data from widget.reportData
    _months = [];
    _chartBars = [];

    if (widget.reportData != null) {
      // Extract actual data from reportData
      final monthlyData = widget.reportData!['monthly_data'] as List<dynamic>?;

      if (monthlyData != null && monthlyData.isNotEmpty) {
        for (int i = 0; i < monthlyData.length; i++) {
          final monthData = monthlyData[i];
          final monthName = monthData['month'] ?? 'Bulan ${i+1}';
          final income = (monthData['income'] as num?)?.toDouble() ?? 0.0;
          final expense = (monthData['expense'] as num?)?.toDouble() ?? 0.0;

          _months.add(monthName.toString());

          _chartBars.add(
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: income,
                  color: Colors.green,
                  width: 8,
                  borderSide: const BorderSide(color: Colors.white, width: 1),
                  borderRadius: BorderRadius.zero,
                ),
                BarChartRodData(
                  toY: expense,
                  color: Colors.red,
                  width: 8,
                  borderSide: const BorderSide(color: Colors.white, width: 1),
                  borderRadius: BorderRadius.zero,
                ),
              ],
              barsSpace: 2, // Space between the two bars in a group
            ),
          );
        }
      }
    }
  }

  String _formatCurrency(double amount) {
    // Format angka dengan pemisah ribuan menggunakan titik
    String formatted = amount.abs().toStringAsFixed(0);
    RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    formatted = formatted.replaceAllMapped(reg, (Match m) => '${m[1]}.');
    return 'Rp$formatted';
  }

  @override
  Widget build(BuildContext context) {
    // Generate chart data if not initialized
    if (_months.isEmpty) {
      _generateChartData();
    }

    // Calculate max value for the chart safely
    double maxValue = 0;
    for (var group in _chartBars) {
      for (var rod in group.barRods) {
        if (rod.toY > maxValue) {
          maxValue = rod.toY;
        }
      }
    }

    // Add 20% padding, but ensure it's not zero
    maxValue = maxValue > 0 ? (maxValue * 1.2) : 1000000; // Fallback to 1 million if all values are 0

    // Calculate safe interval for axis labels
    double safeInterval = _calculateSafeInterval(maxValue);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tren Bulanan',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            // Month selector
            Row(
              children: [
                const Text('Bulan:', style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _months.contains(widget.selectedMonth) ? widget.selectedMonth : _months.isNotEmpty ? _months.first : null,
                        isExpanded: true,
                        items: _months.map((String month) {
                          return DropdownMenuItem(
                            value: month,
                            child: Text(
                              month,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            widget.onMonthChanged(newValue);
                          }
                        },
                        style: const TextStyle(fontSize: 10),
                        icon: const Icon(Icons.arrow_drop_down, size: 16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            // Chart with AspectRatio to ensure proper sizing
            AspectRatio(
              aspectRatio: 1.6,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.center,
                  maxY: maxValue,
                  minY: 0,
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 && value.toInt() < _months.length) {
                            return Text(
                              _months[value.toInt()],
                              style: const TextStyle(
                                fontSize: 9,
                                color: Colors.black,
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: safeInterval, // Use safe interval
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            _formatCurrency(value).replaceAll('Rp', 'Rp.'),
                            style: const TextStyle(
                              fontSize: 9,
                              color: Colors.black,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: safeInterval, // Use safe interval
                    verticalInterval: 1,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.black.withOpacity(0.1),
                        strokeWidth: 1,
                      );
                    },
                    getDrawingVerticalLine: (value) {
                      return FlLine(
                        color: Colors.black.withOpacity(0.1),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey.withOpacity(0.2)),
                  ),
                  barGroups: _chartBars,
                  groupsSpace: 12, // Space between groups of bars
                ),
              ),
            ),
            const SizedBox(height: 8.0),
            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 4),
                    const Text('Pendapatan', style: TextStyle(fontSize: 10)),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      color: Colors.red,
                    ),
                    const SizedBox(width: 4),
                    const Text('Pengeluaran', style: TextStyle(fontSize: 10)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to calculate safe interval that's never zero
  double _calculateSafeInterval(double maxValue) {
    if (maxValue <= 0) {
      return 100000; // Default interval if maxValue is 0 or negative
    }

    // Calculate interval as 1/5th of maxValue, but ensure it's not zero
    double interval = maxValue / 5;

    // If interval is still zero due to floating point precision, use a small positive value
    if (interval == 0) {
      interval = 100000; // Default fallback
    }

    // Round to nice numbers (multiples of 100000, 500000, etc.) for better readability
    if (interval > 1000000) {
      return (interval / 1000000).ceil() * 1000000.toDouble();
    } else if (interval > 100000) {
      return (interval / 100000).ceil() * 100000.toDouble();
    } else if (interval > 10000) {
      return (interval / 10000).ceil() * 10000.toDouble();
    } else {
      return (interval / 1000).ceil() * 1000.toDouble();
    }
  }
}