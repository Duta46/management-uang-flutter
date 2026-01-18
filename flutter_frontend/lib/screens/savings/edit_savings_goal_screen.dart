import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_frontend/models/savings_goal.dart';
import 'package:flutter_frontend/providers/savings_goal_provider.dart';
import 'package:flutter_frontend/theme/app_theme.dart';

class EditSavingsGoalScreen extends StatefulWidget {
  final SavingsGoal savingsGoal;

  const EditSavingsGoalScreen({Key? key, required this.savingsGoal}) : super(key: key);

  @override
  State<EditSavingsGoalScreen> createState() => _EditSavingsGoalScreenState();
}

class _EditSavingsGoalScreenState extends State<EditSavingsGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _targetAmountController;
  DateTime? _targetDate;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing savings goal data
    _nameController = TextEditingController(text: widget.savingsGoal.name);
    _descriptionController = TextEditingController(
      text: widget.savingsGoal.description ?? '',
    );
    _targetAmountController = TextEditingController(
      text: double.tryParse(widget.savingsGoal.targetAmount)?.toString() ?? '',
    );
    _targetDate = DateTime.tryParse(widget.savingsGoal.targetDate);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _targetAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final savingsGoalProvider = Provider.of<SavingsGoalProvider>(context);

    return Scaffold(
      body: Container(
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
        child: SafeArea(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Edit Target Tabungan',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.grey.shade300,
                            ),
                          ),
                          child: TextFormField(
                            controller: _nameController,
                            style: const TextStyle(color: Colors.black),
                            decoration: const InputDecoration(
                              labelText: 'Nama Target Tabungan',
                              labelStyle: TextStyle(color: Colors.black87),
                              hintText: 'Contoh: Liburan ke Bali',
                              hintStyle: TextStyle(color: Colors.grey),
                              prefixIcon: Icon(Icons.savings, color: Colors.grey),
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Nama target tabungan wajib diisi';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.grey.shade300,
                            ),
                          ),
                          child: TextFormField(
                            controller: _descriptionController,
                            style: const TextStyle(color: Colors.black),
                            decoration: const InputDecoration(
                              labelText: 'Deskripsi',
                              labelStyle: TextStyle(color: Colors.black87),
                              hintText: 'Deskripsi tambahan (opsional)',
                              hintStyle: TextStyle(color: Colors.grey),
                              prefixIcon: Icon(Icons.description, color: Colors.grey),
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                            ),
                            maxLines: 3,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.grey.shade300,
                            ),
                          ),
                          child: TextFormField(
                            controller: _targetAmountController,
                            style: const TextStyle(color: Colors.black),
                            decoration: const InputDecoration(
                              labelText: 'Jumlah Target',
                              labelStyle: TextStyle(color: Colors.black87),
                              hintText: 'Rp',
                              hintStyle: TextStyle(color: Colors.grey),
                              prefixIcon: Icon(Icons.attach_money, color: Colors.grey),
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Jumlah target wajib diisi';
                              }
                              final amount = double.tryParse(value);
                              if (amount == null || amount <= 0) {
                                return 'Masukkan jumlah yang valid';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.grey.shade300,
                            ),
                          ),
                          child: ListTile(
                            title: Text(
                              _targetDate != null
                                  ? 'Tanggal Target: ${_formatDate(_targetDate!)}'
                                  : 'Pilih Tanggal Target',
                              style: TextStyle(
                                color: _targetDate != null
                                    ? Colors.black87
                                    : Colors.grey,
                              ),
                            ),
                            trailing: const Icon(Icons.calendar_today, color: Colors.grey),
                            onTap: _selectTargetDate,
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: savingsGoalProvider.isLoading
                                ? null
                                : _submitForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF764ba2),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: savingsGoalProvider.isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text('Perbarui Target Tabungan'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _selectTargetDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _targetDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _targetDate) {
      setState(() {
        _targetDate = picked;
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && _targetDate != null) {
      final success = await Provider.of<SavingsGoalProvider>(context, listen: false)
          .updateSavingsGoal(
        id: widget.savingsGoal.id!,
        name: _nameController.text.trim(),
        targetAmount: double.parse(_targetAmountController.text),
        targetDate: _targetDate!,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
      );

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Target tabungan berhasil diperbarui'),
              backgroundColor: AppTheme.incomeColor,
            ),
          );
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                Provider.of<SavingsGoalProvider>(context, listen: false).message,
              ),
              backgroundColor: AppTheme.expenseColor,
            ),
          );
        }
      }
    } else if (_targetDate == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tanggal target wajib dipilih'),
            backgroundColor: AppTheme.expenseColor,
          ),
        );
      }
    }
  }
}