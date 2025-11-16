# Alur Analisis Aplikasi Pelacak Keuangan Pribadi

## 1. Alur Umum Pengguna

### A. Registrasi & Login
1. **User membuka aplikasi** → Tampilan awal (Login/Registrasi)
2. **User registrasi** → Input nama, email, password → API `/register` → Token disimpan
3. **User login** → Input email, password → API `/login` → Token disimpan → Navigasi ke Dashboard

### B. Dashboard (Beranda)
1. **User melihat ringkasan keuangan**:
   - Total pemasukan bulan ini
   - Total pengeluaran bulan ini
   - Total tabungan bulan ini
   - Saldo bersih bulan ini
2. **User melihat grafik perbandingan keuangan bulanan**
3. **User melihat 3 transaksi terbaru**

## 2. Alur Pengelolaan Kategori

### A. Melihat Kategori
1. **User menavigasi ke halaman Kategori**
2. **Aplikasi memanggil API** `/categories`
3. **Data kategori ditampilkan dalam list**

### B. Membuat Kategori
1. **User menekan tombol tambah**
2. **User mengisi nama kategori dan jenis (pemasukan/pengeluaran)**
3. **Aplikasi memanggil API** `/categories` (POST)
4. **Aplikasi merefresh data kategori**

### C. Mengedit Kategori
1. **User menekan tombol edit**
2. **User mengubah nama atau jenis kategori**
3. **Aplikasi memanggil API** `/categories/{id}` (PUT)
4. **Aplikasi merefresh data kategori**

### D. Menghapus Kategori
1. **User menekan tombol hapus**
2. **Aplikasi memanggil API** `/categories/{id}` (DELETE)
3. **Aplikasi merefresh data kategori**

## 3. Alur Pengelolaan Transaksi

### A. Melihat Transaksi
1. **User menavigasi ke halaman Transaksi**
2. **Aplikasi memanggil API** `/transactions`
3. **Data transaksi ditampilkan dalam list dengan filter (Semua, Pemasukan, Pengeluaran)**

### B. Membuat Transaksi
1. **User menekan tombol tambah**
2. **User mengisi detail transaksi**:
   - Kategori (dipilih dari kategori tersedia)
   - Jumlah uang
   - Jenis (pemasukan/pengeluaran)
   - Deskripsi
   - Tanggal
3. **Aplikasi memanggil API** `/transactions` (POST)
4. **Aplikasi merefresh data transaksi**
5. **Dashboard diperbarui (total pemasukan/pengeluaran)**

### C. Mengedit Transaksi
1. **User menekan tombol edit**
2. **User mengubah detail transaksi**
3. **Aplikasi memanggil API** `/transactions/{id}` (PUT)
4. **Aplikasi merefresh data transaksi**

### D. Menghapus Transaksi
1. **User menekan tombol hapus**
2. **Aplikasi memanggil API** `/transactions/{id}` (DELETE)
3. **Aplikasi merefresh data transaksi**
4. **Dashboard diperbarui**

## 4. Alur Pengelolaan Anggaran (Budgets)

### A. Melihat Anggaran
1. **User menavigasi ke halaman Anggaran**
2. **Aplikasi memanggil API** `/budgets`
3. **Data anggaran ditampilkan dalam list**

### B. Membuat Anggaran
1. **User menekan tombol tambah**
2. **User memilih kategori dan mengisi jumlah anggaran untuk bulan tertentu**
3. **Aplikasi memanggil API** `/budgets` (POST)
4. **Aplikasi merefresh data anggaran**

### C. Mengedit Anggaran
1. **User menekan tombol edit**
2. **User mengubah jumlah anggaran**
3. **Aplikasi memanggil API** `/budgets/{id}` (PUT)
4. **Aplikasi merefresh data anggaran**

## 5. Alur Pengelolaan Tabungan

### A. Melihat Tabungan
1. **User menavigasi ke halaman Tabungan**
2. **Aplikasi memanggil API** `/savings`
3. **Data tabungan ditampilkan dalam list**

