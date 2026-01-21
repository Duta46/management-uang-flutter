import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider_change_notifier.dart';
import '../screens/home/daily_transaction_screen.dart';
import '../screens/home/monthly_finance_screen.dart';
import '../screens/home/financial_dashboard_screen.dart';
import '../screens/coming_soon_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/savings/savings_goal_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({Key? key}) : super(key: key);

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 2; // Inisialisasi ke indeks 2 (FinancialDashboardScreen) sebagai halaman beranda

  final List<Widget> _pages = [
    const DailyTransactionScreen(),
    const MonthlyFinanceScreen(),
    const FinancialDashboardScreen(),
    const ComingSoonScreen(featureName: 'Analyst AI', description: 'Fitur ini akan memberikan analisis mendalam, rekomendasi, dan prediksi keuangan menggunakan teknologi AI.'),
    const ProfileScreen(),
  ];

  final List<String> _titles = [
    'Transaksi Harian',
    'Keuangan Bulanan',
    'Dashboard',
    'Analyst AI',
    'Profil',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6.0,
        child: SizedBox(
          height: 56, // Reduced height
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBottomNavItem(0, Icons.calendar_today, 'Harian'),
              _buildBottomNavItem(1, Icons.bar_chart, 'Bulanan'),
              const SizedBox(width: 10), // Spacer for the floating action button
              _buildBottomNavItem(3, Icons.psychology, 'AI'),
              _buildBottomNavItem(4, Icons.person, 'Profil'),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _selectedIndex = 2; // Index for dashboard (already the default)
          });
        },
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.home, color: Colors.white),
        elevation: 4.0,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildBottomNavItem(int index, IconData icon, String label) {
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8), // Reduced padding
        decoration: BoxDecoration(
          color: _selectedIndex == index
              ? Theme.of(context).primaryColor.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20, // Explicitly set icon size
              color: _selectedIndex == index
                  ? Theme.of(context).primaryColor
                  : Colors.grey,
            ),
            const SizedBox(height: 2), // Reduced space
            Text(
              label,
              style: TextStyle(
                fontSize: 9, // Reduced font size
                color: _selectedIndex == index
                    ? Theme.of(context).primaryColor
                    : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}