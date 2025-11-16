import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/category_provider.dart';
import 'category_form_screen.dart';

class CategoryListScreen extends StatelessWidget {
  const CategoryListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<CategoryProvider>(
        builder: (context, provider, child) {
          // Pastikan kategori sudah dimuat
          if (provider.categories.isEmpty && !provider.isLoading) {
            // Jika belum pernah diambil, ambil dulu
            WidgetsBinding.instance.addPostFrameCallback((_) {
              provider.fetchCategories();
            });
          }

          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.categories.isEmpty) {
            return const Center(
              child: Text(
                'No categories yet.\nAdd your first category!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchCategories(),
            child: ListView.builder(
              itemCount: provider.categories.length,
              itemBuilder: (context, index) {
                final category = provider.categories[index];
                print("Menampilkan kategori: ${category.name}, ID: ${category.id}"); // Debug log
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: category.type == 'income'
                            ? Colors.green.shade100
                            : Colors.red.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        category.type == 'income'
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        color: category.type == 'income'
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                    title: Text(
                      category.name ?? 'N/A',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      (category.type ?? '').toUpperCase(),
                    ),
                    trailing: PopupMenuButton(
                      onSelected: (value) async {
                        if (value == 'edit') {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CategoryFormScreen(category: category),
                            ),
                          );

                          // Jika ada perubahan setelah kembali dari form edit, refresh data
                          if (result != null) {
                            print("Kembali dari form edit kategori, menyegarkan data..."); // Debug log
                            await Provider.of<CategoryProvider>(context, listen: false).fetchCategories();
                          }
                        } else if (value == 'delete') {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Category'),
                              content: const Text('Are you sure you want to delete this category?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    Navigator.pop(context);
                                    bool success = await provider.deleteCategory(category.id!);
                                    if (success) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Category deleted successfully'),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(provider.message),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  },
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Text('Edit'),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Pastikan kategori dimuat sebelum navigasi
          print("Menekan tombol tambah kategori, memuat kembali data..."); // Debug log
          await Provider.of<CategoryProvider>(context, listen: false).fetchCategories();
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CategoryFormScreen(),
            ),
          );

          // Jika ada perubahan setelah kembali dari form, refresh data
          if (result != null) {
            print("Kembali dari form kategori, menyegarkan data..."); // Debug log
            await Provider.of<CategoryProvider>(context, listen: false).fetchCategories();
          }
        },
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}