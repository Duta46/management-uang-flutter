import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_frontend/models/category.dart';
import 'package:flutter_frontend/providers/category_provider_change_notifier.dart';

class CategoryFormScreen extends StatefulWidget {
  final Category? category; // Pass existing category for editing

  const CategoryFormScreen({Key? key, this.category}) : super(key: key);

  @override
  State<CategoryFormScreen> createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends State<CategoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();


  @override
  void initState() {
    super.initState();

    if (widget.category != null) {
      // Editing existing category
      _nameController.text = widget.category!.name ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category != null ? 'Edit Category' : 'Add Category'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name input
              const Text(
                'Category Name',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
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
                child: TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    prefixIcon: Icon(Icons.category),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.transparent,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a category name';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 16),

              const SizedBox(height: 24),

              // Save button
              Consumer<CategoryProvider>(
                builder: (context, provider, child) {
                  return SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          if (widget.category != null) {
                            // Update existing category
                            bool success = await provider.updateCategory(
                              widget.category!.id!,
                              _nameController.text,
                            );

                            if (success) {
                              print("Kategori berhasil diperbarui, kembali ke halaman sebelumnya"); // Debug log
                              // Kembali ke halaman sebelumnya dengan result
                              Navigator.pop(context, true); // Mengembalikan true sebagai indikator sukses
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Category updated successfully'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } else {
                              print("Gagal memperbarui kategori: ${provider.message}"); // Debug log
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(provider.message),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          } else {
                            // Create new category
                            bool success = await provider.createCategory(
                              _nameController.text,
                            );

                            if (success) {
                              print("Kategori berhasil dibuat, kembali ke halaman sebelumnya"); // Debug log
                              // Kembali ke halaman sebelumnya dengan result
                              Navigator.pop(context, true); // Mengembalikan true sebagai indikator sukses
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Category added successfully'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } else {
                              print("Gagal membuat kategori: ${provider.message}"); // Debug log
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(provider.message),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        widget.category != null ? 'Update Category' : 'Add Category',
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
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}