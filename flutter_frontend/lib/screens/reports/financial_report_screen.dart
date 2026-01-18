import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_frontend/providers/financial_report_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:printing/printing.dart';
import 'package:flutter_frontend/services/pdf_service.dart';
import 'package:flutter_frontend/widgets/monthly_trend_chart.dart';

class FinancialReportScreen extends StatefulWidget {
  const FinancialReportScreen({Key? key}) : super(key: key);

  @override
  State<FinancialReportScreen> createState() => _FinancialReportScreenState();
}

class _FinancialReportScreenState extends State<FinancialReportScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FinancialReportProvider>(context, listen: false).fetchReport();
    });
  }

  @override
  Widget build(BuildContext context) {
    final reportProvider = Provider.of<FinancialReportProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardTheme.color,
        foregroundColor: Theme.of(context).textTheme.titleLarge?.color,
        elevation: 0,
        title: const Text('Laporan & Analisis'),
        iconTheme: IconThemeData(
          color: Theme.of(context).textTheme.titleLarge?.color,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              _showDownloadConfirmationDialog(context, 'PDF');
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => reportProvider.fetchReport(period: reportProvider.selectedPeriod),
          ),
        ],
      ),
      body: reportProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => reportProvider.fetchReport(period: reportProvider.selectedPeriod),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Period selector
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardTheme.color,
                        border: Border.all(color: Theme.of(context).dividerColor),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: DropdownButton<String>(
                        value: reportProvider.selectedPeriod,
                        isExpanded: true,
                        underline: Container(),
                        items: const [
                          DropdownMenuItem(
                            value: 'daily',
                            child: Text('Harian'),
                          ),
                          DropdownMenuItem(
                            value: 'weekly',
                            child: Text('Mingguan'),
                          ),
                          DropdownMenuItem(
                            value: 'monthly',
                            child: Text('Bulanan'),
                          ),
                          DropdownMenuItem(
                            value: 'yearly',
                            child: Text('Tahunan'),
                          ),
                        ],
                        onChanged: (value) {
                          reportProvider.changePeriod(value!);
                        },
                      ),
                    ),
                    const SizedBox(height: 24.0),
                    // Monthly Trend Chart
                    MonthlyTrendChart(
                      reportData: reportProvider.reportData,
                      selectedMonth: reportProvider.selectedMonth,
                      onMonthChanged: (month) {
                        reportProvider.setSelectedMonth(month);
                      },
                    ),
                    const SizedBox(height: 16.0),
                    // PDF Download Button
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          if (reportProvider.selectedMonth.isNotEmpty) {
                            await _downloadPdf(reportProvider);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Silakan pilih bulan terlebih dahulu'),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.picture_as_pdf),
                        label: const Text('Download PDF'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24.0),
                    // Tampilkan pesan jika tidak ada data sama sekali
                    if (reportProvider.reportData == null ||
                        (reportProvider.reportData['summary'] == null &&
                         reportProvider.reportData['expense_breakdown'] == null &&
                         reportProvider.reportData['budget_comparison'] == null &&
                         reportProvider.reportData['savings_progress'] == null &&
                         reportProvider.reportData['upcoming_bills'] == null))
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardTheme.color,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Ikon laporan di tengah
                            Icon(
                              Icons.analytics_outlined,
                              size: 60,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(height: 16),
                            // Teks utama: "Belum Ada Laporan"
                            Text(
                              'Belum Ada Laporan',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).textTheme.titleLarge?.color,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            // Teks deskripsi lebih kecil di bawahnya
                            Text(
                              'Laporan akan muncul di sini setelah Anda memiliki data keuangan',
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).textTheme.bodyMedium?.color,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Financial Summary
                          _buildSummaryCard(reportProvider),
                          const SizedBox(height: 16.0),
                          // Income vs Expense Chart
                          _buildIncomeExpenseChart(reportProvider),
                          const SizedBox(height: 16.0),
                          // Expense Breakdown
                          _buildExpenseBreakdownCard(reportProvider),
                          const SizedBox(height: 16.0),
                          // Expense Breakdown Chart
                          _buildExpenseBreakdownChart(reportProvider),
                          const SizedBox(height: 16.0),
                          // Budget vs Actual
                          _buildBudgetComparisonCard(reportProvider),
                          const SizedBox(height: 16.0),
                          // Savings Progress
                          _buildSavingsProgressCard(reportProvider),
                          const SizedBox(height: 16.0),
                          // Upcoming Bills
                          _buildUpcomingBillsCard(reportProvider),
                        ],
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSummaryCard(FinancialReportProvider reportProvider) {
    final summary = reportProvider.reportData?['summary'];

    if (summary == null) {
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ringkasan Keuangan',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              'Tidak ada data keuangan untuk periode ini',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
      );
    }

    final income = double.tryParse(summary['income'].toString()) ?? 0;
    final expenses = double.tryParse(summary['expenses'].toString()) ?? 0;
    final netIncome = double.tryParse(summary['net_income'].toString()) ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ringkasan Keuangan',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          const SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text(
                    'Pemasukan',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                  Text(
                    'Rp ${income.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    'Pengeluaran',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                  Text(
                    'Rp ${expenses.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    'Net',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                  Text(
                    'Rp ${netIncome.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: netIncome >= 0 ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseBreakdownCard(FinancialReportProvider reportProvider) {
    final breakdown = reportProvider.reportData?['expense_breakdown'];

    if (breakdown == null) {
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rincian Pengeluaran',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              'Tidak ada data pengeluaran untuk periode ini',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
      );
    }

    final totalExpenses = double.tryParse(breakdown['total_expenses'].toString()) ?? 0;
    final breakdownData = breakdown['breakdown'] as Map<String, dynamic>;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rincian Pengeluaran',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          const SizedBox(height: 16.0),
          if (breakdownData.isEmpty)
            Text(
              'Tidak ada pengeluaran',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            )
          else
            ...breakdownData.entries.map((entry) {
              final amount = double.tryParse(entry.value['amount'].toString()) ?? 0;
              final percentage = double.tryParse(entry.value['percentage'].toString()) ?? 0;

              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry.key,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.titleLarge?.color,
                      ),
                    ),
                    Text(
                      'Rp ${amount.toStringAsFixed(0)} (${percentage.toStringAsFixed(1)}%)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.titleLarge?.color,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildBudgetComparisonCard(FinancialReportProvider reportProvider) {
    final comparisonList = reportProvider.reportData?['budget_comparison'];

    if (comparisonList == null) {
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Anggaran vs Realisasi',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              'Tidak ada data anggaran untuk periode ini',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Anggaran vs Realisasi',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          const SizedBox(height: 16.0),
          if (comparisonList.isEmpty)
            Text(
              'Tidak ada data anggaran',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            )
          else
            ...comparisonList.map((item) {
              final category = item['category'];
              final budgeted = double.tryParse(item['budgeted'].toString()) ?? 0;
              final spent = double.tryParse(item['spent'].toString()) ?? 0;
              final percentage = double.tryParse(item['percentage_used'].toString()) ?? 0;

              Color progressColor;
              if (percentage >= 100) {
                progressColor = Theme.of(context).colorScheme.error;
              } else if (percentage >= 80) {
                progressColor = Colors.orange;
              } else {
                progressColor = Theme.of(context).colorScheme.primary;
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.titleLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: Theme.of(context).dividerColor,
                      valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                    ),
                    const SizedBox(height: 4.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Rp ${spent.toStringAsFixed(0)} / Rp ${budgeted.toStringAsFixed(0)}',
                          style: TextStyle(
                            color: Theme.of(context).textTheme.titleLarge?.color,
                          ),
                        ),
                        Text(
                          '${percentage.toStringAsFixed(1)}%',
                          style: TextStyle(
                            color: Theme.of(context).textTheme.titleLarge?.color,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildSavingsProgressCard(FinancialReportProvider reportProvider) {
    final savingsList = reportProvider.reportData?['savings_progress'];

    if (savingsList == null) {
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Progres Tabungan & Target',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              'Tidak ada data tabungan untuk periode ini',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Progres Tabungan & Target',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          const SizedBox(height: 16.0),
          if (savingsList.isEmpty)
            Text(
              'Tidak ada target tabungan',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            )
          else
            ...savingsList.map((item) {
              final name = item['name'];
              final current = double.tryParse(item['current_amount'].toString()) ?? 0;
              final target = double.tryParse(item['target_amount'].toString()) ?? 0;
              final percentage = double.tryParse(item['progress_percentage'].toString()) ?? 0;

              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.titleLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: Theme.of(context).dividerColor,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                    const SizedBox(height: 4.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Rp ${current.toStringAsFixed(0)} / Rp ${target.toStringAsFixed(0)}',
                          style: TextStyle(
                            color: Theme.of(context).textTheme.titleLarge?.color,
                          ),
                        ),
                        Text(
                          '${percentage.toStringAsFixed(1)}%',
                          style: TextStyle(
                            color: Theme.of(context).textTheme.titleLarge?.color,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildUpcomingBillsCard(FinancialReportProvider reportProvider) {
    if (reportProvider.reportData?['upcoming_bills'] == null) return const SizedBox.shrink();

    final billsList = reportProvider.reportData['upcoming_bills'] as List;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tagihan Mendatang',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          const SizedBox(height: 16.0),
          if (billsList.isEmpty)
            Text(
              'Tidak ada tagihan mendatang',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            )
          else
            ...billsList.map((item) {
              final name = item['name'];
              final amount = double.tryParse(item['amount'].toString()) ?? 0;
              final dueDate = item['due_date'];
              final daysUntilDue = item['days_until_due'];

              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).textTheme.titleLarge?.color,
                            ),
                          ),
                          Text(
                            'Jatuh tempo: $dueDate (${daysUntilDue} hari lagi)',
                            style: TextStyle(
                              color: Theme.of(context).textTheme.bodyMedium?.color,
                              fontSize: 12.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'Rp ${amount.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.titleLarge?.color,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildIncomeExpenseChart(FinancialReportProvider reportProvider) {
    if (reportProvider.reportData?['summary'] == null) return const SizedBox.shrink();

    final summary = reportProvider.reportData['summary'];
    final income = double.tryParse(summary['income'].toString()) ?? 0;
    final expenses = double.tryParse(summary['expenses'].toString()) ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Grafik Pendapatan vs Pengeluaran',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          const SizedBox(height: 16.0),
          AspectRatio(
            aspectRatio: 1.7,
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    color: Theme.of(context).colorScheme.primary,
                    value: income,
                    title: 'Pendapatan',
                    radius: 50,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    color: Theme.of(context).colorScheme.error,
                    value: expenses,
                    title: 'Pengeluaran',
                    radius: 50,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
                centerSpaceRadius: 30,
                sectionsSpace: 2,
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {},
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseBreakdownChart(FinancialReportProvider reportProvider) {
    if (reportProvider.reportData?['expense_breakdown'] == null) return const SizedBox.shrink();

    final breakdown = reportProvider.reportData['expense_breakdown'];
    final breakdownData = breakdown['breakdown'] as Map<String, dynamic>;

    if (breakdownData.isEmpty) return const SizedBox.shrink();

    List<PieChartSectionData> sections = [];
    List<Color> colors = [
      Colors.blue,
      Colors.orange,
      Colors.purple,
      Colors.brown,
      Colors.pink,
      Colors.teal,
      Colors.amber,
      Colors.cyan,
    ];

    int index = 0;
    breakdownData.forEach((category, data) {
      final amount = double.tryParse(data['amount'].toString()) ?? 0;
      sections.add(
        PieChartSectionData(
          color: colors[index % colors.length],
          value: amount,
          title: '${category.substring(0, category.length > 8 ? 8 : category.length)}${category.length > 8 ? '..' : ''}',
          radius: 50,
          titleStyle: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
      index++;
    });

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Distribusi Pengeluaran per Kategori',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          const SizedBox(height: 16.0),
          AspectRatio(
            aspectRatio: 1.7,
            child: PieChart(
              PieChartData(
                sections: sections,
                centerSpaceRadius: 30,
                sectionsSpace: 2,
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {},
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDownloadConfirmationDialog(BuildContext context, String format) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Konfirmasi Download PDF"),
          content: Text("Apakah Anda yakin ingin mengunduh laporan dalam format PDF untuk periode ${Provider.of<FinancialReportProvider>(context, listen: false).selectedPeriod}?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
              },
              child: const Text("Batal"),
            ),
            TextButton(
              onPressed: () {
                // Di sini nanti akan ditambahkan logika untuk download laporan
                _performDownload(format);
                Navigator.of(context).pop(); // Tutup dialog
              },
              child: const Text("Ya"),
            ),
          ],
        );
      },
    );
  }

  void _performDownload(String format) {
    // Placeholder untuk logika download
    // Di sini akan ditambahkan logika untuk mengenerate dan download file PDF
    print("Downloading report in $format format");
    // Nanti bisa ditambahkan implementasi nyata untuk download file
  }

  Future<void> _downloadPdf(FinancialReportProvider reportProvider) async {
    try {
      final pdfBytes = await PdfService.generateFinancialReportPdf(
        month: reportProvider.selectedMonth,
        reportData: reportProvider.reportData,
      );

      await Printing.layoutPdf(
        onLayout: (format) async => pdfBytes,
      );
    } catch (e) {
      print('Error generating PDF: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal membuat PDF: $e'),
        ),
      );
    }
  }
}