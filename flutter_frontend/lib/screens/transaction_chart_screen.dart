import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/transaction.dart';
import '../../providers/transaction_provider_change_notifier.dart';
import '../../theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

class TransactionChartScreen extends StatefulWidget {
  const TransactionChartScreen({Key? key}) : super(key: key);

  @override
  _TransactionChartScreenState createState() => _TransactionChartScreenState();
}

class _TransactionChartScreenState extends State<TransactionChartScreen> {
  int selectedYear = DateTime.now().year;
  int selectedMonth = DateTime.now().month;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // Panggil fetchTransactions dari provider saat inisialisasi
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TransactionProvider>(context, listen: false)
          .fetchTransactions();
    });
  }

  String _formatCurrency(double amount) {
    // Format angka dengan pemisah ribuan menggunakan titik
    String formatted = amount.abs().toStringAsFixed(0);
    RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    formatted = formatted.replaceAllMapped(reg, (Match m) => '${m[1]}.');
    return amount < 0 ? '-$formatted' : formatted;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Grafik Transaksi'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, transactionProvider, child) {
          // Tampilkan loading saat data sedang dimuat
          if (transactionProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Filter transaksi untuk bulan dan tahun yang dipilih
          List<Transaction> monthlyTransactions = [];
          double totalIncome = 0;
          double totalExpense = 0;

          if (transactionProvider.transactions.isNotEmpty) {
            monthlyTransactions = transactionProvider.transactions
                .where((transaction) {
                  if (transaction.date == null) return false;
                  final transactionDate = transaction.date!;
                  return transactionDate.year == selectedYear &&
                         transactionDate.month == selectedMonth;
                })
                .toList();

            // Hitung total income dan expense untuk bulan ini
            totalIncome = monthlyTransactions
                .where((transaction) => transaction.type == 'income')
                .fold(0.0, (sum, transaction) => sum + transaction.amount);

            totalExpense = monthlyTransactions
                .where((transaction) => transaction.type == 'expense')
                .fold(0.0, (sum, transaction) => sum + transaction.amount);
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Month/Year selector
                _buildMonthYearSelector(),

                const SizedBox(height: 20),

                // Summary cards
                _buildSummaryCards(totalIncome, totalExpense),

                const SizedBox(height: 20),

                // Chart
                Expanded(
                  child: _buildTransactionChart(monthlyTransactions),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMonthYearSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () => _changeMonth(-1),
            ),
            Column(
              children: [
                Text(
                  _getMonthName(selectedMonth),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left, size: 18),
                      onPressed: () => _changeYear(-1),
                    ),
                    Text(
                      selectedYear.toString(),
                      style: const TextStyle(fontSize: 16),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right, size: 18),
                      onPressed: () => _changeYear(1),
                    ),
                  ],
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () => _changeMonth(1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(double totalIncome, double totalExpense) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildSummaryCard(
          'Pemasukan',
          'Rp ${_formatCurrency(totalIncome)}',
          AppTheme.incomeColor,
        ),
        _buildSummaryCard(
          'Pengeluaran',
          'Rp ${_formatCurrency(totalExpense)}',
          AppTheme.expenseColor,
        ),
        _buildSummaryCard(
          'Bersih',
          'Rp ${_formatCurrency(totalIncome - totalExpense)}',
          (totalIncome - totalExpense) >= 0 ? AppTheme.incomeColor : AppTheme.expenseColor,
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color) {
    return Container(
      width: 100,
      height: 80,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionChart(List<Transaction> transactions) {
    return DefaultTabController(
      length: 1,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'Ringkasan Harian'),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: TabBarView(
              children: [
                _buildDailyChart(transactions),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyChart(List<Transaction> transactions) {
    // Group transactions by date and calculate daily totals for the selected month/year
    Map<String, Map<String, double>> dailyTotals = {};

    for (var transaction in transactions) {
      if (transaction.date == null) continue;

      final transactionDate = transaction.date!;

      // Only include transactions from the selected month/year
      if (transactionDate.year == selectedYear && transactionDate.month == selectedMonth) {
        final dateKey = DateFormat('dd/MM').format(transactionDate);

        if (!dailyTotals.containsKey(dateKey)) {
          dailyTotals[dateKey] = {'income': 0, 'expense': 0};
        }

        final amount = transaction.amount;
        if (transaction.type == 'income') {
          dailyTotals[dateKey]!['income'] = dailyTotals[dateKey]!['income']! + amount;
        } else {
          dailyTotals[dateKey]!['expense'] = dailyTotals[dateKey]!['expense']! + amount;
        }
      }
    }

    // Prepare chart data
    List<BarChartGroupData> barGroups = [];
    List<String> dateLabels = dailyTotals.keys.toList()..sort();

    // Ensure barGroups is not empty by adding empty data if needed
    if (dateLabels.isEmpty) {
      // Add a single empty group to prevent chart from being empty
      barGroups.add(
        BarChartGroupData(
          x: 0,
          barsSpace: 4,
          barRods: [
            BarChartRodData(
              toY: 0,
              color: AppTheme.incomeColor,
              width: 14,
              borderRadius: BorderRadius.zero,
            ),
            BarChartRodData(
              toY: 0,
              color: AppTheme.expenseColor,
              width: 14,
              borderRadius: BorderRadius.zero,
            ),
          ],
        ),
      );
    } else {
      for (int i = 0; i < dateLabels.length; i++) {
        final dayData = dailyTotals[dateLabels[i]]!;

        barGroups.add(
          BarChartGroupData(
            x: i,
            barsSpace: 4,
            barRods: [
              BarChartRodData(
                toY: dayData['income']!,
                color: AppTheme.incomeColor,
                width: 14,
                borderRadius: BorderRadius.zero,
              ),
              BarChartRodData(
                toY: dayData['expense']!,
                color: AppTheme.expenseColor,
                width: 14,
                borderRadius: BorderRadius.zero,
              ),
            ],
          ),
        );
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Ringkasan Transaksi Harian',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: BarChart(
                BarChartData(
                  maxY: _calculateMaxY(dailyTotals), // Dynamic maxY calculation
                  minY: 0, // Set minY to 0
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          int index = value.toInt();
                          if (index >= 0 && index < dateLabels.length) {
                            // Only show every 3rd date to avoid clutter
                            if (index % 3 == 0) {
                              return SideTitleWidget(
                                meta: meta,
                                child: Text(dateLabels[index]),
                              );
                            }
                          }
                          return const Text('');
                        },
                        reservedSize: 40,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 60,
                        interval: _calculateYAxisInterval(_calculateMaxY(dailyTotals)),
                        getTitlesWidget: (value, meta) {
                          return SideTitleWidget(
                            meta: meta,
                            child: Text(
                              _formatYAxisLabel(value),
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        },
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
    );
  }


  // Helper method to calculate maxY dynamically with padding
  double _calculateMaxY(Map<String, Map<String, double>> dailyTotals) {
    if (dailyTotals.isEmpty) return 10;

    double maxValue = 0;
    for (var dayData in dailyTotals.values) {
      maxValue = maxValue > dayData['income']! ? maxValue : dayData['income']!;
      maxValue = maxValue > dayData['expense']! ? maxValue : dayData['expense']!;
    }

    // Add 20% padding to the maximum value
    double maxY = maxValue <= 0 ? 10 : maxValue * 1.2;
    return maxY;
  }

  // Helper method to format Y-axis labels
  String _formatYAxisLabel(double value) {
    if (value >= 1000000000) {
      return 'Rp${_formatCurrency(value / 1000000000)}M';
    } else if (value >= 1000000) {
      return 'Rp${_formatCurrency(value / 1000000)}Jt';
    } else if (value >= 1000) {
      return 'Rp${_formatCurrency(value / 1000)}Rb';
    } else {
      return 'Rp${_formatCurrency(value)}';
    }
  }

  // Helper method to calculate Y-axis interval based on max value
  double _calculateYAxisInterval(double maxY) {
    if (maxY <= 0) return 1000;

    // Calculate interval based on the scale of maxY
    double baseInterval = maxY / 5; // Aim for about 5-6 labels

    // Round to a "nice" number (1, 2, 5, 10, 20, 50, etc.)
    double magnitude = math.pow(10, (baseInterval > 0 ? math.log(baseInterval) / math.log(10) : 0).floor()).toDouble();
    double normalized = baseInterval / magnitude;

    if (normalized <= 1) {
      normalized = 1;
    } else if (normalized <= 2) {
      normalized = 2;
    } else if (normalized <= 5) {
      normalized = 5;
    } else {
      normalized = 10;
    }

    return normalized * magnitude;
  }

  void _changeMonth(int change) {
    int newMonth = selectedMonth + change;
    int newYear = selectedYear;

    if (newMonth > 12) {
      newYear++;
      newMonth = 1;
    } else if (newMonth < 1) {
      newYear--;
      newMonth = 12;
    }

    setState(() {
      selectedMonth = newMonth;
      selectedYear = newYear;
    });
  }

  void _changeYear(int change) {
    int newYear = selectedYear + change;

    setState(() {
      selectedYear = newYear;
    });
  }

  String _getMonthName(int month) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
}