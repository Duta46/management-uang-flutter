import 'package:flutter/foundation.dart';
import '../repositories/api_repository.dart';
import '../models/api_response.dart' as Response;
import '../screens/bill_notification_screen.dart';
import 'global_providers.dart';

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

  int get unreadCount {
    return _notifications.where((notification) => !notification.isRead).length;
  }

  void markAllAsRead() {
    for (var notification in _notifications) {
      notification.markAsRead();
    }
    notifyListeners();
  }

  void markAsRead(int index) {
    if (index >= 0 && index < _notifications.length) {
      _notifications[index].markAsRead();
      notifyListeners();
    }
  }
}