### B. Membuat Tabungan
1. **User menekan tombol tambah**
2. **User mengisi detail tabungan**:
   - Nama tujuan tabungan
   - Jumlah target
   - Jumlah saat ini
   - Tenggat waktu
3. **Aplikasi memanggil API** `/savings` (POST)
4. **Aplikasi merefresh data tabungan**

### C. Mengedit Tabungan
1. **User menekan tombol edit**
2. **User mengubah detail tabungan**
3. **Aplikasi memanggil API** `/savings/{id}` (PUT)
4. **Aplikasi merefresh data tabungan**

## 6. Alur Analisis Data & Laporan

### A. Ringkasan Keuangan Bulanan
1. **Aplikasi memanggil API** `/financial-summary?year={year}&month={month}`
2. **Aplikasi menerima data**:
   - Total pemasukan bulan ini
   - Total pengeluaran bulan ini
   - Total tabungan bulan ini
   - Saldo bersih
3. **Data ditampilkan di Dashboard**

### B. Data Keuangan Bulanan
1. **Aplikasi memanggil API** `/monthly-financial-data?year={year}`
2. **Aplikasi menerima data** untuk grafik perbandingan:
   - Pemasukan per bulan
   - Pengeluaran per bulan
   - Net total per bulan
3. **Data ditampilkan dalam grafik**

### C. Perbandingan Bulanan
1. **Aplikasi menampilkan grafik batang ganda**:
   - Pemasukan vs Pengeluaran per bulan
   - Tren keuangan selama 12 bulan terakhir
2. **User dapat memilih mode tampilan**: Bulanan atau Tahunan

## 7. Alur Logout
1. **User menekan tombol logout di AppBar**
2. **Aplikasi memanggil API** `/logout`
3. **Token dihapus dari local storage**
4. **User diarahkan ke halaman login**

## 8. Analisis Data yang Dilakukan Aplikasi

### A. Analisis Perhitungan Otomatis
1. **Perhitungan saldo** = Total pemasukan - Total pengeluaran
2. **Perhitungan progres tabungan** = (jumlah saat ini / target) * 100
3. **Perhitungan sisa anggaran** = Anggaran - Pengeluaran aktual

### B. Analisis Tren
1. **Tren pemasukan** (naik/turun dibanding bulan sebelumnya)
2. **Tren pengeluaran** (naik/turun dibanding bulan sebelumnya)  
3. **Tren tabungan** (naik/turun dibanding bulan sebelumnya)

### C. Analisis Kategori
1. **Presentase pengeluaran per kategori**
2. **Kategori pengeluaran terbesar**
3. **Kategori pemasukan terbesar**

### D. Analisis Kesehatan Keuangan
1. **Rasio pemasukan:pengeluaran**
2. **Ketepatan pengeluaran terhadap anggaran**
3. **Progres pencapaian target tabungan**

## 9. Flowchart Interaksi Utama

```
User Login
    ↓
Load Dashboard
    ↓
Tampilkan Ringkasan
    ↓
User dapat navigasi ke:
├── Transaksi
├── Kategori  
├── Anggaran
├── Tabungan
└── Ringkasan Keuangan
```

## 10. Fungsi Analisis Spesifik di Dashboard

1. **Total Income**: Jumlah semua transaksi dengan `type='income'` untuk bulan ini
2. **Total Expense**: Jumlah semua transaksi dengan `type='expense'` untuk bulan ini
3. **Net Balance**: `Total Income` - `Total Expense`
4. **Total Saving**: Jumlah semua tabungan saat ini
5. **Recent Transactions**: 3 transaksi terbaru dari database
6. **Monthly Trend**: Perbandingan pemasukan vs pengeluaran per bulan
7. **Budget Tracking**: Perbandingan anggaran vs realisasi pengeluaran per kategori
8. **Saving Progress**: Persentase kemajuan pencapaian target tabungan