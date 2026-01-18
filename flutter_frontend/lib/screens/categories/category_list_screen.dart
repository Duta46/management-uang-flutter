import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_frontend/providers/category_provider_change_notifier.dart';
import 'package:flutter_frontend/providers/auth_provider_change_notifier.dart';
import '../../models/category.dart' as ModelCategory;
import '../../theme/app_theme.dart';
import 'category_form_screen.dart';
import '../../widgets/category_item_card.dart';

class CategoryListScreen extends StatelessWidget {
  const CategoryListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          appBar: AppBar(
            backgroundColor: Theme.of(context).cardTheme.color,
            foregroundColor: Theme.of(context).textTheme.titleLarge?.color,
            elevation: 0,
            title: const Text('Kategori'),
            iconTheme: IconThemeData(
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CategoryFormScreen(),
                    ),
                  );

                  // Refresh data after adding new category
                  if (result != null) {
                    await Provider.of<CategoryProvider>(context, listen: false).fetchCategories();
                  }
                },
              ),
            ],
          ),
          body: Consumer<CategoryProvider>(
            builder: (context, provider, child) {
              // Load categories when screen is built
              WidgetsBinding.instance.addPostFrameCallback((_) {
                provider.fetchCategories();
              });

              if (provider.categories.isEmpty) {
                return Center(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardTheme.color,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.category_outlined,
                          size: 60,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Belum Ada Kategori',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.titleLarge?.color,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Kategori akan muncul di sini setelah Anda menambahkannya',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => provider.fetchCategories(),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.categories.length,
                  itemBuilder: (context, index) {
                    final category = provider.categories[index];
                    return CategoryItemCard(
                      category: category,
                      onRefresh: () async {
                        await Provider.of<CategoryProvider>(context, listen: false).fetchCategories();
                      },
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}