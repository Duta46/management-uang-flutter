# Dokumentasi Teknis Aplikasi Personal Finance Tracker

## Gambaran Umum
Aplikasi ini adalah aplikasi pelacak keuangan pribadi yang dibangun dengan arsitektur full-stack menggunakan Laravel di backend dan Flutter di frontend. Aplikasi ini memungkinkan pengguna untuk mengelola transaksi keuangan, anggaran, tabungan, dan pengingat tagihan.

## Arsitektur Aplikasi

### Backend (Laravel)
- **Framework**: Laravel 12
- **Bahasa**: PHP 8.2+
- **Database**: MySQL
- **Authentication**: Laravel Sanctum
- **Authorization**: Spatie Laravel Permission
- **API**: RESTful API dengan JSON response

### Frontend (Flutter)
- **Framework**: Flutter
- **Bahasa**: Dart
- **State Management**: Provider
- **HTTP Client**: http package
- **Date/Time**: intl package

## Struktur Proyek

### Backend Structure
```
backend/
├── app/
│   ├── Http/
│   │   ├── Controllers/
│   │   ├── Middleware/
│   │   └── Resources/
│   ├── Models/
│   ├── Providers/
│   └── Services/
├── config/
├── database/
│   ├── factories/
│   ├── migrations/
│   └── seeders/
├── public/
├── resources/
├── routes/
└── storage/
```

### Frontend Structure
```
flutter_frontend/
├── lib/
│   ├── config/
│   ├── models/
│   ├── providers/
│   ├── repositories/
│   ├── screens/
│   │   ├── auth/
│   │   ├── bill_reminder/
│   │   ├── budget/
│   │   ├── categories/
│   │   ├── financial_health/
│   │   ├── financial_insights/
│   │   ├── financial_notifications/
│   │   ├── financial_predictions/
│   │   ├── financial_recommendations/
│   │   ├── home/
│   │   ├── reports/
│   │   ├── savings/
│   │   ├── transactions/
│   │   └── widgets/
│   ├── services/
│   ├── theme/
│   ├── utils/
│   └── widgets/
├── pubspec.yaml
└── README.md
```

## Komponen Utama

### 1. Authentication System
- **Login/Register**: Menggunakan email dan password
- **Social Login**: Mendukung Google OAuth
- **Token Management**: Laravel Sanctum untuk autentikasi API
- **Role-based Access Control**: Admin/User roles

### 2. Mapping Menu, Controller, Service, dan Repository

#### Authentication
- **Menu**: Login, Register
- **Flutter Screens**: `lib/screens/auth/login_screen.dart`, `lib/screens/auth/register_screen.dart`
- **Backend Controller**: `app/Http/Controllers/AuthController.php`
- **Backend Service**: `app/Services/AuthService.php`
- **Backend Repository**: `app/Repositories/UserRepository.php`

#### Dashboard
- **Menu**: Dashboard Utama
- **Flutter Screen**: `lib/screens/home/financial_dashboard_screen.dart`
- **Backend Controller**: `app/Http/Controllers/DashboardController.php`
- **Backend Service**: `app/Services/DashboardService.php`
- **Backend Repository**: `app/Repositories/DashboardRepository.php`

#### Transaksi
- **Menu**: Daftar Transaksi, Tambah/Edit Transaksi
- **Flutter Screens**:
  - `lib/screens/transactions/transaction_list_screen.dart`
  - `lib/screens/transactions/transaction_form_screen.dart`
- **Backend Controller**: `app/Http/Controllers/TransactionController.php`
- **Backend Service**: `app/Services/TransactionService.php`
- **Backend Repository**: `app/Repositories/TransactionRepository.php`
- **Flutter Provider**: `lib/providers/transaction_provider_change_notifier.dart`

#### Kategori
- **Menu**: Daftar Kategori, Tambah/Edit Kategori
- **Flutter Screens**: `lib/screens/categories/category_list_screen.dart`
- **Backend Controller**: `app/Http/Controllers/CategoryController.php`
- **Backend Service**: `app/Services/CategoryService.php`
- **Backend Repository**: `app/Repositories/CategoryRepository.php`
- **Flutter Provider**: `lib/providers/category_provider_change_notifier.dart`

