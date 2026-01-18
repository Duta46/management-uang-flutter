import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_frontend/models/bill_reminder.dart';
import 'package:flutter_frontend/providers/bill_reminder_provider.dart';
import 'package:flutter_frontend/widgets/bill_reminder_item_card.dart';

class BillReminderScreen extends StatefulWidget {
  const BillReminderScreen({Key? key}) : super(key: key);

  @override
  State<BillReminderScreen> createState() => _BillReminderScreenState();
}

class _BillReminderScreenState extends State<BillReminderScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BillReminderProvider>(context, listen: false).fetchBillReminders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final billReminderProvider = Provider.of<BillReminderProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardTheme.color,
        foregroundColor: Theme.of(context).textTheme.titleLarge?.color,
        elevation: 0,
        title: const Text('Pengingat Tagihan'),
        iconTheme: IconThemeData(
          color: Theme.of(context).textTheme.titleLarge?.color,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, '/add-bill-reminder');
            },
          ),
        ],
      ),
      body: billReminderProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => billReminderProvider.fetchBillReminders(),
              child: billReminderProvider.billReminders.isEmpty
                  ? Center(
                      child: Container(
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(24),
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
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Ikon pengingat tagihan di tengah
                            Icon(
                              Icons.notifications_active_outlined,
                              size: 60,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(height: 16),
                            // Teks utama: "Belum Ada Pengingat Tagihan"
                            Text(
                              'Belum Ada Pengingat Tagihan',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).textTheme.titleLarge?.color,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            // Teks deskripsi lebih kecil di bawahnya
                            Text(
                              'Pengingat tagihan akan muncul di sini setelah Anda menambahkannya',
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).textTheme.bodyMedium?.color,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: billReminderProvider.billReminders.length,
                      itemBuilder: (context, index) {
                        return BillReminderItemCard(
                          billReminder: billReminderProvider.billReminders[index],
                          onRefresh: () => billReminderProvider.fetchBillReminders(),
                        );
                      },
                    ),
            ),
    );
  }
}