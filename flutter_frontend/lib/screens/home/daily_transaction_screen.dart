import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/transaction_provider_change_notifier.dart';
import '../../providers/category_provider_change_notifier.dart';
import '../../models/transaction.dart';
import 'package:intl/intl.dart';

class DailyTransactionScreen extends StatefulWidget {
  const DailyTransactionScreen({Key? key}) : super(key: key);

  @override
  State<DailyTransactionScreen> createState() => _DailyTransactionScreenState();
}

class _DailyTransactionScreenState extends State<DailyTransactionScreen> {
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaksi Harian'),
        backgroundColor: Theme.of(context).cardTheme.color,
        foregroundColor: Theme.of(context).textTheme.titleLarge?.color,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Selection
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
                  const Icon(Icons.date_range),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      DateFormat('dd MMMM yyyy', 'id_ID').format(selectedDate),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _selectDate,
                    child: const Text('Pilih Tanggal'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Daily Transactions Header
            const Text(
              'Aktivitas Transaksi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // Transactions List
            Expanded(
              child: Consumer<TransactionProvider>(
                builder: (context, transactionProvider, child) {
                  if (transactionProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  // Filter transactions by selected date
                  List<Transaction> dailyTransactions = transactionProvider.transactions
                      .where((transaction) =>
                          transaction.date != null &&
                          transaction.date!.year == selectedDate.year &&
                          transaction.date!.month == selectedDate.month &&
                          transaction.date!.day == selectedDate.day)
                      .toList();
                  
                  if (dailyTransactions.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Belum ada transaksi hari ini',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  return ListView.builder(
                    itemCount: dailyTransactions.length,
                    itemBuilder: (context, index) {
                      Transaction transaction = dailyTransactions[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: transaction.type == 'income' 
                                  ? Theme.of(context).colorScheme.primary.withOpacity(0.1) 
                                  : Theme.of(context).colorScheme.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              transaction.type == 'income' 
                                  ? Icons.arrow_downward 
                                  : Icons.arrow_upward,
                              color: transaction.type == 'income' 
                                  ? Theme.of(context).colorScheme.primary 
                                  : Theme.of(context).colorScheme.error,
                            ),
                          ),
                          title: Text(
                            transaction.description ?? 'Transaksi Tanpa Nama',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text(
                            transaction.category?.name ?? 'Kategori Tidak Diketahui',
                          ),
                          trailing: Text(
                            transaction.type == 'income' 
                                ? '+${_formatCurrency(transaction.amount)}' 
                                : '-${_formatCurrency(transaction.amount)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: transaction.type == 'income' 
                                  ? Theme.of(context).colorScheme.primary 
                                  : Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
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

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
      locale: const Locale('id', 'ID'),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }
}