#### Anggaran (Budget)
- **Menu**: Daftar Anggaran, Tambah/Edit Anggaran
- **Flutter Screens**:
  - `lib/screens/budget/budget_screen.dart`
  - `lib/screens/budget/add_budget_screen.dart`
  - `lib/screens/budget/edit_budget_screen.dart`
- **Backend Controller**: `app/Http/Controllers/BudgetController.php`
- **Backend Service**: `app/Services/BudgetService.php`
- **Backend Repository**: `app/Repositories/BudgetRepository.php`
- **Flutter Provider**: `lib/providers/budget_provider.dart`

#### Tabungan (Savings Goals)
- **Menu**: Daftar Tabungan, Tambah/Edit Tujuan Tabungan
- **Flutter Screens**:
  - `lib/screens/savings/savings_goal_screen.dart`
  - `lib/screens/savings/add_savings_goal_screen.dart`
  - `lib/screens/savings/edit_savings_goal_screen.dart`
- **Backend Controller**: `app/Http/Controllers/SavingsGoalController.php`
- **Backend Service**: `app/Services/SavingsGoalService.php`
- **Backend Repository**: `app/Repositories/SavingsGoalRepository.php`
- **Flutter Provider**: `lib/providers/savings_goal_provider.dart`

#### Pengingat Tagihan (Bill Reminders)
- **Menu**: Daftar Pengingat Tagihan, Tambah/Edit Pengingat Tagihan
- **Flutter Screens**:
  - `lib/screens/bill_reminder/bill_reminder_screen.dart`
  - `lib/screens/bill_reminder/add_bill_reminder_screen.dart`
  - `lib/screens/bill_reminder/edit_bill_reminder_screen.dart`
- **Backend Controller**: `app/Http/Controllers/BillReminderController.php`
- **Backend Service**: `app/Services/BillReminderService.php`
- **Backend Repository**: `app/Repositories/BillReminderRepository.php`
- **Flutter Provider**: `lib/providers/bill_reminder_provider.dart`

#### Laporan Keuangan
- **Menu**: Laporan Keuangan
- **Flutter Screen**: `lib/screens/reports/financial_report_screen.dart`
- **Backend Controller**: `app/Http/Controllers/FinancialReportController.php`
- **Backend Service**: `app/Services/FinancialReportService.php`
- **Backend Repository**: `app/Repositories/FinancialReportRepository.php`
- **Flutter Provider**: `lib/providers/financial_report_provider.dart`

#### Kesehatan Keuangan
- **Menu**: Kesehatan Keuangan
- **Flutter Screen**: `lib/screens/financial_health/financial_health_screen.dart`
- **Backend Controller**: `app/Http/Controllers/FinancialHealthController.php`
- **Backend Service**: `app/Services/FinancialHealthService.php`
- **Backend Repository**: `app/Repositories/FinancialHealthRepository.php`
- **Flutter Provider**: `lib/providers/financial_health_provider.dart`

#### Wawasan Keuangan (AI - Coming Soon)
- **Menu**: Wawasan Keuangan
- **Flutter Screen**: `lib/screens/coming_soon_screen.dart`
- **Backend Controller**: `app/Http/Controllers/FinancialInsightsController.php`
- **Backend Service**: `app/Services/FinancialInsightsService.php`
- **Backend Repository**: `app/Repositories/FinancialInsightsRepository.php`
- **Flutter Provider**: `lib/providers/financial_insights_provider.dart`

#### Rekomendasi Keuangan (AI - Coming Soon)
- **Menu**: Rekomendasi Keuangan
- **Flutter Screen**: `lib/screens/coming_soon_screen.dart`
- **Backend Controller**: `app/Http/Controllers/FinancialRecommendationsController.php`
- **Backend Service**: `app/Services/FinancialRecommendationsService.php`
- **Backend Repository**: `app/Repositories/FinancialRecommendationsRepository.php`
- **Flutter Provider**: `lib/providers/financial_recommendations_provider.dart`

