import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/category_provider_change_notifier.dart';
import '../../providers/savings_goal_provider.dart';
import '../../providers/bill_reminder_provider.dart';
import '../../providers/transaction_provider_change_notifier.dart';
import '../../models/category.dart';
import '../../models/savings_goal.dart';
import '../../models/bill_reminder.dart';

class TransactionFormScreen extends StatefulWidget {
  final dynamic transaction; // Accept transaction object for editing

  const TransactionFormScreen({Key? key, this.transaction}) : super(key: key);

  @override
  _TransactionFormScreenState createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dateController = TextEditingController();

  String? _selectedType;
  String? _selectedCategory;
  String? _selectedPaymentType;
  String? _selectedSavings;
  String? _selectedBill;

  // Variabel untuk menyimpan data dari API
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _savingsGoals = [];
  List<Map<String, dynamic>> _bills = [];


  @override
  Widget build(BuildContext context) {
    // Muat data bill reminder saat widget pertama kali dibangun
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final billReminderProvider = Provider.of<BillReminderProvider>(context, listen: false);
      if (billReminderProvider.billReminders.isEmpty && !billReminderProvider.isLoading) {
        billReminderProvider.fetchBillReminders();
      }
    });

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardTheme.color,
        foregroundColor: Theme.of(context).textTheme.titleLarge?.color,
        elevation: 0,
        title: Text(
          widget.transaction != null ? 'Edit Transaksi' : 'Tambah Transaksi'
        ),
        iconTheme: IconThemeData(
          color: Theme.of(context).textTheme.titleLarge?.color,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Type selection
                Container(
                  padding: const EdgeInsets.all(16),
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
                      Text(
                        'Jenis Transaksi',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.titleLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedType = 'income'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: _selectedType == 'income'
                                      ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                                      : Colors.transparent,
                                  border: Border.all(
                                    color: _selectedType == 'income'
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context).dividerColor,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.add_circle_outline,
                                      color: _selectedType == 'income'
                                          ? Theme.of(context).colorScheme.primary
                                          : Theme.of(context).iconTheme.color,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Pemasukan',
                                      style: TextStyle(
                                        color: _selectedType == 'income'
                                            ? Theme.of(context).colorScheme.primary
                                            : null,
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
                              onTap: () => setState(() => _selectedType = 'expense'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: _selectedType == 'expense'
                                      ? Theme.of(context).colorScheme.error.withOpacity(0.1)
                                      : Colors.transparent,
                                  border: Border.all(
                                    color: _selectedType == 'expense'
                                        ? Theme.of(context).colorScheme.error
                                        : Theme.of(context).dividerColor,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.remove_circle_outline,
                                      color: _selectedType == 'expense'
                                          ? Theme.of(context).colorScheme.error
                                          : Theme.of(context).iconTheme.color,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Pengeluaran',
                                      style: TextStyle(
                                        color: _selectedType == 'expense'
                                            ? Theme.of(context).colorScheme.error
                                            : null,
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

                // Card untuk memilih antara kategori, tabungan, atau tagihan
                Consumer3<CategoryProvider, SavingsGoalProvider, BillReminderProvider>(
                  builder: (context, categoryProvider, savingsProvider, billProvider, child) {
                    // Muat data jika belum dimuat
                    if (categoryProvider.categories.isEmpty && !categoryProvider.isLoading) {
                      categoryProvider.fetchCategories();
                    }

                    if (savingsProvider.savingsGoals.isEmpty && !savingsProvider.isLoading) {
                      savingsProvider.fetchSavingsGoals();
                    }

                    if (billProvider.billReminders.isEmpty && !billProvider.isLoading) {
                      billProvider.fetchBillReminders();
                    }

                    // Gunakan data yang tersedia
                    final categories = categoryProvider.categories.map((cat) => {
                      'id': cat.id.toString(),
                      'name': cat.name ?? 'N/A',
                    }).toList();

                    final savingsGoals = savingsProvider.savingsGoals.map((sg) => {
                      'id': sg.id.toString(),
                      'name': sg.name ?? 'N/A',
                    }).toList();

                    final bills = billProvider.billReminders.map((bill) => {
                      'id': bill.id.toString(),
                      'name': bill.name ?? 'N/A',
                    }).toList();

                    return Container(
                      padding: const EdgeInsets.all(16),
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
                          Text(
                            'Pilih Jenis Relasi',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).textTheme.titleLarge?.color,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Radio buttons untuk memilih jenis relasi
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => _selectedPaymentType = 'category'),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      color: _selectedPaymentType == 'category'
                                          ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                                          : Colors.transparent,
                                      border: Border.all(
                                        color: _selectedPaymentType == 'category'
                                            ? Theme.of(context).colorScheme.primary
                                            : Theme.of(context).dividerColor,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.category_outlined,
                                          color: _selectedPaymentType == 'category'
                                              ? Theme.of(context).colorScheme.primary
                                              : Theme.of(context).iconTheme.color,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Kategori',
                                          style: TextStyle(
                                            color: _selectedPaymentType == 'category'
                                                ? Theme.of(context).colorScheme.primary
                                                : null,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => _selectedPaymentType = 'savings'),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      color: _selectedPaymentType == 'savings'
                                          ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                                          : Colors.transparent,
                                      border: Border.all(
                                        color: _selectedPaymentType == 'savings'
                                            ? Theme.of(context).colorScheme.primary
                                            : Theme.of(context).dividerColor,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.savings_outlined,
                                          color: _selectedPaymentType == 'savings'
                                              ? Theme.of(context).colorScheme.primary
                                              : Theme.of(context).iconTheme.color,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Tabungan',
                                          style: TextStyle(
                                            color: _selectedPaymentType == 'savings'
                                                ? Theme.of(context).colorScheme.primary
                                                : null,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => _selectedPaymentType = 'bill'),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      color: _selectedPaymentType == 'bill'
                                          ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                                          : Colors.transparent,
                                      border: Border.all(
                                        color: _selectedPaymentType == 'bill'
                                            ? Theme.of(context).colorScheme.primary
                                            : Theme.of(context).dividerColor,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.receipt_long_outlined,
                                          color: _selectedPaymentType == 'bill'
                                              ? Theme.of(context).colorScheme.primary
                                              : Theme.of(context).iconTheme.color,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Tagihan',
                                          style: TextStyle(
                                            color: _selectedPaymentType == 'bill'
                                                ? Theme.of(context).colorScheme.primary
                                                : null,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Dropdown berdasarkan pilihan
                          if (_selectedPaymentType == 'category')
                            Column(
                              children: [
                                Text(
                                  'Pilih Kategori',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(context).textTheme.bodyMedium?.color,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Theme.of(context).dividerColor),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: DropdownButton<String>(
                                    value: _selectedCategory,
                                    hint: const Text('Pilih Kategori'),
                                    isExpanded: true,
                                    underline: Container(),
                                    items: categories.map((category) {
                                      return DropdownMenuItem<String>(
                                        value: category['id'],
                                        child: Text(category['name'] ?? 'N/A'),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedCategory = value;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            )
                          else if (_selectedPaymentType == 'savings')
                            Column(
                              children: [
                                Text(
                                  'Pilih Tabungan',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(context).textTheme.bodyMedium?.color,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Theme.of(context).dividerColor),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: DropdownButton<String>(
                                    value: _selectedSavings,
                                    hint: const Text('Pilih Tabungan'),
                                    isExpanded: true,
                                    underline: Container(),
                                    items: savingsGoals.map((savings) {
                                      return DropdownMenuItem<String>(
                                        value: savings['id'],
                                        child: Text(savings['name'] ?? 'N/A'),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedSavings = value;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            )
                          else if (_selectedPaymentType == 'bill')
                            Column(
                              children: [
                                Text(
                                  'Pilih Tagihan',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(context).textTheme.bodyMedium?.color,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Theme.of(context).dividerColor),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: DropdownButton<String>(
                                    value: _selectedBill,
                                    hint: const Text('Pilih Tagihan'),
                                    isExpanded: true,
                                    underline: Container(),
                                    items: bills.map((bill) {
                                      return DropdownMenuItem<String>(
                                        value: bill['id'],
                                        child: Text(bill['name'] ?? 'N/A'),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedBill = value;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16),

                // Amount input
                Container(
                  padding: const EdgeInsets.all(16),
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
                      Text(
                        'Jumlah',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.titleLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Harap masukkan jumlah';
                          }
                          final amount = double.tryParse(value);
                          if (amount == null || amount <= 0) {
                            return 'Harap masukkan jumlah yang valid';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: 'Rp 0',
                          prefixText: 'Rp ',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Description input
                Container(
                  padding: const EdgeInsets.all(16),
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
                      Text(
                        'Deskripsi',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.titleLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _descriptionController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Harap masukkan deskripsi';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: 'Contoh: Belanja bulanan',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Date picker
                Container(
                  padding: const EdgeInsets.all(16),
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
                      Text(
                        'Tanggal',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.titleLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _dateController,
                        readOnly: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Harap pilih tanggal';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: 'Pilih tanggal',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2101),
                          );
                          if (pickedDate != null) {
                            String formattedDate = "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                            setState(() {
                              _dateController.text = formattedDate;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Submit button
                Consumer<TransactionProvider>(
                  builder: (context, transactionProvider, child) {
                    return SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: transactionProvider.isLoading ? null : () async {
                          if (_formKey.currentState!.validate()) {
                            // Determine the IDs based on payment type
                            int? categoryId;
                            int? savingsGoalId;
                            int? billReminderId;

                            if (_selectedPaymentType == 'category' && _selectedCategory != null) {
                              categoryId = int.tryParse(_selectedCategory!);
                            } else if (_selectedPaymentType == 'savings' && _selectedSavings != null) {
                              savingsGoalId = int.tryParse(_selectedSavings!);
                            } else if (_selectedPaymentType == 'bill' && _selectedBill != null) {
                              billReminderId = int.tryParse(_selectedBill!);
                            }

                            // Parse the date
                            DateTime? selectedDate;
                            if (_dateController.text.isNotEmpty) {
                              try {
                                // Format date from dd/MM/yyyy to yyyy-MM-dd
                                List<String> dateParts = _dateController.text.split('/');
                                if (dateParts.length == 3) {
                                  selectedDate = DateTime(
                                    int.parse(dateParts[2]), // year
                                    int.parse(dateParts[1]), // month
                                    int.parse(dateParts[0]), // day
                                  );
                                }
                              } catch (e) {
                                print('Error parsing date: $e');
                              }
                            }

                            bool success = false;

                            if (widget.transaction != null) {
                              // Update existing transaction
                              success = await transactionProvider.updateTransaction(
                                widget.transaction.id!,
                                categoryId, // categoryId
                                _amountController.text,
                                _selectedType!,
                                _descriptionController.text,
                                selectedDate?.toIso8601String().split('T')[0], // Format date as YYYY-MM-DD
                                billReminderId: billReminderId,
                                savingsGoalId: savingsGoalId,
                              );
                            } else {
                              // Create new transaction
                              success = await transactionProvider.createTransactionSimple(
                                categoryId, // categoryId
                                _amountController.text,
                                _selectedType!,
                                _descriptionController.text,
                                selectedDate?.toIso8601String().split('T')[0], // Format date as YYYY-MM-DD
                                billReminderId: billReminderId,
                                savingsGoalId: savingsGoalId,
                              );
                            }

                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Transaksi berhasil disimpan'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              Navigator.pop(context); // Go back after successful submission
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(transactionProvider.message),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: transactionProvider.isLoading
                              ? Theme.of(context).colorScheme.primary.withOpacity(0.5)
                              : Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: transactionProvider.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(
                                widget.transaction != null ? 'Perbarui Transaksi' : 'Tambah Transaksi',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
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