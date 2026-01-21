import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../../config/api_config.dart';
import '../../providers/auth_provider_change_notifier.dart';
import '../../providers/transaction_provider_change_notifier.dart';
import '../../providers/bill_notification_provider.dart';
import '../../services/api_service.dart';
import '../../services/data_service.dart';
import '../auth/login_screen.dart';
import '../bill_notification_screen.dart' hide BillNotificationProvider;
import '../../widgets/notification_dropdown.dart';

class FinancialDashboardScreen extends StatefulWidget {
  const FinancialDashboardScreen({Key? key}) : super(key: key);

  @override
  State<FinancialDashboardScreen> createState() => _FinancialDashboardScreenState();
}

class _FinancialDashboardScreenState extends State<FinancialDashboardScreen> {
  String _formatCurrency(double amount) {
    // Format angka dengan pemisah ribuan menggunakan titik
    String formatted = amount.abs().toStringAsFixed(0);
    RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    formatted = formatted.replaceAllMapped(reg, (Match m) => '${m[1]}.');
    return amount < 0 ? '-$formatted' : formatted;
  }

  Future<void> _selectAndUploadProfilePicture(AuthProvider authProvider) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      try {
        bool success = await authProvider.updateProfileWithPhoto(
          profileImage: image.path,
        );

        if (success) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Foto profil berhasil diperbarui'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(authProvider.message ?? 'Gagal memperbarui foto profil'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Consumer<TransactionProvider>(
          builder: (context, transactionProvider, child) {
            return Consumer<BillNotificationProvider>(
              builder: (context, billNotificationProvider, child) {
                return Scaffold(
                  backgroundColor: Theme.of(context).colorScheme.background,
                  appBar: AppBar(
                    backgroundColor: Theme.of(context).cardTheme.color,
                    foregroundColor: Theme.of(context).textTheme.titleLarge?.color,
                    elevation: 0,
                    title: const Text(
                      'Beranda',
                    ),
                    iconTheme: IconThemeData(
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined),
                        onPressed: () {
                          Navigator.pushNamed(context, '/financial-notifications');
                        },
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert),
                        onSelected: (String result) {
                          if (result == 'logout') {
                            _handleLogout(authProvider);
                          } else if (result == 'profile') {
                            _selectAndUploadProfilePicture(authProvider);
                          }
                        },
                        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                          const PopupMenuItem<String>(
                            value: 'profile',
                            child: ListTile(
                              leading: Icon(Icons.person_outline),
                              title: Text('Profil'),
                            ),
                          ),
                          const PopupMenuItem<String>(
                            value: 'logout',
                            child: ListTile(
                              leading: Icon(Icons.logout),
                              title: Text('Keluar'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  body: SafeArea(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        await transactionProvider.fetchDashboardData();
                        await billNotificationProvider.fetchBillNotifications();
                      },
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Profile Section
                              _buildProfileCard(authProvider),
                              
                              // Financial Summary Cards
                              _buildBalanceCard(transactionProvider),

                              // Main Menu Section - Box Style Grid
                              _buildMainMenuSection(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildProfileCard(AuthProvider authProvider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          authProvider.currentUser?.profilePhoto != null
              ? CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(
                    '${ApiConfig.storageBaseUrl}/${authProvider.currentUser!.profilePhoto!}?v=${authProvider.currentUser!.cacheBuster}',
                    scale: 1.0,
                  ),
                  onBackgroundImageError: (exception, stackTrace) {
                    print('Error loading dashboard profile photo: $exception');
                  },
                )
              : CircleAvatar(
                  radius: 30,
                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                  child: Text(
                    authProvider.currentUser?.name != null && authProvider.currentUser!.name.isNotEmpty
                        ? authProvider.currentUser!.name.substring(0, 1).toUpperCase()
                        : 'U',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Halo, ${authProvider.currentUser?.name ?? 'User'}!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700, // Lebih tebal
                  ),
                ),
                Text(
                  authProvider.currentUser?.email ?? '',
                  style: TextStyle(
                    color: Colors.grey[600], // Lebih kontras
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(TransactionProvider transactionProvider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
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
        children: [
          const Text(
            'Saldo Saat Ini',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Rp ${_formatCurrency(transactionProvider.balance)}',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: transactionProvider.balance >= 0
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.error,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                flex: 1,
                child: _buildSummaryCard(
                  'Pemasukan',
                  'Rp ${_formatCurrency(transactionProvider.income)}',
                  Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16), // Add spacing between cards
              Expanded(
                flex: 1,
                child: _buildSummaryCard(
                  'Pengeluaran',
                  'Rp ${_formatCurrency(transactionProvider.expense)}',
                  Theme.of(context).colorScheme.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
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

  Widget _buildMainMenuSection() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
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
          const Text(
            'Menu Utama',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildMenuCard(
                'Transaksi',
                Icons.list_alt,
                const Color(0xFFa8e6cf),
                () {
                  Navigator.pushNamed(context, '/transactions');
                },
              ),
              _buildMenuCard(
                'Anggaran',
                Icons.account_balance_wallet,
                const Color(0xFFdcedc1),
                () {
                },
              ),
              _buildMenuCard(
                'Kategori',
                Icons.category,
                const Color(0xFFf093fb),
                () {
                  Navigator.pushNamed(context, '/categories');
                },
              ),
              _buildMenuCard(
                'Pengingat Tagihan',
                Icons.notifications_active,
                const Color(0xFF4facfe),
                () {
                  Navigator.pushNamed(context, '/bill-reminders');
                },
              ),
              _buildMenuCard(
                'Laporan',
                Icons.bar_chart,
                const Color(0xFF0fd850),
                () {
                  Navigator.pushNamed(context, '/financial-reports');
                },
              ),
              _buildMenuCard(
                'Tabungan',
                Icons.savings,
                const Color(0xFFffd166),
                () {
                  Navigator.pushNamed(context, '/savings-goals');
                },
              ),
              _buildMenuCard(
                'Kesehatan Finansial',
                Icons.health_and_safety,
                const Color(0xFFff9a9e),
                () {
                  Navigator.pushNamed(context, '/financial-health');
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _handleLogout(AuthProvider authProvider) async {
    bool success = await authProvider.logout();

    if (success && mounted) {
      // Navigate back to login screen
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}