#### Prediksi Keuangan (AI - Coming Soon)
- **Menu**: Prediksi Keuangan
- **Flutter Screen**: `lib/screens/coming_soon_screen.dart`
- **Backend Controller**: `app/Http/Controllers/FinancialPredictionsController.php`
- **Backend Service**: `app/Services/FinancialPredictionsService.php`
- **Backend Repository**: `app/Repositories/FinancialPredictionsRepository.php`
- **Flutter Provider**: `lib/providers/financial_predictions_provider.dart`

### 3. Fitur Keuangan
#### Transaksi
- CRUD operasi untuk transaksi
- Kategorisasi (pemasukan/pengeluaran)
- Penjadwalan transaksi
- Filter dan pencarian

#### Anggaran (Budget)
- Pembuatan anggaran berdasarkan kategori
- Pelacakan penggunaan anggaran
- Visualisasi progres

#### Tabungan (Savings Goals)
- Pembuatan tujuan tabungan
- Pelacakan kemajuan
- Estimasi waktu pencapaian

#### Pengingat Tagihan (Bill Reminders)
- Pembuatan pengingat tagihan
- Pengelompokan berdasarkan frekuensi
- Status pembayaran

### 4. Dashboard dan Laporan
- Ringkasan keuangan harian/mingguan/bulanan
- Grafik dan visualisasi data
- Rekomendasi keuangan (fitur AI - dalam pengembangan)
- Prediksi keuangan (fitur AI - dalam pengembangan)

## State Management

### Flutter State Management
Aplikasi menggunakan Provider pattern untuk manajemen state:

- **ChangeNotifierProvider**: Untuk state yang kompleks seperti transaksi, anggaran, dll
- **Consumer**: Untuk mengakses state di widget
- **MultiProvider**: Untuk menyediakan beberapa provider sekaligus

### Contoh Provider
```dart
class TransactionProvider extends ChangeNotifier {
  List<Transaction> _transactions = [];
  bool _isLoading = false;
  
  // Getter methods
  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  
  // Business logic methods
  Future<bool> fetchTransactions() async {
    // Implementation
  }
  
  Future<bool> createTransaction() async {
    // Implementation
  }
}
```

## API Integration

### HTTP Requests
Aplikasi menggunakan http package untuk komunikasi dengan backend:

- **Base URL**: Didapatkan dari EnvironmentConfig
- **Headers**: Authorization token, Content-Type
- **Error Handling**: Response validation dan error messaging

### Environment Configuration
- **Tunnel URL**: Dapat diubah melalui `--dart-define=TUNNEL_URL`
- **Default**: Menggunakan Cloudflare Tunnel untuk akses eksternal

## Model dan API Endpoints

### Model Utama
#### User
- **File**: `app/Models/User.php`
- **Fields**: id, name, email, password, role, profile_photo, created_at, updated_at
- **Relationships**: HasMany transactions, budgets, savings_goals, bill_reminders

#### Transaction
- **File**: `app/Models/Transaction.php`
- **Fields**: id, user_id, category_id, amount, type, description, date, created_at, updated_at
- **Relationships**: BelongsTo user, BelongsTo category

#### Category
- **File**: `app/Models/Category.php`
- **Fields**: id, user_id, name, type, created_at, updated_at
- **Relationships**: BelongsTo user, HasMany transactions

#### Budget
- **File**: `app/Models/Budget.php`
- **Fields**: id, user_id, category_id, amount, month, created_at, updated_at
- **Relationships**: BelongsTo user, BelongsTo category

#### SavingsGoal
- **File**: `app/Models/SavingsGoal.php`
- **Fields**: id, user_id, name, description, target_amount, current_amount, target_date, status, created_at, updated_at
- **Relationships**: BelongsTo user

#### BillReminder
- **File**: `app/Models/BillReminder.php`
- **Fields**: id, user_id, name, description, amount, due_date, frequency, is_paid, is_active, created_at, updated_at
- **Relationships**: BelongsTo user

### API Endpoints
#### Authentication
- `POST /api/register` - Registrasi pengguna baru
- `POST /api/login` - Login pengguna
- `POST /api/logout` - Logout pengguna
- `GET /api/user` - Mendapatkan informasi pengguna saat ini

