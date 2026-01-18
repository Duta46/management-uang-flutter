import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/transaction_provider_change_notifier.dart';
import '../../providers/category_provider_change_notifier.dart';
import '../../models/transaction.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class MonthlyFinanceScreen extends StatefulWidget {
  const MonthlyFinanceScreen({Key? key}) : super(key: key);

  @override
  State<MonthlyFinanceScreen> createState() => _MonthlyFinanceScreenState();
}

class _MonthlyFinanceScreenState extends State<MonthlyFinanceScreen> {
  DateTime selectedMonth = DateTime.now();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    // Load data from providers
    await Provider.of<TransactionProvider>(context, listen: false).fetchTransactions();
    await Provider.of<CategoryProvider>(context, listen: false).fetchCategories();

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Keuangan Bulanan'),
        backgroundColor: Theme.of(context).cardTheme.color,
        foregroundColor: Theme.of(context).textTheme.titleLarge?.color,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month Selection
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_month),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      DateFormat('MMMM yyyy', 'id_ID').format(selectedMonth),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _selectMonth,
                    child: const Text('Pilih Bulan'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Financial Summary Cards
            Consumer<TransactionProvider>(
              builder: (context, transactionProvider, child) {
                if (_isLoading) {
                  return const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                // Calculate monthly totals
                List<Transaction> monthlyTransactions = transactionProvider.transactions
                    .where((transaction) {
                      return transaction.date != null &&
                          transaction.date!.month == selectedMonth.month &&
                          transaction.date!.year == selectedMonth.year;
                    })
                    .toList();

                double monthlyIncome = monthlyTransactions
                    .where((t) => t.type == 'income')
                    .fold(0, (sum, t) => sum + t.amount);

                double monthlyExpense = monthlyTransactions
                    .where((t) => t.type == 'expense')
                    .fold(0, (sum, t) => sum + t.amount);

                return Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Income and Expense Summary
                        Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: _buildSummaryCard(
                                'Pemasukan',
                                'Rp ${_formatCurrency(monthlyIncome)}',
                                Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 16), // Add spacing between cards
                            Expanded(
                              flex: 1,
                              child: _buildSummaryCard(
                                'Pengeluaran',
                                'Rp ${_formatCurrency(monthlyExpense)}',
                                Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Net Balance
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardTheme.color,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'Saldo Bulan Ini',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _formatCurrency(monthlyIncome - monthlyExpense),
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: (monthlyIncome - monthlyExpense) >= 0
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Chart Section
                        const Text(
                          'Grafik Transaksi Bulanan',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          height: 250, // Meningkatkan tinggi container untuk grafik
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardTheme.color,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: _buildSplineChart(monthlyTransactions),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatCurrency(double amount) {
    // Format angka dengan pemisah ribuan menggunakan titik
    String formatted = amount.abs().toStringAsFixed(0);
    RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    formatted = formatted.replaceAllMapped(reg, (Match m) => '${m[1]}.');
    return amount < 0 ? '-$formatted' : formatted;
  }

  Widget _buildSummaryCard(String title, String amount, Color color) {
    // Menentukan ikon berdasarkan judul
    IconData icon = title == 'Pemasukan' ? Icons.arrow_downward : Icons.arrow_upward;

    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: color,
              ),
              const SizedBox(width: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectMonth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
      locale: const Locale('id', 'ID'),
    );
    if (picked != null) {
      setState(() {
        selectedMonth = picked;
      });
    }
  }

  Widget _buildSplineChart(List<Transaction> transactions) {
    // Group transactions by day
    Map<int, double> incomeByDay = {};
    Map<int, double> expenseByDay = {};

    for (var transaction in transactions) {
      DateTime date = transaction.date!;
      int day = date.day;

      if (transaction.type == 'income') {
        incomeByDay[day] = (incomeByDay[day] ?? 0) + transaction.amount;
      } else {
        expenseByDay[day] = (expenseByDay[day] ?? 0) + transaction.amount;
      }
    }

    // Find max day in the month
    int daysInMonth = DateTime(selectedMonth.year, selectedMonth.month + 1, 0).day;

    // Prepare data points for spline chart
    List<FlSpot> incomeSpots = [];
    List<FlSpot> expenseSpots = [];

    for (int i = 1; i <= daysInMonth; i++) {
      double income = incomeByDay[i] ?? 0;
      double expense = expenseByDay[i] ?? 0;

      incomeSpots.add(FlSpot(i.toDouble(), income));
      expenseSpots.add(FlSpot(i.toDouble(), expense));
    }

    // Determine the maximum value for scaling the chart
    double maxValue = 0;
    for (var spot in [...incomeSpots, ...expenseSpots]) {
      if (spot.y > maxValue) maxValue = spot.y;
    }

    // Add 10% padding to the maximum value
    maxValue = maxValue * 1.1;
    if (maxValue == 0) maxValue = 100000; // Default value if no transactions

    return LineChart(
      LineChartData(
        lineTouchData: LineTouchData(
          touchCallback: (FlTouchEvent event, lineTouchResponse) {},
          handleBuiltInTouches: false, // Disable touch to prevent interference
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: maxValue / 4, // Dynamic interval based on max value
          verticalInterval: 5,
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 25,
              interval: daysInMonth > 15 ? 5 : 1, // Show every 5th day for months with more than 15 days
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: maxValue / 4, // Dynamic interval based on max value
              getTitlesWidget: (value, meta) {
                if (value == 0) {
                  return const Text('');
                }
                String formattedValue = _formatCurrency(value.abs());
                // Limit the length of the formatted value to prevent overflow
                if (formattedValue.length > 6) {
                  formattedValue = formattedValue.substring(0, 6) + '..';
                }
                return Text(
                  formattedValue,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 9,
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(
          show: false,
        ),
        minX: 1,
        maxX: daysInMonth.toDouble(),
        minY: 0,
        maxY: maxValue, // Dynamic maximum based on actual data
        lineBarsData: [
          // Income line
          LineChartBarData(
            spots: incomeSpots,
            isCurved: true, // This creates the spline effect
            color: Theme.of(context).colorScheme.primary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: false,
            ),
            belowBarData: BarAreaData(
              show: true,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            ),
          ),
          // Expense line
          LineChartBarData(
            spots: expenseSpots,
            isCurved: true, // This creates the spline effect
            color: Theme.of(context).colorScheme.error,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: false,
            ),
            belowBarData: BarAreaData(
              show: true,
              color: Theme.of(context).colorScheme.error.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }
}