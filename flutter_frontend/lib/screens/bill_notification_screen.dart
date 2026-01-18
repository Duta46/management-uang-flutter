import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider_change_notifier.dart';
import '../repositories/api_repository.dart';
import '../models/api_response.dart' as Response;
import '../theme/app_theme.dart';
import '../providers/global_providers.dart';

class BillNotification {
  final int id;
  final String title;
  final String message;
  final String dueDate;
  final double amount;
  final String name;
  final String type;
  final String priority;
  final DateTime createdAt;
  bool isRead; // Tambahkan properti untuk status dibaca

  BillNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.dueDate,
    required this.amount,
    required this.name,
    required this.type,
    required this.priority,
    required this.createdAt,
    this.isRead = false, // Default belum dibaca
  });

  factory BillNotification.fromJson(Map<String, dynamic> json) {
    return BillNotification(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Tagihan',
      message: json['message'] ?? 'Deskripsi tagihan',
      dueDate: json['due_date'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      name: json['name'] ?? 'Tagihan',
      type: json['type'] ?? 'bill_reminder',
      priority: json['priority'] ?? 'low',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  // Fungsi untuk menandai notifikasi sebagai dibaca
  void markAsRead() {
    isRead = true;
  }
}

class BillNotificationProvider extends ChangeNotifier {
  final ApiRepository _apiRepository = sharedApiRepository;
  List<BillNotification> _notifications = [];
  bool _isLoading = false;
  String _message = '';

  List<BillNotification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String get message => _message;

  Future<void> fetchBillNotifications({int daysAhead = 7}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiRepository.getBillNotifications(daysAhead: daysAhead);
      
      if (response.success && response.data != null) {
        final List<dynamic> notificationList = response.data['notifications'] ?? [];
        _notifications = notificationList
            .map((json) => BillNotification.fromJson(json))
            .toList();
        _message = response.message ?? 'Notifikasi tagihan berhasil diambil';
      } else {
        _notifications = [];
        _message = response.message ?? 'Gagal mengambil notifikasi tagihan';
      }
    } catch (e) {
      _notifications = [];
      _message = 'Terjadi kesalahan: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  int get upcomingCount {
    return _notifications.where((notification) => notification.type == 'bill_reminder').length;
  }

  int get overdueCount {
    return _notifications.where((notification) => notification.type == 'bill_reminder_overdue').length;
  }

  int get totalCount {
    return _notifications.length;
  }
}

class BillNotificationScreen extends StatefulWidget {
  const BillNotificationScreen({Key? key}) : super(key: key);

  @override
  State<BillNotificationScreen> createState() => _BillNotificationScreenState();
}

class _BillNotificationScreenState extends State<BillNotificationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BillNotificationProvider>(context, listen: false)
          .fetchBillNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF667eea), // Biru keunguan
            Color(0xFF764ba2), // Ungu
            Color(0xFFc3a1d9), // Ungu lembut
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'Notifikasi Tagihan',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          iconTheme: const IconThemeData(
            color: Colors.white,
          ),
        ),
        body: Consumer<BillNotificationProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (provider.notifications.isEmpty) {
              return Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_none,
                        size: 60,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Tidak Ada Notifikasi',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Anda tidak memiliki notifikasi tagihan saat ini',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => provider.fetchBillNotifications(),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: provider.notifications.length,
                itemBuilder: (context, index) {
                  final notification = provider.notifications[index];
                  return _buildNotificationCard(notification);
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildNotificationCard(BillNotification notification) {
    Color priorityColor;
    switch (notification.priority) {
      case 'high':
        priorityColor = AppTheme.expenseColor;
        break;
      case 'medium':
        priorityColor = Colors.orange;
        break;
      default:
        priorityColor = AppTheme.incomeColor;
        break;
    }

    IconData iconData;
    switch (notification.type) {
      case 'bill_reminder_overdue':
        iconData = Icons.warning_amber_rounded;
        break;
      case 'bill_reminder':
        iconData = Icons.notifications_active_rounded;
        break;
      default:
        iconData = Icons.receipt_long_rounded;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
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
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: priorityColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            iconData,
            color: priorityColor,
          ),
        ),
        title: Text(
          notification.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              notification.message,
              style: const TextStyle(
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Jatuh Tempo: ${_formatDate(notification.dueDate)}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Rp ${_formatCurrency(notification.amount)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: priorityColor,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: priorityColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                notification.type == 'bill_reminder_overdue' ? 'TERLAMBAT' : 'MENDEKAT',
                style: TextStyle(
                  fontSize: 10,
                  color: priorityColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  String _formatCurrency(double amount) {
    return amount
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
  }
}