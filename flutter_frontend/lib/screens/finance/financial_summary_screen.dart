import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/financial_summary.dart';
import '../../providers/financial_summary_provider.dart';
import '../../widgets/monthly_comparison_chart.dart';

class FinancialSummaryScreen extends StatefulWidget {
  const FinancialSummaryScreen({Key? key}) : super(key: key);

  @override
  State<FinancialSummaryScreen> createState() => _FinancialSummaryScreenState();
}

class _FinancialSummaryScreenState extends State<FinancialSummaryScreen> {
  final TextEditingController _yearController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  bool _showYearComparison = false; // Tambahkan state untuk mode tampilan

  @override
  void initState() {
    super.initState();
    _yearController.text = selectedDate.year.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Summary'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Consumer<FinancialSummaryProvider>(
          builder: (context, provider, child) {
            return Column(
              children: [
                // Year and Month Selector
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _yearController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Year',
                                  border: OutlineInputBorder(),
                                ),
                                onChanged: (value) {
                                  if (value.isNotEmpty) {
                                    _loadFinancialData(int.tryParse(value) ?? DateTime.now().year, selectedDate.month);
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: DropdownButtonFormField<int>(
                                value: selectedDate.month,
                                decoration: const InputDecoration(
                                  labelText: 'Month',
                                  border: OutlineInputBorder(),
                                ),
                                items: List.generate(12, (index) {
                                  final month = index + 1;
                                  return DropdownMenuItem(
                                    value: month,
                                    child: Text(DateFormat('MMMM').format(DateTime(0, month))),
                                  );
                                }),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      selectedDate = DateTime(selectedDate.year, value);
                                    });
                                    _loadFinancialData(selectedDate.year, value);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                _loadFinancialData(selectedDate.year, selectedDate.month);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('View Summary'),
                            ),
                            // Toggle untuk mode tampilan
                            SwitchListTile(
                              title: const Text('Tahunan'),
                              value: _showYearComparison,
                              onChanged: (bool value) {
                                setState(() {
                                  _showYearComparison = value;
                                });
                              },
                              contentPadding: EdgeInsets.zero,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Financial Summary Cards
                if (provider.currentMonthSummary != null)
                  _buildSummaryCard(provider.currentMonthSummary!)
                else
                  const Center(
                    child: Text('Select a month to view financial summary'),
                  ),

                const SizedBox(height: 16),

                // Monthly Comparison Chart
                if (provider.monthlyData != null && provider.monthlyData!.isNotEmpty)
                  MonthlyComparisonChart(
                    financialData: provider.monthlyData!,
                    currentYear: selectedDate.year,
                    showYearComparison: _showYearComparison, // Gunakan state untuk menentukan mode
                  )
                else if (!provider.isLoading)
                  const Center(
                    child: Text('No financial data available for comparison'),
                  ),

                const SizedBox(height: 16),

                // Monthly Overview
                if (provider.monthlyData != null && provider.monthlyData!.isNotEmpty)
                  Expanded(
                    child: _buildMonthlyOverview(provider.monthlyData!),
                  )
                else if (!provider.isLoading)
                  Expanded(
                    child: Center(
                      child: Text('No financial data available for ${selectedDate.year}'),
                    ),
                  ),

                if (provider.isLoading)
                  const Center(child: CircularProgressIndicator()),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSummaryCard(FinancialSummary summary) {
    final totalIncome = summary.totalIncome;
    final totalExpense = summary.totalExpense;
    final netTotal = summary.netTotal;
    final totalSaving = summary.totalSaving;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${DateFormat('MMMM').format(DateTime(0, int.parse(summary.month), 1))} ${summary.year}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            _buildSummaryRow('Total Income', '+Rp ${totalIncome.toStringAsFixed(0)}', Colors.green),
            _buildSummaryRow('Total Expense', '-Rp ${totalExpense.toStringAsFixed(0)}', Colors.red),
            _buildSummaryRow('Net Total', 'Rp ${netTotal.toStringAsFixed(0)}', netTotal >= 0 ? Colors.green : Colors.red),
            _buildSummaryRow('Total Saving', 'Rp ${totalSaving.toStringAsFixed(0)}', Colors.blue),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String title, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyOverview(List<FinancialSummary> monthlyData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Monthly Overview',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            itemCount: monthlyData.length,
            itemBuilder: (context, index) {
              final monthData = monthlyData[index];
              final monthName = DateFormat('MMM').format(DateTime(0, int.parse(monthData.month)));
              final netTotal = monthData.netTotal;
              
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$monthName ${monthData.year}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildMiniSummary('Income', '+Rp ${monthData.totalIncome.toStringAsFixed(0)}', Colors.green),
                          _buildMiniSummary('Expense', '-Rp ${monthData.totalExpense.toStringAsFixed(0)}', Colors.red),
                          _buildMiniSummary('Net', 'Rp ${netTotal.toStringAsFixed(0)}', netTotal >= 0 ? Colors.green : Colors.red),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMiniSummary(String title, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  void _loadFinancialData(int year, int month) {
    Provider.of<FinancialSummaryProvider>(context, listen: false)
        .getMonthlyFinancialData(year);
  }
}