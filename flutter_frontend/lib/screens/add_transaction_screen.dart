import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../providers/category_provider_change_notifier.dart';
import '../providers/bill_reminder_provider.dart';
import '../providers/savings_goal_provider.dart';
import '../models/api_models.dart';
import '../theme/app_theme.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({Key? key}) : super(key: key);

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedType = 'expense';
  String _selectedPaymentType = 'category'; // New: 'category', 'bill', or 'savings'
  int? _selectedCategoryId;
  int? _selectedBillReminderId;
  int? _selectedSavingsGoalId;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CategoryProvider>(context, listen: false).fetchCategories();
      Provider.of<BillReminderProvider>(context, listen: false).fetchBillReminders();
      Provider.of<SavingsGoalProvider>(context, listen: false).fetchSavingsGoals();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submitForm() async {
    // Validate based on selected payment type
    bool isValid = _formKey.currentState!.validate();
    bool hasRequiredSelection = false;

    if (_selectedPaymentType == 'category') {
      hasRequiredSelection = _selectedCategoryId != null;
    } else if (_selectedPaymentType == 'bill') {
      // Jika tidak ada tagihan yang belum dibayar, tidak bisa memilih bill
      if (billReminders.isEmpty) {
        hasRequiredSelection = false;
      } else {
        hasRequiredSelection = _selectedBillReminderId != null;
      }
    } else if (_selectedPaymentType == 'savings') {
      // Jika tidak ada tujuan tabungan, tidak bisa memilih savings
      if (savingsGoals.isEmpty) {
        hasRequiredSelection = false;
      } else {
        hasRequiredSelection = _selectedSavingsGoalId != null;
      }
    }

    if (isValid && hasRequiredSelection) {
      int? categoryId;
      int? billReminderId;
      int? savingsGoalId;

      if (_selectedPaymentType == 'category' && _selectedCategoryId != null) {
        categoryId = _selectedCategoryId;
      } else if (_selectedPaymentType == 'bill' && _selectedBillReminderId != null) {
        billReminderId = _selectedBillReminderId;
      } else if (_selectedPaymentType == 'savings' && _selectedSavingsGoalId != null) {
        savingsGoalId = _selectedSavingsGoalId;
      }

      // Determine which category ID to use based on payment type
      int? finalCategoryId;
      if (_selectedPaymentType == 'category' && categoryId != null) {
        finalCategoryId = categoryId;
      } else if (_selectedPaymentType == 'bill' && billReminderId != null) {
        // When using bill, we can use a default category
        finalCategoryId = 1; // Using default category ID
      } else if (_selectedPaymentType == 'savings' && savingsGoalId != null) {
        // When using savings, we can use a default category
        finalCategoryId = 1; // Using default category ID
      } else {
        finalCategoryId = 1; // Default fallback
      }

      final transaction = Transaction(
        amount: _amountController.text,
        type: _selectedType,
        categoryId: finalCategoryId,
        billReminderId: billReminderId,
        savingsGoalId: savingsGoalId,
        description: _descriptionController.text,
        date: DateFormat('yyyy-MM-dd').format(_selectedDate),
      );

      final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
      final response = await transactionProvider.addTransaction(transaction);

      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaction added successfully')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.message)),
        );
      }
    } else {
      String errorMessage = 'Please fill all required fields';
      if (!hasRequiredSelection) {
        if (_selectedPaymentType == 'category') {
          errorMessage = 'Please select a category';
        } else if (_selectedPaymentType == 'bill') {
          if (billReminders.isEmpty) {
            errorMessage = 'No unpaid bills available';
          } else {
            errorMessage = 'Please select a bill';
          }
        } else if (_selectedPaymentType == 'savings') {
          if (savingsGoals.isEmpty) {
            errorMessage = 'No savings goals available';
          } else {
            errorMessage = 'Please select a savings goal';
          }
        } else {
          errorMessage = 'Please make a selection';
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final billReminderProvider = Provider.of<BillReminderProvider>(context);
    final savingsGoalProvider = Provider.of<SavingsGoalProvider>(context);
    final categories = categoryProvider.categories;
    final billReminders = billReminderProvider.billReminders
        .where((bill) => !bill.isPaid && bill.isActive)
        .toList();
    final savingsGoals = savingsGoalProvider.savingsGoals;

    final filteredCategories = categories;

    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedType == 'income' ? 'Add Income' : 'Add Expense'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Type Selection
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Transaction Type',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _selectedType = 'income';
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _selectedType == 'income'
                                    ? AppTheme.incomeColor
                                    : Colors.grey.shade200,
                                foregroundColor: _selectedType == 'income'
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                              child: const Text('Income'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _selectedType = 'expense';
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _selectedType == 'expense'
                                    ? AppTheme.expenseColor
                                    : Colors.grey.shade200,
                                foregroundColor: _selectedType == 'expense'
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                              child: const Text('Expense'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Payment Type Selection
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Payment Type',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _selectedPaymentType = 'category';
                                  _selectedBillReminderId = null; // Reset bill reminder when switching to category
                                  _selectedSavingsGoalId = null; // Reset savings goal when switching to category
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _selectedPaymentType == 'category'
                                    ? AppTheme.incomeColor
                                    : Colors.grey.shade200,
                                foregroundColor: _selectedPaymentType == 'category'
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                              child: const Text('Category'),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: billReminders.isEmpty ? null : () {
                                setState(() {
                                  _selectedPaymentType = 'bill';
                                  _selectedCategoryId = null; // Reset category when switching to bill
                                  _selectedSavingsGoalId = null; // Reset savings goal when switching to bill
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _selectedPaymentType == 'bill'
                                    ? AppTheme.expenseColor
                                    : billReminders.isEmpty
                                    ? Colors.grey.shade300
                                    : Colors.grey.shade200,
                                foregroundColor: _selectedPaymentType == 'bill'
                                    ? Colors.white
                                    : billReminders.isEmpty
                                    ? Colors.grey.shade100
                                    : Colors.black87,
                              ),
                              child: const Text('Bill'),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: savingsGoals.isEmpty ? null : () {
                                setState(() {
                                  _selectedPaymentType = 'savings';
                                  _selectedCategoryId = null; // Reset category when switching to savings
                                  _selectedBillReminderId = null; // Reset bill reminder when switching to savings
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _selectedPaymentType == 'savings'
                                    ? AppTheme.incomeColor
                                    : savingsGoals.isEmpty
                                    ? Colors.grey.shade300
                                    : Colors.grey.shade200,
                                foregroundColor: _selectedPaymentType == 'savings'
                                    ? Colors.white
                                    : savingsGoals.isEmpty
                                    ? Colors.grey.shade100
                                    : Colors.black87,
                              ),
                              child: const Text('Savings'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Conditional Category Selection
              if (_selectedPaymentType == 'category') ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Category',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<int>(
                          value: _selectedCategoryId,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Select a category',
                          ),
                          items: filteredCategories.map((category) {
                            return DropdownMenuItem(
                              value: category.id,
                              child: Text(category.name),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCategoryId = value;
                            });
                          },
                          validator: (value) {
                            if (_selectedPaymentType == 'category' && value == null) {
                              return 'Please select a category';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Conditional Bill Reminder Selection
              if (_selectedPaymentType == 'bill') ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Bill Payment',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        if (billReminders.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              'Tidak ada tagihan yang belum dibayar',
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        else
                          DropdownButtonFormField<int>(
                            value: _selectedBillReminderId,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Select a bill to pay',
                            ),
                            items: billReminders.map((bill) {
                              return DropdownMenuItem(
                                value: bill.id,
                                child: Text('${bill.name} - Rp ${bill.amount} (Due: ${bill.dueDate})'),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedBillReminderId = value;
                                // Auto-fill amount when bill is selected
                                if (value != null) {
                                  final selectedBill = billReminders.firstWhere(
                                    (bill) => bill.id == value,
                                  );
                                  _amountController.text = selectedBill.amount;
                                }
                              });
                            },
                            validator: (value) {
                              if (_selectedPaymentType == 'bill' && value == null) {
                                return 'Please select a bill';
                              }
                              return null;
                            },
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Conditional Savings Goal Selection
              if (_selectedPaymentType == 'savings') ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Savings Goal',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        if (savingsGoals.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              'Tidak ada tujuan tabungan',
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        else
                          DropdownButtonFormField<int>(
                            value: _selectedSavingsGoalId,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Select a savings goal',
                            ),
                            items: savingsGoals.map((goal) {
                              return DropdownMenuItem(
                                value: goal.id,
                                child: Text('${goal.name} - Rp ${goal.currentAmount} / Rp ${goal.targetAmount}'),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedSavingsGoalId = value;
                                // Auto-fill amount when savings goal is selected (optional)
                                // For now, we'll let the user enter the amount manually
                              });
                            },
                            validator: (value) {
                              if (_selectedPaymentType == 'savings' && value == null) {
                                return 'Please select a savings goal';
                              }
                              return null;
                            },
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Amount Input
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Amount',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          hintText: '0.00',
                          prefixText: 'Rp ',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an amount';
                          }
                          if (double.tryParse(value) == null || double.parse(value) <= 0) {
                            return 'Please enter a valid amount';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Date Selection
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Date',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      ListTile(
                        tileColor: Colors.grey.shade50,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(color: Colors.grey),
                        ),
                        leading: const Icon(Icons.calendar_today),
                        title: Text(DateFormat('dd MMM yyyy').format(_selectedDate)),
                        trailing: const Icon(Icons.arrow_drop_down),
                        onTap: _selectDate,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Description
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Description (Optional)',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          hintText: 'Add a note about this transaction...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Save Transaction',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}