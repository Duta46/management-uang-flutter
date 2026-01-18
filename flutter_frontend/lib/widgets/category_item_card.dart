import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_frontend/models/category.dart';
import 'package:flutter_frontend/providers/category_provider_change_notifier.dart';
import 'package:flutter_frontend/providers/auth_provider_change_notifier.dart';
import '../theme/app_theme.dart';
import '../screens/categories/category_form_screen.dart';

class CategoryItemCard extends StatefulWidget {
  final Category category;
  final VoidCallback onRefresh;

  const CategoryItemCard({
    Key? key,
    required this.category,
    required this.onRefresh,
  }) : super(key: key);

  @override
  State<CategoryItemCard> createState() => _CategoryItemCardState();
}

class _CategoryItemCardState extends State<CategoryItemCard> {
  bool _isDeleting = false;

  Future<void> _deleteCategory() async {
    setState(() {
      _isDeleting = true;
    });

    try {
      // Get the CategoryProvider from context to delete the category
      final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
      bool success = await categoryProvider.hapusKategori(widget.category.id!);

      if (success) {
        widget.onRefresh();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(categoryProvider.message)),
        );
      } else {
        setState(() {
          _isDeleting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(categoryProvider.message)),
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.category.name ?? 'Kategori',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.titleLarge?.color,
                          ),
                        ),
                      ),
                      // Tambahkan badge untuk menunjukkan bahwa ini adalah kategori pribadi
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Theme.of(context).colorScheme.primary),
                        ),
                        child: Text(
                          'Milik Saya',
                          style: TextStyle(
                            fontSize: 10,
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, size: 20, color: Theme.of(context).colorScheme.primary),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CategoryFormScreen(category: widget.category),
                          ),
                        ).then((result) {
                          if (result != null) {
                            widget.onRefresh();
                          }
                        });
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, size: 20, color: Theme.of(context).colorScheme.error),
                      onPressed: () {
                        _showDeleteConfirmation();
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12.0),
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getCategoryIcon(widget.category.name ?? ''),
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String categoryName) {
    // Konversi nama kategori ke huruf kecil untuk pencocokan
    final lowerCategoryName = categoryName.toLowerCase();

    // Daftar kata kunci dan icon yang sesuai
    if (lowerCategoryName.contains('listrik') || lowerCategoryName.contains('pln') || lowerCategoryName.contains('tagihan') || lowerCategoryName.contains('pembayaran')) {
      return Icons.electrical_services;
    } else if (lowerCategoryName.contains('gaji') || lowerCategoryName.contains('pendapatan') || lowerCategoryName.contains('income') || lowerCategoryName.contains('kerja')) {
      return Icons.work;
    } else if (lowerCategoryName.contains('belanja') || lowerCategoryName.contains('shopping') || lowerCategoryName.contains('makan') || lowerCategoryName.contains('food')) {
      return Icons.shopping_cart;
    } else if (lowerCategoryName.contains('transportasi') || lowerCategoryName.contains('travel') || lowerCategoryName.contains('mobil') || lowerCategoryName.contains('bensin')) {
      return Icons.directions_car;
    } else if (lowerCategoryName.contains('kesehatan') || lowerCategoryName.contains('dokter') || lowerCategoryName.contains('obat') || lowerCategoryName.contains('medis')) {
      return Icons.local_hospital;
    } else if (lowerCategoryName.contains('pendidikan') || lowerCategoryName.contains('sekolah') || lowerCategoryName.contains('kuliah') || lowerCategoryName.contains('buku')) {
      return Icons.school;
    } else if (lowerCategoryName.contains('hiburan') || lowerCategoryName.contains('entertainment') || lowerCategoryName.contains('film') || lowerCategoryName.contains('game')) {
      return Icons.movie;
    } else if (lowerCategoryName.contains('pajak') || lowerCategoryName.contains('tax') || lowerCategoryName.contains('pemerintah')) {
      return Icons.account_balance;
    } else if (lowerCategoryName.contains('asuransi') || lowerCategoryName.contains('insurance')) {
      return Icons.shield;
    } else if (lowerCategoryName.contains('pulsa') || lowerCategoryName.contains('telepon') || lowerCategoryName.contains('internet')) {
      return Icons.phone_iphone;
    } else if (lowerCategoryName.contains('air') || lowerCategoryName.contains('pdam')) {
      return Icons.water_drop;
    } else if (lowerCategoryName.contains('sewa') || lowerCategoryName.contains('kontrak')) {
      return Icons.home;
    } else if (lowerCategoryName.contains('investasi') || lowerCategoryName.contains('saham')) {
      return Icons.trending_up;
    } else if (lowerCategoryName.contains('pakaian') || lowerCategoryName.contains('cloth') || lowerCategoryName.contains('fashion')) {
      return Icons.checkroom;
    } else if (lowerCategoryName.contains('hadiah') || lowerCategoryName.contains('gift')) {
      return Icons.card_giftcard;
    } else if (lowerCategoryName.contains('hutang') || lowerCategoryName.contains('pinjaman')) {
      return Icons.money_off;
    } else if (lowerCategoryName.contains('tabungan') || lowerCategoryName.contains('saving')) {
      return Icons.savings;
    } else {
      // Icon default jika tidak ada kecocokan
      return Icons.category;
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: Text('Apakah Anda yakin ingin menghapus kategori "${widget.category.name ?? 'Kategori'}"?'),
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
                _deleteCategory();
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