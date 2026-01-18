import 'package:flutter/material.dart';
import 'package:flutter_frontend/models/budget.dart';
import 'package:flutter_frontend/models/category.dart';
import 'package:flutter_frontend/services/api_service.dart';

class EditBudgetScreen extends StatefulWidget {
  final Budget budget;
  
  const EditBudgetScreen({Key? key, required this.budget}) : super(key: key);

  @override
  State<EditBudgetScreen> createState() => _EditBudgetScreenState();
}

class _EditBudgetScreenState extends State<EditBudgetScreen> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;
  
  String _selectedMonth = '';
  int? _selectedCategoryId;
  List<Category> _categories = [];
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.budget.name ?? '');
    _amountController = TextEditingController(text: widget.budget.amount);
    _descriptionController = TextEditingController(text: widget.budget.description ?? '');
    
    _selectedMonth = widget.budget.month;
    _selectedCategoryId = widget.budget.categoryId;
    
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final response = await _apiService.getCategories();
      if (response.success && response.data != null) {
        setState(() {
          _categories = response.data!;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading categories: $e')),
      );
    }
  }

  Future<void> _updateBudget() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final budget = Budget(
        id: widget.budget.id,
        userId: widget.budget.userId,
        categoryId: _selectedCategoryId,
        amount: _amountController.text,
        month: _selectedMonth,
        name: _nameController.text,
        description: _descriptionController.text,
      );

      final response = await _apiService.updateBudget(budget);
      if (response.success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Anggaran berhasil diperbarui')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memperbarui anggaran: ${response.message}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardTheme.color,
        foregroundColor: Theme.of(context).textTheme.titleLarge?.color,
        elevation: 0,
        title: const Text('Edit Anggaran'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardTheme.color,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: 'Nama Anggaran',
                                hintText: 'Contoh: Anggaran Bulan Ini',
                                prefixIcon: Icon(Icons.account_balance_wallet),
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Nama anggaran wajib diisi';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16.0),
                            TextFormField(
                              controller: _amountController,
                              decoration: const InputDecoration(
                                labelText: 'Jumlah Anggaran',
                                hintText: 'Rp',
                                prefixIcon: Icon(Icons.attach_money),
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Jumlah anggaran wajib diisi';
                                }
                                final amount = double.tryParse(value);
                                if (amount == null || amount <= 0) {
                                  return 'Jumlah harus lebih besar dari 0';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16.0),
                            TextFormField(
                              controller: _descriptionController,
                              decoration: const InputDecoration(
                                labelText: 'Deskripsi (Opsional)',
                                hintText: 'Tambahkan deskripsi (opsional)',
                                prefixIcon: Icon(Icons.description),
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 3,
                            ),
                            const SizedBox(height: 16.0),
                            // Month selection
                            const Text('Bulan', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8.0),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12.0),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: DropdownButton<String>(
                                value: _selectedMonth,
                                isExpanded: true,
                                underline: Container(),
                                items: List.generate(24, (index) {
                                  final date = DateTime.now().subtract(Duration(days: index * 30));
                                  final month = '${date.year}-${date.month.toString().padLeft(2, '0')}';
                                  return DropdownMenuItem(
                                    value: month,
                                    child: Text(month),
                                  );
                                }),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedMonth = value!;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(height: 16.0),
                            // Category selection
                            const Text('Kategori (Opsional)', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8.0),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12.0),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: DropdownButton<int?>(
                                value: _selectedCategoryId,
                                isExpanded: true,
                                underline: Container(),
                                hint: const Text('Pilih kategori'),
                                items: [
                                  const DropdownMenuItem(
                                    value: null,
                                    child: Text('Tanpa kategori'),
                                  ),
                                  ..._categories.map((category) => DropdownMenuItem(
                                        value: category.id,
                                        child: Text(category.name),
                                      )),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _selectedCategoryId = value;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24.0),
                      ElevatedButton(
                        onPressed: _isSaving ? null : _updateBudget,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                              )
                            : const Text(
                                'Perbarui Anggaran',
                                style: TextStyle(fontSize: 16.0, color: Colors.white),
                              ),
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
    _nameController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}