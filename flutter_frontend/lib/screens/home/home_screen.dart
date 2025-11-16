import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/menu_item.dart';
import '../../providers/auth_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/saving_provider.dart';
import '../../providers/financial_summary_provider.dart';
import '../auth/login_screen.dart';
import '../transactions/transaction_list_screen.dart';
import '../categories/category_list_screen.dart';
import '../budgets/budget_list_screen.dart';
import '../savings/saving_list_screen.dart';
import '../finance/financial_summary_screen.dart';
import '../../widgets/monthly_comparison_chart.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Load initial data when the screen is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
      transactionProvider.fetchTransactions();
    });
  }

  List<MenuItem> get _menuItems => [
    MenuItem(
      title: 'Beranda',
      icon: Icons.dashboard,
      screen: const DashboardScreen(),
    ),
    MenuItem(
      title: 'Transaksi',
      icon: Icons.attach_money,
      screen: const TransactionListScreen(),
    ),
    MenuItem(
      title: 'Kategori',
      icon: Icons.category,
      screen: const CategoryListScreen(),
    ),
    MenuItem(
      title: 'Anggaran',
      icon: Icons.account_balance,
      screen: const BudgetListScreen(),
    ),
    MenuItem(
      title: 'Tabungan',
      icon: Icons.savings,
      screen: const SavingListScreen(),
    ),
    MenuItem(
      title: 'Ringkasan',
      icon: Icons.analytics,
      screen: const FinancialSummaryScreen(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final menuItems = _menuItems;
    final currentScreen = menuItems[_selectedIndex].screen;

    return Scaffold(
      appBar: AppBar(
        title: Text('Pelacak Keuangan Pribadi'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              bool success = await authProvider.logout();
              if (success) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: currentScreen,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: menuItems.map((item) =>
          BottomNavigationBarItem(
            icon: Icon(item.icon),
            label: item.title,
          ),
        ).toList(),
      ),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Load initial data when the screen is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
    final savingProvider = Provider.of<SavingProvider>(context, listen: false);
    final financialSummaryProvider = Provider.of<FinancialSummaryProvider>(context, listen: false);

    // Muat data secara paralel untuk efisiensi
    await Future.wait([
      transactionProvider.fetchTransactions(forceRefresh: false), // Gunakan cache jika tersedia
      savingProvider.fetchSavings(forceRefresh: false), // Gunakan cache jika tersedia
      financialSummaryProvider.getMonthlyFinancialData(DateTime.now().year), // Load financial summary
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final financialSummaryProvider = Provider.of<FinancialSummaryProvider>(context);

    // Get dynamic values using getters
    double totalIncome = transactionProvider.totalIncome;
    double totalExpense = transactionProvider.totalExpense;
    double balance = transactionProvider.balance;

    // Get financial summary data if available
    double monthlyIncome = 0;
    double monthlyExpense = 0;
    double monthlyNetTotal = 0;
    double monthlyTotalSaving = 0;

    if (financialSummaryProvider.currentMonthSummary != null) {
      monthlyIncome = financialSummaryProvider.currentMonthSummary!.totalIncome;
      monthlyExpense = financialSummaryProvider.currentMonthSummary!.totalExpense;
      monthlyNetTotal = financialSummaryProvider.currentMonthSummary!.netTotal;
      monthlyTotalSaving = financialSummaryProvider.currentMonthSummary!.totalSaving;
    }

    // Get 3 most recent transactions
    var recentTransactions = transactionProvider.transactions.length > 3
        ? transactionProvider.transactions.take(3).toList()
        : transactionProvider.transactions;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome message
            Text(
              'Selamat datang kembali!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Berikut ringkasan keuangan Anda',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),

            // Summary cards with dynamic data - Using ConstrainedBox to prevent overflow
            _buildSummaryCards(
              context,
              incomeAmount: monthlyIncome.toStringAsFixed(0),
              expenseAmount: monthlyExpense.toStringAsFixed(0),
              savingAmount: monthlyTotalSaving.toStringAsFixed(0),
              netTotalAmount: monthlyNetTotal.toStringAsFixed(0),
              netTotalColor: monthlyNetTotal >= 0 ? Colors.green : Colors.red,
              netTotalBgColor: monthlyNetTotal >= 0 ? const Color(0xFFe8f5e9) : const Color(0xFFffebee),
              netTotalIconColor: monthlyNetTotal >= 0 ? const Color(0xFFa5d6a7) : const Color(0xFFef9a9a),
            ),
            const SizedBox(height: 24),

            // Financial Summary Overview Card
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Ringkasan Keuangan',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const FinancialSummaryScreen(),
                            ),
                          );
                        },
                        child: const Text('Lihat Detail'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (financialSummaryProvider.currentMonthSummary != null)
                    Text(
                      'Bulan ini: Pemasukan Rp${monthlyIncome.toStringAsFixed(0)} | Pengeluaran Rp${monthlyExpense.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      overflow: TextOverflow.ellipsis,
                    )
                  else
                    const Text(
                      'Memuat data...',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  if (financialSummaryProvider.nextMonthSummary != null)
                    Text(
                      'Bulan depan: Tabungan Rp${financialSummaryProvider.nextMonthSummary!.totalSaving.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),

            // Monthly Comparison Chart
            if (financialSummaryProvider.monthlyData != null &&
                financialSummaryProvider.monthlyData!.isNotEmpty)
              Container(
                width: double.infinity,
                height: 300, // Tetapkan tinggi tetap untuk mencegah overflow
                child: MonthlyComparisonChart(
                  financialData: financialSummaryProvider.monthlyData!,
                  currentYear: DateTime.now().year,
                  showYearComparison: false, // Default tampilkan mode bulanan
                ),
              )
            else
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Text(
                  'Memuat grafik keuangan...',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ),

            // Recent transactions header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Transaksi Terbaru',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to transactions screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TransactionListScreen(),
                      ),
                    );
                  },
                  child: const Text('Lihat Semua'),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Dynamic recent transactions list
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: transactionProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : recentTransactions.isEmpty
                      ? const Center(
                          child: Text('Belum ada transaksi'),
                        )
                      : Column(
                          children: [
                            ...recentTransactions.map((transaction) =>
                              Column(
                                children: [
                                  ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: transaction.type == 'income'
                                          ? Colors.green
                                          : Colors.red,
                                      child: Icon(
                                        transaction.type == 'income'
                                            ? Icons.work
                                            : Icons.shopping_basket,
                                        color: Colors.white,
                                      ),
                                    ),
                                    title: Text(
                                      transaction.description ?? 'Tidak ada deskripsi',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    subtitle: Text(
                                      transaction.category?.name ?? 'Tanpa Kategori',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    trailing: Text(
                                      transaction.type == 'income'
                                          ? '+Rp${transaction.amount}'
                                          : '-Rp${transaction.amount}',
                                      style: TextStyle(
                                        color: transaction.type == 'income'
                                            ? Colors.green
                                            : Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const Divider(),
                                ],
                              ),
                            ),
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String amount,
    required IconData icon,
    required Color color,
    required Color bgColor,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Rp$amount',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          const Text(
            'Bulan ini',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(
    BuildContext context, {
    required String incomeAmount,
    required String expenseAmount,
    required String savingAmount,
    required String netTotalAmount,
    required Color netTotalColor,
    required Color netTotalBgColor,
    required Color netTotalIconColor,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Jika lebar layar cukup, tampilkan dalam 2 baris dengan 2 kolom masing-masing
        // Jika tidak, tampilkan dalam 4 baris dengan 1 kolom
        if (constraints.maxWidth > 600) {
          // Tampilkan dalam 2 baris x 2 kolom untuk layar yang cukup lebar
          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      title: 'Pemasukan',
                      amount: incomeAmount,
                      icon: Icons.arrow_upward,
                      color: Colors.green,
                      bgColor: const Color(0xFFe8f5e9),
                      iconColor: const Color(0xFFa5d6a7),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSummaryCard(
                      title: 'Pengeluaran',
                      amount: expenseAmount,
                      icon: Icons.arrow_downward,
                      color: Colors.red,
                      bgColor: const Color(0xFFffebee),
                      iconColor: const Color(0xFFef9a9a),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      title: 'Tabungan',
                      amount: savingAmount,
                      icon: Icons.savings,
                      color: Colors.blue,
                      bgColor: const Color(0xFFe3f2fd),
                      iconColor: const Color(0xFF90caf9),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSummaryCard(
                      title: 'Saldo Bulan Ini',
                      amount: netTotalAmount,
                      icon: Icons.account_balance_wallet,
                      color: netTotalColor,
                      bgColor: netTotalBgColor,
                      iconColor: netTotalIconColor,
                    ),
                  ),
                ],
              ),
            ],
          );
        } else {
          // Tampilkan dalam 4 baris x 1 kolom untuk layar sempit
          return Column(
            children: [
              _buildSummaryCard(
                title: 'Pemasukan',
                amount: incomeAmount,
                icon: Icons.arrow_upward,
                color: Colors.green,
                bgColor: const Color(0xFFe8f5e9),
                iconColor: const Color(0xFFa5d6a7),
              ),
              const SizedBox(height: 16),
              _buildSummaryCard(
                title: 'Pengeluaran',
                amount: expenseAmount,
                icon: Icons.arrow_downward,
                color: Colors.red,
                bgColor: const Color(0xFFffebee),
                iconColor: const Color(0xFFef9a9a),
              ),
              const SizedBox(height: 16),
              _buildSummaryCard(
                title: 'Tabungan',
                amount: savingAmount,
                icon: Icons.savings,
                color: Colors.blue,
                bgColor: const Color(0xFFe3f2fd),
                iconColor: const Color(0xFF90caf9),
              ),
              const SizedBox(height: 16),
              _buildSummaryCard(
                title: 'Saldo Bulan Ini',
                amount: netTotalAmount,
                icon: Icons.account_balance_wallet,
                color: netTotalColor,
                bgColor: netTotalBgColor,
                iconColor: netTotalIconColor,
              ),
            ],
          );
        }
      },
    );
  }
}

  Widget _buildSummaryCard({
    required String title,
    required String amount,
    required IconData icon,
    required Color color,
    required Color bgColor,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Rp$amount',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          const Text(
            'Bulan ini',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(
    BuildContext context, {
    required String incomeAmount,
    required String expenseAmount,
    required String savingAmount,
    required String netTotalAmount,
    required Color netTotalColor,
    required Color netTotalBgColor,
    required Color netTotalIconColor,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Jika lebar layar cukup, tampilkan dalam 2 baris dengan 2 kolom masing-masing
        // Jika tidak, tampilkan dalam 4 baris dengan 1 kolom
        if (constraints.maxWidth > 600) {
          // Tampilkan dalam 2 baris x 2 kolom untuk layar yang cukup lebar
          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      title: 'Pemasukan',
                      amount: incomeAmount,
                      icon: Icons.arrow_upward,
                      color: Colors.green,
                      bgColor: const Color(0xFFe8f5e9),
                      iconColor: const Color(0xFFa5d6a7),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSummaryCard(
                      title: 'Pengeluaran',
                      amount: expenseAmount,
                      icon: Icons.arrow_downward,
                      color: Colors.red,
                      bgColor: const Color(0xFFffebee),
                      iconColor: const Color(0xFFef9a9a),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      title: 'Tabungan',
                      amount: savingAmount,
                      icon: Icons.savings,
                      color: Colors.blue,
                      bgColor: const Color(0xFFe3f2fd),
                      iconColor: const Color(0xFF90caf9),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSummaryCard(
                      title: 'Saldo Bulan Ini',
                      amount: netTotalAmount,
                      icon: Icons.account_balance_wallet,
                      color: netTotalColor,
                      bgColor: netTotalBgColor,
                      iconColor: netTotalIconColor,
                    ),
                  ),
                ],
              ),
            ],
          );
        } else {
          // Tampilkan dalam 4 baris x 1 kolom untuk layar sempit
          return Column(
            children: [
              _buildSummaryCard(
                title: 'Pemasukan',
                amount: incomeAmount,
                icon: Icons.arrow_upward,
                color: Colors.green,
                bgColor: const Color(0xFFe8f5e9),
                iconColor: const Color(0xFFa5d6a7),
              ),
              const SizedBox(height: 16),
              _buildSummaryCard(
                title: 'Pengeluaran',
                amount: expenseAmount,
                icon: Icons.arrow_downward,
                color: Colors.red,
                bgColor: const Color(0xFFffebee),
                iconColor: const Color(0xFFef9a9a),
              ),
              const SizedBox(height: 16),
              _buildSummaryCard(
                title: 'Tabungan',
                amount: savingAmount,
                icon: Icons.savings,
                color: Colors.blue,
                bgColor: const Color(0xFFe3f2fd),
                iconColor: const Color(0xFF90caf9),
              ),
              const SizedBox(height: 16),
              _buildSummaryCard(
                title: 'Saldo Bulan Ini',
                amount: netTotalAmount,
                icon: Icons.account_balance_wallet,
                color: netTotalColor,
                bgColor: netTotalBgColor,
                iconColor: netTotalIconColor,
              ),
            ],
          );
        }
      },
    );
  }
