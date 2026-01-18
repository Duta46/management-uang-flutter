import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bill_notification_provider.dart';
import '../screens/bill_notification_screen.dart' hide BillNotificationProvider;

class NotificationDropdown extends StatefulWidget {
  const NotificationDropdown({Key? key}) : super(key: key);

  @override
  State<NotificationDropdown> createState() => _NotificationDropdownState();
}

class _NotificationDropdownState extends State<NotificationDropdown> {
  bool _isDropdownVisible = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<BillNotificationProvider>(
      builder: (context, notificationProvider, child) {
        return Stack(
          children: [
            IconButton(
              icon: Icon(
                Icons.notifications,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _isDropdownVisible = !_isDropdownVisible;
                });
                
                // Tandai semua notifikasi sebagai dibaca ketika dropdown dibuka
                if (_isDropdownVisible) {
                  notificationProvider.markAllAsRead();
                }
              },
            ),
            if (notificationProvider.unreadCount > 0)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    '${notificationProvider.unreadCount}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            if (_isDropdownVisible)
              Positioned(
                top: 50,
                right: 0,
                width: 350,
                child: Material(
                  elevation: 8,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Notifikasi Tagihan',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  setState(() {
                                    _isDropdownVisible = false;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: notificationProvider.notifications.isEmpty
                              ? const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Text(
                                    'Tidak ada notifikasi',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontStyle: FontStyle.italic,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: notificationProvider.notifications.length,
                                  itemBuilder: (context, index) {
                                    final notification = notificationProvider.notifications[index];
                                    return ListTile(
                                      leading: Icon(
                                        notification.type == 'bill_reminder_overdue' 
                                            ? Icons.warning_amber_rounded 
                                            : Icons.notifications_active_rounded,
                                        color: notification.type == 'bill_reminder_overdue' 
                                            ? Colors.red 
                                            : Colors.orange,
                                      ),
                                      title: Text(
                                        notification.title,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: notification.isRead ? Colors.grey : Colors.black,
                                        ),
                                      ),
                                      subtitle: Text(
                                        notification.message,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: notification.isRead ? Colors.grey : Colors.black87,
                                        ),
                                      ),
                                      trailing: Text(
                                        'Rp ${_formatCurrency(notification.amount)}',
                                        style: TextStyle(
                                          color: notification.type == 'bill_reminder_overdue' 
                                              ? Colors.red 
                                              : Colors.orange,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      onTap: () {
                                        // Tandai notifikasi ini sebagai dibaca
                                        notificationProvider.markAsRead(index);
                                        
                                        // Arahkan ke halaman detail atau tagihan
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const BillNotificationScreen(),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                        ),
                        if (notificationProvider.notifications.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(12),
                                bottomRight: Radius.circular(12),
                              ),
                            ),
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const BillNotificationScreen(),
                                  ),
                                );
                              },
                              child: const Text('Lihat Semua'),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  String _formatCurrency(double amount) {
    return amount
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
  }
}