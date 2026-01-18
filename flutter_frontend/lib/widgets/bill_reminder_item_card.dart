import 'package:flutter/material.dart';
import 'package:flutter_frontend/models/bill_reminder.dart';
import 'package:flutter_frontend/services/api_service.dart';

class BillReminderItemCard extends StatefulWidget {
  final BillReminder billReminder;
  final VoidCallback onRefresh;

  const BillReminderItemCard({
    Key? key,
    required this.billReminder,
    required this.onRefresh,
  }) : super(key: key);

  @override
  State<BillReminderItemCard> createState() => _BillReminderItemCardState();
}

class _BillReminderItemCardState extends State<BillReminderItemCard> {
  final ApiService _apiService = ApiService();
  bool _isDeleting = false;

  Future<void> _deleteBillReminder() async {
    setState(() {
      _isDeleting = true;
    });

    try {
      final response = await _apiService.deleteBillReminder(widget.billReminder.id!);
      if (response.success) {
        widget.onRefresh();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pengingat tagihan berhasil dihapus')),
        );
      } else {
        setState(() {
          _isDeleting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus pengingat tagihan: ${response.message}')),
        );
      }
    } catch (e) {
      setState(() {
        _isDeleting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate days until due
    DateTime dueDate = DateTime.parse(widget.billReminder.dueDate);
    int daysUntilDue = dueDate.difference(DateTime.now()).inDays;

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.billReminder.name,
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (String value) {
                    if (value == 'edit') {
                      Navigator.pushNamed(
                        context,
                        '/edit-bill-reminder',
                        arguments: widget.billReminder,
                      );
                    } else if (value == 'delete') {
                      _showDeleteConfirmation();
                    }
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'edit',
                      child: Text('Edit'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Text('Hapus'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            if (widget.billReminder.description != null && widget.billReminder.description!.isNotEmpty)
              Text(
                widget.billReminder.description!,
                style: const TextStyle(color: Colors.grey),
              ),
            const SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rp ${double.parse(widget.billReminder.amount).toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Jatuh tempo: ${dueDate.day}/${dueDate.month}/${dueDate.year}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: _getStatusColor(),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Text(
                    _getStatusText(),
                    style: const TextStyle(color: Colors.white, fontSize: 12.0),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Frekuensi: ${_getFrequencyText()}',
                  style: const TextStyle(color: Colors.grey),
                ),
                Text(
                  '$daysUntilDue hari lagi',
                  style: TextStyle(
                    color: daysUntilDue <= 0 ? Colors.red : Colors.grey,
                    fontWeight: daysUntilDue <= 0 ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor() {
    if (widget.billReminder.isPaid) {
      return Colors.green;
    } else if (DateTime.parse(widget.billReminder.dueDate).isBefore(DateTime.now())) {
      return Colors.red;
    } else if (DateTime.parse(widget.billReminder.dueDate).difference(DateTime.now()).inDays <= 3) {
      return Colors.orange;
    } else {
      return Colors.blue;
    }
  }

  String _getStatusText() {
    if (widget.billReminder.isPaid) {
      return 'Lunas';
    } else if (DateTime.parse(widget.billReminder.dueDate).isBefore(DateTime.now())) {
      return 'Terlambat';
    } else if (DateTime.parse(widget.billReminder.dueDate).difference(DateTime.now()).inDays <= 3) {
      return 'Segera Jatuh Tempo';
    } else {
      return 'Aktif';
    }
  }

  String _getFrequencyText() {
    switch (widget.billReminder.frequency) {
      case 'monthly':
        return 'Bulanan';
      case 'weekly':
        return 'Mingguan';
      case 'yearly':
        return 'Tahunan';
      case 'one_time':
        return 'Satu Kali';
      default:
        return widget.billReminder.frequency;
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: Text('Apakah Anda yakin ingin menghapus pengingat tagihan "${widget.billReminder.name}"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteBillReminder();
              },
              child: _isDeleting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }
}