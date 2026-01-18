import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bantuan'),
        backgroundColor: Theme.of(context).cardTheme.color,
        foregroundColor: Theme.of(context).textTheme.titleLarge?.color,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildHelpSection(
              'Bagaimana Cara Menambah Transaksi?',
              '1. Ketuk tombol "+" di beranda\n2. Pilih jenis transaksi (pemasukan/pengeluaran)\n3. Masukkan jumlah uang\n4. Pilih kategori atau buat kategori baru\n5. Tambahkan deskripsi jika perlu\n6. Simpan transaksi',
              Icons.add,
              context,
            ),
            _buildHelpSection(
              'Bagaimana Cara Membuat Anggaran?',
              '1. Buka menu "Anggaran"\n2. Ketuk tombol "+" untuk menambah anggaran\n3. Pilih kategori\n4. Masukkan jumlah anggaran\n5. Pilih bulan yang sesuai\n6. Simpan anggaran',
              Icons.pie_chart,
              context,
            ),
            _buildHelpSection(
              'Bagaimana Cara Membuat Tujuan Tabungan?',
              '1. Buka menu "Tabungan"\n2. Ketuk tombol "+" untuk menambah tujuan tabungan\n3. Beri nama tujuan tabungan\n4. Masukkan jumlah target\n5. Masukkan jumlah saat ini\n6. Atur tenggat waktu\n7. Simpan tujuan tabungan',
              Icons.savings,
              context,
            ),
            _buildHelpSection(
              'Bagaimana Cara Mengatur Kategori?',
              '1. Buka menu "Kategori"\n2. Untuk menambah kategori, ketuk tombol "+" di pojok kanan atas\n3. Untuk mengedit atau menghapus, ketuk pada kategori yang ingin diubah',
              Icons.category,
              context,
            ),
            _buildHelpSection(
              'Apa itu Pengingat Tagihan?',
              'Pengingat tagihan membantu Anda mengingat pembayaran rutin seperti listrik, air, atau cicilan. Anda bisa mengaturnya dengan:\n1. Buka menu "Pengingat Tagihan"\n2. Ketuk tombol "+" untuk menambah pengingat\n3. Isi detail tagihan dan frekuensinya',
              Icons.notifications_active,
              context,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpSection(String title, String description, IconData icon, BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              description,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}