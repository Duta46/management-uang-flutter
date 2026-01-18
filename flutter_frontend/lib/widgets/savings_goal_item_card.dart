import 'package:flutter/material.dart';
import 'package:flutter_frontend/models/savings_goal.dart';
import 'package:flutter_frontend/services/api_service.dart';

class SavingsGoalItemCard extends StatefulWidget {
  final SavingsGoal savingsGoal;
  final VoidCallback onRefresh;

  const SavingsGoalItemCard({
    Key? key,
    required this.savingsGoal,
    required this.onRefresh,
  }) : super(key: key);

  @override
  State<SavingsGoalItemCard> createState() => _SavingsGoalItemCardState();
}

class _SavingsGoalItemCardState extends State<SavingsGoalItemCard> {
  final ApiService _apiService = ApiService();
  bool _isDeleting = false;

  Future<void> _deleteSavingsGoal() async {
    setState(() {
      _isDeleting = true;
    });

    try {
      final response = await _apiService.deleteSavingsGoal(widget.savingsGoal.id!);
      if (response.success) {
        widget.onRefresh();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Target tabungan berhasil dihapus')),
        );
      } else {
        setState(() {
          _isDeleting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus target tabungan: ${response.message}')),
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
    // Calculate progress percentage
    double targetAmount = double.tryParse(widget.savingsGoal.targetAmount) ?? 0;
    double currentAmount = double.tryParse(widget.savingsGoal.currentAmount) ?? 0;
    double progress = targetAmount > 0 ? (currentAmount / targetAmount) * 100 : 0;

    Color progressColor;
    if (progress >= 100) {
      progressColor = Colors.green;
    } else if (progress >= 80) {
      progressColor = Colors.blue;
    } else {
      progressColor = Colors.orange;
    }

    // Calculate days remaining
    DateTime targetDate = DateTime.parse(widget.savingsGoal.targetDate);
    int daysRemaining = targetDate.difference(DateTime.now()).inDays;

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
                    widget.savingsGoal.name,
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
                        '/edit-savings-goal',
                        arguments: widget.savingsGoal,
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
            if (widget.savingsGoal.description != null && widget.savingsGoal.description!.isNotEmpty)
              Text(
                widget.savingsGoal.description!,
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
                      'Rp ${targetAmount.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Target',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Rp ${currentAmount.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Terkumpul',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            LinearProgressIndicator(
              value: progress / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
            const SizedBox(height: 4.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${progress.toStringAsFixed(1)}% dari target',
                  style: TextStyle(color: progressColor),
                ),
                Text(
                  '$daysRemaining hari lagi',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
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
      ),
    );
  }

  Color _getStatusColor() {
    switch (widget.savingsGoal.status) {
      case 'achieved':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  String _getStatusText() {
    switch (widget.savingsGoal.status) {
      case 'achieved':
        return 'Tercapai';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return 'Aktif';
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: Text('Apakah Anda yakin ingin menghapus target tabungan "${widget.savingsGoal.name}"?'),
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
                _deleteSavingsGoal();
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