#### Categories
- `GET /api/categories` - Mendapatkan daftar kategori
- `POST /api/categories` - Membuat kategori baru
- `PUT /api/categories/{id}` - Memperbarui kategori
- `DELETE /api/categories/{id}` - Menghapus kategori

#### Transactions
- `GET /api/transactions` - Mendapatkan daftar transaksi
- `POST /api/transactions` - Membuat transaksi baru
- `PUT /api/transactions/{id}` - Memperbarui transaksi
- `DELETE /api/transactions/{id}` - Menghapus transaksi

#### Budgets
- `GET /api/budgets` - Mendapatkan daftar anggaran
- `POST /api/budgets` - Membuat anggaran baru
- `PUT /api/budgets/{id}` - Memperbarui anggaran
- `DELETE /api/budgets/{id}` - Menghapus anggaran

#### Savings Goals
- `GET /api/savings-goals` - Mendapatkan daftar tujuan tabungan
- `POST /api/savings-goals` - Membuat tujuan tabungan baru
- `PUT /api/savings-goals/{id}` - Memperbarui tujuan tabungan
- `DELETE /api/savings-goals/{id}` - Menghapus tujuan tabungan

#### Bill Reminders
- `GET /api/bill-reminders` - Mendapatkan daftar pengingat tagihan
- `POST /api/bill-reminders` - Membuat pengingat tagihan baru
- `PUT /api/bill-reminders/{id}` - Memperbarui pengingat tagihan
- `DELETE /api/bill-reminders/{id}` - Menghapus pengingat tagihan

## UI/UX Components

### Theme System
- **AppTheme**: Kelas singleton untuk manajemen warna dan gaya
- **Consistent Design**: Gradient biru-ungu khas aplikasi
- **Responsive Layout**: Mendukung berbagai ukuran layar

### Screen Architecture
- **Gradient Background**: Digunakan di semua halaman
- **Card-based UI**: Untuk elemen-elemen interaktif
- **Consistent Navigation**: Back button dan header style

## Security Features

### Backend Security
- **Input Validation**: Validasi input di level request
- **SQL Injection Prevention**: Menggunakan Eloquent ORM
- **XSS Protection**: Sanitasi output
- **Rate Limiting**: Terhadap endpoint sensitif

### Frontend Security
- **Token Storage**: Disimpan di secure storage
- **Sensitive Data**: Tidak disimpan di lokal
- **Network Security**: HTTPS enforcement

## Deployment

### Backend Deployment
- **Server**: Apache/Nginx + PHP 8.2+
- **Database**: MySQL 8.0+
- **Environment**: Production configuration

### Frontend Deployment
- **Platforms**: Android, iOS, Web
- **Build Configuration**: Release builds dengan minifikasi
- **Distribution**: APK/IPA files

## Development Best Practices

### Code Organization
- **Separation of Concerns**: Model, View, Controller terpisah
- **Clean Architecture**: Layered architecture
- **Modular Design**: Fitur-fitur terorganisir dalam modul

### Testing
- **Unit Tests**: Untuk business logic
- **Integration Tests**: Untuk API endpoints
- **UI Tests**: Untuk critical user flows

### Documentation
- **Inline Comments**: Untuk fungsi kompleks
- **API Documentation**: Melalui response examples
- **Setup Guide**: Untuk developer baru

## Dependencies

### Backend Dependencies
- Laravel Framework
- Spatie Laravel Permission
- Laravel Sanctum
- Laravel Socialite (Google OAuth)

### Frontend Dependencies
- Provider (state management)
- Http (networking)
- Intl (internationalization)
- Image Picker (profile pictures)

## Troubleshooting

### Common Issues
- **API Connection**: Pastikan URL backend benar
- **Authentication**: Token mungkin expired
- **Database Sync**: Pastikan migrasi telah dijalankan

### Debugging Tips
- **Log Files**: Cek storage/logs/laravel.log
- **Network Calls**: Gunakan Flutter DevTools
- **State Issues**: Gunakan Provider debugging tools

## Future Enhancements

### Planned Features
- AI-powered insights
- Machine learning predictions
- Advanced reporting
- Multi-currency support

### Technical Improvements
- Modular architecture
- Better error handling
- Enhanced caching
- Performance optimizations