import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/transaction.dart';
import 'package:flutter_frontend/providers/transaction_provider_change_notifier.dart';
import 'package:flutter_frontend/providers/category_provider_change_notifier.dart';
import 'package:flutter_frontend/theme/app_theme.dart';
import '../../services/profile_service.dart';
import '../../models/user.dart';

class TransactionFormScreen extends StatefulWidget {
  final Transaction? transaction; // Pass existing transaction for editing

  const TransactionFormScreen({Key? key, this.transaction}) : super(key: key);

  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dateController = TextEditingController();

  String? _selectedCategory;
  String _selectedType = 'expense';
  DateTime _selectedDate = DateTime.now();

  // Auto-save related variables
  bool _autoSavePercentageEnabled = false;
  double _autoSavePercentage = 0.0;
  bool _autoSaveFixedAmountEnabled = false;
  double _autoSaveFixedAmount = 0.0;
  int? _selectedPercentageSavingId;
  int? _selectedFixedAmountSavingId;

  @override
  void initState() {
    super.initState();

    if (widget.transaction != null) {
      // Editing existing transaction
      _amountController.text = widget.transaction!.amount.toString();
      _descriptionController.text = widget.transaction!.description ?? '';

      if (widget.transaction!.date != null) {
        _selectedDate = widget.transaction!.date!;
        _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate);
      }

      _selectedType = widget.transaction!.type;
      _selectedCategory = widget.transaction!.category?.id.toString();
    } else {
      // New transaction
      _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.transaction != null ? 'Edit Transaksi' : 'Tambah Transaksi',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Consumer2<TransactionProvider, CategoryProvider>(
          builder: (context, transactionProvider, categoryProvider, child) {
            if (categoryProvider.categories.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            return Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Type selection
                    Container(
                      padding: const EdgeInsets.all(16),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Jenis Transaksi',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textColor,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedType = 'expense';
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: _selectedType == 'expense'
                                        ? AppTheme.expenseLightColor
                                        : Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: _selectedType == 'expense'
                                          ? AppTheme.expenseColor
                                          : Colors.grey.shade300,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.money_off,
                                          color: _selectedType == 'expense'
                                            ? AppTheme.expenseColor
                                            : Colors.grey,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Pengeluaran',
                                          style: TextStyle(
                                            fontWeight: _selectedType == 'expense'
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                            color: _selectedType == 'expense'
                                              ? AppTheme.expenseColor
                                              : Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedType = 'income';
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: _selectedType == 'income'
                                        ? AppTheme.incomeLightColor
                                        : Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: _selectedType == 'income'
                                          ? AppTheme.incomeColor
                                          : Colors.grey.shade300,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.attach_money,
                                          color: _selectedType == 'income'
                                            ? AppTheme.incomeColor
                                            : Colors.grey,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Pemasukan',
                                          style: TextStyle(
                                            fontWeight: _selectedType == 'income'
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                            color: _selectedType == 'income'
                                              ? AppTheme.incomeColor
                                              : Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Category selection
                    Container(
                      padding: const EdgeInsets.all(16),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Kategori',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: _selectedCategory,
                              hint: const Text('Pilih kategori'),
                              underline: Container(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedCategory = newValue;
                                });
                              },
                              items: categoryProvider.categories
                                  .map<DropdownMenuItem<String>>((cat) {
                                return DropdownMenuItem<String>(
                                  value: cat.id.toString(),
                                  child: Text(cat.name),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Amount input
                    Container(
                      padding: const EdgeInsets.all(16),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Jumlah',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _amountController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(
                              hintText: 'Masukkan jumlah',
                              prefixIcon: Icon(Icons.currency_rupee),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(8)),
                              ),
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Harap masukkan jumlah';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Harap masukkan angka yang valid';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Date input
                    Container(
                      padding: const EdgeInsets.all(16),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tanggal',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _dateController,
                            readOnly: true,
                            decoration: const InputDecoration(
                              hintText: 'Pilih tanggal',
                              prefixIcon: Icon(Icons.calendar_today),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(8)),
                              ),
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            ),
                            onTap: () async {
                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: _selectedDate,
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2101),
                              );
                              if (pickedDate != null) {
                                setState(() {
                                  _selectedDate = pickedDate;
                                  _dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Description input
                    Container(
                      padding: const EdgeInsets.all(16),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Deskripsi',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _descriptionController,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              hintText: 'Tambahkan deskripsi (opsional)',
                              prefixIcon: Icon(Icons.description),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(8)),
                              ),
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Save button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate() && _selectedCategory != null) {
                            // Update user profile with auto-save settings and saving IDs if this is an income transaction
                            if (_selectedType == 'income') {
                              await ProfileService.updateAutoSaveSettings(
                                autoSavePercentage: _autoSavePercentageEnabled ? _autoSavePercentage : 0,
                                autoSaveFixedAmount: _autoSaveFixedAmountEnabled ? _autoSaveFixedAmount : 0,
                                autoSavePercentageSavingId: _selectedPercentageSavingId,
                                autoSaveFixedAmountSavingId: _selectedFixedAmountSavingId,
                              );
                            }

                            if (widget.transaction != null) {
                              // Update existing transaction
                              bool success = await transactionProvider.updateTransaction(
                                widget.transaction!.id!,
                                int.parse(_selectedCategory!),
                                _amountController.text,
                                _selectedType,
                                _descriptionController.text,
                                _dateController.text,
                              );

                              if (success) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Transaksi berhasil diperbarui'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(transactionProvider.message),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            } else {
                              // Create new transaction
                              bool success = await transactionProvider.createTransactionSimple(
                                int.parse(_selectedCategory!),
                                _amountController.text,
                                _selectedType,
                                _descriptionController.text,
                                _dateController.text,
                              );

                              if (success) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Transaksi berhasil ditambahkan'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(transactionProvider.message),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Harap isi semua bidang yang diperlukan'),
                                backgroundColor: Colors.orange,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          widget.transaction != null ? 'Perbarui Transaksi' : 'Tambah Transaksi',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    super.dispose();
  }
}