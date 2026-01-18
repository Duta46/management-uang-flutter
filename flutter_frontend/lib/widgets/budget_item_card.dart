import 'package:flutter/material.dart';
import 'package:flutter_frontend/models/budget.dart';
import 'package:flutter_frontend/services/api_service.dart';

class BudgetItemCard extends StatefulWidget {
  final Budget budget;
  final VoidCallback onRefresh;

  const BudgetItemCard({
    Key? key,
    required this.budget,
    required this.onRefresh,
  }) : super(key: key);

  @override
  State<BudgetItemCard> createState() => _BudgetItemCardState();
}

class _BudgetItemCardState extends State<BudgetItemCard> {
  final ApiService _apiService = ApiService();
  bool _isDeleting = false;

  Future<void> _deleteBudget() async {
    setState(() {
      _isDeleting = true;
    });

    try {
      final response = await _apiService.deleteBudget(widget.budget.id!);
      if (response.success) {
        widget.onRefresh();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Anggaran berhasil dihapus')),
        );
      } else {
        setState(() {
          _isDeleting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus anggaran: ${response.message}')),
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
    double progress = 0;
    if (widget.budget.amount != '0') {
      double budgetAmount = double.tryParse(widget.budget.amount) ?? 0;
      double spentAmount = double.tryParse(widget.budget.spentAmount ?? '0') ?? 0;
      progress = budgetAmount > 0 ? (spentAmount / budgetAmount) * 100 : 0;
    }

    Color progressColor;
    if (progress >= 100) {
      progressColor = Colors.red;
    } else if (progress >= 80) {
      progressColor = Colors.orange;
    } else {
      progressColor = Colors.green;
    }

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
                    widget.budget.name ?? 'Anggaran',
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
                        '/edit-budget',
                        arguments: widget.budget,
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
            if (widget.budget.category != null)
              Text(
                'Kategori: ${widget.budget.category!.name}',
                style: const TextStyle(color: Colors.grey),
              ),
            Text(
              'Bulan: ${widget.budget.month}',
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
                      'Rp ${double.parse(widget.budget.amount).toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Tersisa: Rp ${(double.parse(widget.budget.amount) - (double.tryParse(widget.budget.spentAmount ?? '0') ?? 0)).toStringAsFixed(0)}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Rp ${(double.tryParse(widget.budget.spentAmount ?? '0') ?? 0).toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Digunakan',
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
            Text(
              '${progress.toStringAsFixed(1)}% dari anggaran',
              style: TextStyle(color: progressColor),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: Text('Apakah Anda yakin ingin menghapus anggaran "${widget.budget.name ?? 'Anggaran'}"?'),
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
                _deleteBudget();
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