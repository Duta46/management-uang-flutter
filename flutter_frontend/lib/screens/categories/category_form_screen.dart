import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_frontend/models/category.dart';
import 'package:flutter_frontend/providers/category_provider_change_notifier.dart';
import 'package:flutter_frontend/providers/auth_provider_change_notifier.dart';
import 'package:flutter_frontend/theme/app_theme.dart';

class CategoryFormScreen extends StatefulWidget {
  final Category? category; // Pass existing category for editing

  const CategoryFormScreen({Key? key, this.category}) : super(key: key);

  @override
  State<CategoryFormScreen> createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends State<CategoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.category != null) {
      // Editing existing category
      _namaController.text = widget.category!.name ?? '';
    }

    // Tambahkan listener untuk memperbarui tampilan ketika teks berubah
    _namaController.addListener(() {
      setState(() {
        // Memperbarui tampilan untuk menampilkan icon yang sesuai
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardTheme.color,
        foregroundColor: Theme.of(context).textTheme.titleLarge?.color,
        elevation: 0,
        title: Text(
          widget.category != null ? 'Edit Kategori' : 'Tambah Kategori',
        ),
        iconTheme: IconThemeData(
          color: Theme.of(context).textTheme.titleLarge?.color,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name input
              Text(
                'Nama Kategori',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
              const SizedBox(height: 8),
              Container(
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
                child: TextFormField(
                  controller: _namaController,
                  style: TextStyle(color: Theme.of(context).textTheme.titleLarge?.color),
                  decoration: InputDecoration(
                    labelText: 'Nama',
                    labelStyle: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
                    prefixIcon: Icon(Icons.category, color: Theme.of(context).colorScheme.primary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.transparent,
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Theme.of(context).dividerColor),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Harap masukkan nama kategori';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Preview icon
              Container(
                padding: const EdgeInsets.all(12),
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
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getCategoryIcon(_namaController.text),
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Pratinjau Ikon:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).textTheme.titleLarge?.color,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _namaController.text.isEmpty ? 'Masukkan nama kategori untuk melihat ikon' : 'Ikon untuk "${_namaController.text}"',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

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
                            bool success = await provider.perbaruiKategori(
                              widget.category!.id!,
                              _namaController.text,
                            );

                            if (success) {
                              print("Kategori berhasil diperbarui, kembali ke halaman sebelumnya"); // Debug log
                              // Kembali ke halaman sebelumnya dengan result
                              Navigator.pop(context, true); // Mengembalikan true sebagai indikator sukses
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Kategori berhasil diperbarui'),
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
                            // Create new category (always as personal category, not global)
                            bool success = await provider.buatKategori(
                              _namaController.text,
                              isGlobal: false,
                            );

                            if (success) {
                              print("Kategori berhasil dibuat, kembali ke halaman sebelumnya"); // Debug log
                              // Kembali ke halaman sebelumnya dengan result
                              Navigator.pop(context, true); // Mengembalikan true sebagai indikator sukses
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Kategori berhasil ditambahkan'),
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
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        widget.category != null ? 'Perbarui Kategori' : 'Tambah Kategori',
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

  IconData _getCategoryIcon(String categoryName) {
    // Konversi nama kategori ke huruf kecil untuk pencocokan
    final lowerNamaKategori = categoryName.toLowerCase();

    // Daftar kata kunci dan icon yang sesuai
    if (lowerNamaKategori.contains('listrik') || lowerNamaKategori.contains('pln') || lowerNamaKategori.contains('tagihan') || lowerNamaKategori.contains('pembayaran')) {
      return Icons.electrical_services;
    } else if (lowerNamaKategori.contains('gaji') || lowerNamaKategori.contains('pendapatan') || lowerNamaKategori.contains('income') || lowerNamaKategori.contains('kerja')) {
      return Icons.work;
    } else if (lowerNamaKategori.contains('belanja') || lowerNamaKategori.contains('shopping') || lowerNamaKategori.contains('makan') || lowerNamaKategori.contains('food')) {
      return Icons.shopping_cart;
    } else if (lowerNamaKategori.contains('transportasi') || lowerNamaKategori.contains('travel') || lowerNamaKategori.contains('mobil') || lowerNamaKategori.contains('bensin')) {
      return Icons.directions_car;
    } else if (lowerNamaKategori.contains('kesehatan') || lowerNamaKategori.contains('dokter') || lowerNamaKategori.contains('obat') || lowerNamaKategori.contains('medis')) {
      return Icons.local_hospital;
    } else if (lowerNamaKategori.contains('pendidikan') || lowerNamaKategori.contains('sekolah') || lowerNamaKategori.contains('kuliah') || lowerNamaKategori.contains('buku')) {
      return Icons.school;
    } else if (lowerNamaKategori.contains('hiburan') || lowerNamaKategori.contains('entertainment') || lowerNamaKategori.contains('film') || lowerNamaKategori.contains('game')) {
      return Icons.movie;
    } else if (lowerNamaKategori.contains('pajak') || lowerNamaKategori.contains('tax') || lowerNamaKategori.contains('pemerintah')) {
      return Icons.account_balance;
    } else if (lowerNamaKategori.contains('asuransi') || lowerNamaKategori.contains('insurance')) {
      return Icons.shield;
    } else if (lowerNamaKategori.contains('pulsa') || lowerNamaKategori.contains('telepon') || lowerNamaKategori.contains('internet')) {
      return Icons.phone_iphone;
    } else if (lowerNamaKategori.contains('air') || lowerNamaKategori.contains('pdam')) {
      return Icons.water_drop;
    } else if (lowerNamaKategori.contains('sewa') || lowerNamaKategori.contains('kontrak')) {
      return Icons.home;
    } else if (lowerNamaKategori.contains('investasi') || lowerNamaKategori.contains('saham')) {
      return Icons.trending_up;
    } else if (lowerNamaKategori.contains('pakaian') || lowerNamaKategori.contains('cloth') || lowerNamaKategori.contains('fashion')) {
      return Icons.checkroom;
    } else if (lowerNamaKategori.contains('hadiah') || lowerNamaKategori.contains('gift')) {
      return Icons.card_giftcard;
    } else if (lowerNamaKategori.contains('hutang') || lowerNamaKategori.contains('pinjaman')) {
      return Icons.money_off;
    } else if (lowerNamaKategori.contains('tabungan') || lowerNamaKategori.contains('saving')) {
      return Icons.savings;
    } else {
      // Icon default jika tidak ada kecocokan
      return Icons.category;
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    super.dispose();
  }
}