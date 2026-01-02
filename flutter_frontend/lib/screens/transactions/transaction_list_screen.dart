import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_frontend/providers/transaction_provider_change_notifier.dart';
import 'package:flutter_frontend/theme/app_theme.dart';
import 'transaction_form_screen.dart';

class TransactionListScreen extends StatelessWidget {
  const TransactionListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Transaksi'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, child) {
          // Load transactions when screen is built
          WidgetsBinding.instance.addPostFrameCallback((_) {
            provider.fetchTransactions();
          });

          if (provider.transactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 80,
                    color: AppTheme.textSecondaryColor,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Belum ada transaksi',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tambahkan transaksi pertama Anda!',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchTransactions(),
            child: ListView.builder(
              itemCount: provider.transactions.length,
              itemBuilder: (context, index) {
                final transaction = provider.transactions[index];
                final isIncome = transaction.type == 'income';
                final amountColor = isIncome ? AppTheme.incomeColor : AppTheme.expenseColor;
                final backgroundColor = isIncome ? AppTheme.incomeLightColor : AppTheme.expenseLightColor;

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: amountColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: backgroundColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          isIncome ? Icons.arrow_upward : Icons.arrow_downward,
                          color: amountColor,
                          size: 24,
                        ),
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  transaction.category?.name ?? 'Tanpa Kategori',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: AppTheme.textColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  transaction.description ?? 'Tidak ada deskripsi',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppTheme.textSecondaryColor,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${DateFormat('dd MMM').format(transaction.date ?? DateTime.now())}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textSecondaryColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isIncome ? '+Rp${transaction.amount}' : '-Rp${transaction.amount}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: amountColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      trailing: PopupMenuButton(
                        onSelected: (value) async {
                          if (value == 'edit') {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TransactionFormScreen(transaction: transaction),
                              ),
                            );

                            // Refresh data after edit
                            if (result != null) {
                              await Provider.of<TransactionProvider>(context, listen: false).fetchTransactions();
                            }
                          } else if (value == 'delete') {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Hapus Transaksi'),
                                content: const Text('Apakah Anda yakin ingin menghapus transaksi ini?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Batal'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      Navigator.pop(context);
                                      if (transaction.id != null) {
                                        bool success = await provider.deleteTransaction(transaction.id!);
                                        if (success) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Transaksi berhasil dihapus'),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(provider.message),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Tidak dapat menghapus transaksi - ID tidak ditemukan'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    },
                                    child: const Text('Hapus'),
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, color: AppTheme.primaryColor),
                                SizedBox(width: 8),
                                Text('Edit'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Hapus', style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TransactionFormScreen(),
            ),
          );
          // Refresh data after adding new transaction
          final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
          await transactionProvider.fetchTransactions();
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}