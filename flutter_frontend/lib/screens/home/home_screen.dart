import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_frontend/providers/transaction_provider_change_notifier.dart';
import 'package:flutter_frontend/providers/auth_provider_change_notifier.dart';
import 'package:flutter_frontend/theme/app_theme.dart';
import '../../screens/categories/category_list_screen.dart';
import '../../screens/transactions/transaction_list_screen.dart';
import '../../screens/transactions/transaction_form_screen.dart';
import 'add_transaction_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TransactionProvider>(context, listen: false).fetchTransactions();
    });
  }

  void _handleLogout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    bool success = await authProvider.logout();

    if (success) {
      // Navigate back to login screen
      Navigator.pushReplacementNamed(context, '/login');
    }
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
    final transactionProvider = Provider.of<TransactionProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Keuangan Pribadi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          PopupMenuButton(
            icon: Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'logout') {
                _handleLogout();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Keluar', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting
              Text(
                'Halo, Selamat Datang Kembali!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Lacak keuangan Anda dengan mudah',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondaryColor,
                    ),
              ),
              
              const SizedBox(height: 24),
              
              // Balance Summary Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Saldo Total',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: () {
                            transactionProvider.fetchTransactions();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Rp ',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: AppTheme.textColor,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        Text(
                          _formatCurrency(transactionProvider.balance),
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: AppTheme.textColor,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildBalanceCard(
                          'Pemasukan',
                          '+Rp ${_formatCurrency(transactionProvider.income)}',
                          AppTheme.incomeColor,
                        ),
                        _buildBalanceCard(
                          'Pengeluaran',
                          '-Rp ${_formatCurrency(transactionProvider.expense)}',
                          AppTheme.expenseColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Recent Transactions Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Transaksi Terbaru',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/history');
                    },
                    child: const Text('Lihat Semua'),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Recent Transactions List
              if (transactionProvider.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (transactionProvider.transactions.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text('Belum ada transaksi'),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: transactionProvider.transactions.length > 3
                      ? 3
                      : transactionProvider.transactions.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final transaction = transactionProvider.transactions[index];
                    final isIncome = transaction.type == 'income';
                    final amountColor = isIncome ? AppTheme.incomeColor : AppTheme.expenseColor;

                    return Card(
                      margin: EdgeInsets.zero,
                      child: ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isIncome
                                ? AppTheme.incomeLightColor
                                : AppTheme.expenseLightColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            isIncome ? Icons.add : Icons.remove,
                            color: amountColor,
                          ),
                        ),
                        title: Text(
                          transaction.description ?? 'No description',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          transaction.category?.name ?? 'Uncategorized',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${isIncome ? '+' : '-'}Rp ${_formatCurrency(transaction.amount)}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: amountColor,
                              ),
                            ),
                            PopupMenuButton(
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
                                              final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
                                              bool success = await transactionProvider.deleteTransaction(transaction.id!);
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
                                                    content: Text(transactionProvider.message),
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
                                  child: Text('Edit'),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Hapus'),
                                ),
                              ],
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
      ),
    );
  }

  Widget _buildBalanceCard(String title, String amount, Color color) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 40,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}