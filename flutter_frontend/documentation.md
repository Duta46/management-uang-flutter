# Dokumentasi Perubahan Aplikasi Flutter Finance

## Daftar Isi
1. [Perbaikan Error Import](#perbaikan-error-import)
2. [Perbaikan Tampilan ke Bahasa Indonesia](#perbaikan-tampilan-ke-bahasa-indonesia)
3. [Perbaikan Format Angka ke Format Indonesia](#perbaikan-format-angka-ke-format-indonesia)
4. [Perbaikan Tampilan Chart Transaction](#perbaikan-tampilan-chart-transaction)
5. [Perbaikan Tampilan Beranda](#perbaikan-tampilan-beranda)
6. [Perbaikan Tampilan Transaksi Terbaru](#perbaikan-tampilan-transaksi-terbaru)

## Perbaikan Error Import

### Masalah
- File `main_navigation_screen.dart` mengimport `category_chart_screen.dart` yang tidak ada
- Menyebabkan error saat build: `Error: Error when reading 'lib/screens/category_chart_screen.dart': The system cannot find the file specified.`

### Solusi
- Menghapus import statement `category_chart_screen.dart` dari `main_navigation_screen.dart`
- File tersebut tidak diperlukan karena tidak ada dalam struktur direktori

### File yang Diubah
- `lib/screens/home/main_navigation_screen.dart`

## Perbaikan Tampilan ke Bahasa Indonesia

### Masalah
- Tampilan aplikasi menggunakan bahasa Inggris
- Perlu diubah ke bahasa Indonesia sesuai permintaan

### Solusi
- Mengganti semua teks dalam aplikasi ke bahasa Indonesia
- Mengganti label, judul, dan deskripsi ke bahasa Indonesia

### File yang Diubah
- `lib/screens/home/home_screen.dart`
- `lib/screens/transaction_chart_screen.dart`

### Perubahan Teks
#### Home Screen
- "Personal Finance" → "Keuangan Pribadi"
- "Hello, Welcome Back!" → "Halo, Selamat Datang Kembali!"
- "Track your finances with ease" → "Lacak keuangan Anda dengan mudah"
- "Total Balance" → "Saldo Total"
- "Income" → "Pemasukan"
- "Expense" → "Pengeluaran"
- "Logout" → "Keluar"
- "Reports & Charts" → "Laporan & Grafik"
- "Transaction Chart" → "Grafik Transaksi"
- "Monthly overview" → "Ringkasan bulanan"
- "Recent Transactions" → "Transaksi Terbaru"
- "No transactions yet" → "Belum ada transaksi"

#### Transaction Chart Screen
- "Transaction Chart" → "Grafik Transaksi"
- "Daily Overview" → "Ringkasan Harian"
- "Daily Transaction Overview" → "Ringkasan Transaksi Harian"
- "Income" → "Pemasukan"
- "Expense" → "Pengeluaran"
- "Net" → "Bersih"

## Perbaikan Format Angka ke Format Indonesia

### Masalah
- Format angka menggunakan format internasional (tanpa pemisah ribuan)
- Perlu menggunakan format Indonesia dengan titik sebagai pemisah ribuan

### Solusi
- Menambahkan fungsi `_formatCurrency` di kedua file untuk memformat angka
- Mengganti semua tampilan angka dengan format Indonesia

### Fungsi yang Ditambahkan
```dart
String _formatCurrency(double amount) {
  // Format angka dengan pemisah ribuan menggunakan titik
  String formatted = amount.abs().toStringAsFixed(0);
  RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
  formatted = formatted.replaceAllMapped(reg, (Match m) => '${m[1]}.');
  return amount < 0 ? '-$formatted' : formatted;
}
```

### File yang Diubah
- `lib/screens/home/home_screen.dart`
- `lib/screens/transaction_chart_screen.dart`

### Perubahan Format Angka
- `transactionProvider.balance.toStringAsFixed(0)` → `_formatCurrency(transactionProvider.balance)`
- `transactionProvider.income.toStringAsFixed(0)` → `_formatCurrency(transactionProvider.income)`
- `transactionProvider.expense.toStringAsFixed(0)` → `_formatCurrency(transactionProvider.expense)`
- `transaction.amount` → `_formatCurrency(transaction.amount)`

## Perbaikan Tampilan Chart Transaction

### Masalah
- Chart tidak muncul meskipun data transaksi berhasil dimuat
- Data chart menggunakan `TransactionReportService` bukan `TransactionProvider`
- Chart tidak menampilkan data yang seharusnya

### Solusi
- Mengganti penggunaan `TransactionReportService` dengan `TransactionProvider`
- Menggunakan data dari `TransactionProvider` untuk menampilkan chart
- Memastikan chart hanya dirender saat data tersedia

### File yang Diubah
- `lib/screens/transaction_chart_screen.dart`

### Perubahan Implementasi
- Mengganti `TransactionReportService.getMonthlyTransactions()` dengan data dari `TransactionProvider`
- Menggunakan `Consumer<TransactionProvider>` untuk mendapatkan data transaksi
- Menambahkan pengecekan loading state dan error state
- Menggunakan field `date` dari transaksi untuk menampilkan data chart

## Perbaikan Tampilan Beranda

### Masalah
- Bagian "Laporan & Grafik" di halaman beranda tidak perlu ditampilkan
- Mengganggu tampilan dan fokus pengguna

### Solusi
- Menghapus bagian "Laporan & Grafik" dari halaman beranda
- Menjaga fokus pada informasi utama seperti saldo dan transaksi terbaru

### File yang Diubah
- `lib/screens/home/home_screen.dart`

### Perubahan
- Menghapus widget `GridView.count` yang menampilkan kartu grafik
- Menghapus bagian header "Laporan & Grafik"
- Mengganti margin untuk menjaga tata letak yang baik

## Perbaikan Tampilan Transaksi Terbaru

### Masalah
- Tampilan transaksi terbaru menampilkan semua data
- Perlu dibatasi hanya menampilkan 3 data terbaru

### Solusi
- Membatasi jumlah transaksi yang ditampilkan menjadi 3 data terbaru
- Menjaga tampilan yang bersih dan tidak terlalu panjang

### File yang Diubah
- `lib/screens/home/home_screen.dart`

### Perubahan
- Mengganti `transactionProvider.transactions.length > 5 ? 5 : transactionProvider.transactions.length` menjadi `transactionProvider.transactions.length > 3 ? 3 : transactionProvider.transactions.length`
- Menampilkan maksimal 3 transaksi terbaru di beranda

## Catatan Tambahan

### Struktur Data
- Aplikasi menggunakan `Provider` untuk state management
- Data transaksi diambil dari API backend melalui `TransactionProvider`
- Format tanggal menggunakan format ISO 8601
- Field `date` digunakan untuk menentukan tanggal transaksi (bukan `created_at`)

### Format Angka
- Format angka menggunakan titik (.) sebagai pemisah ribuan
- Contoh: 68.000.000 (bukan 68,000,000)
- Format ini sesuai dengan standar Indonesia

### Bahasa Aplikasi
- Semua teks dalam aplikasi sekarang menggunakan bahasa Indonesia
- Termasuk pesan error, tombol, dan label
- Meningkatkan pengalaman pengguna lokal