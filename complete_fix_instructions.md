# Perbaikan untuk Error HTTP 500 pada Endpoint Chatbot

## Masalah Utama
Aplikasi mengalami error HTTP 500 saat mengakses endpoint `/api/chatbot/ask` dari Flutter frontend ke Laravel backend. Setelah investigasi lebih lanjut, ditemukan dua masalah utama:

### 1. Error Sintaks PHP (ParseError)
- Terdapat error di file `app/Services/FinancialChatbotService.php` di baris sekitar 845
- Ada bagian kode yang salah tempat atau duplikat di luar fungsi yang valid
- Ini menyebabkan ParseError yang membuat seluruh aplikasi Laravel tidak dapat berjalan dengan benar

### 2. Masalah Otentikasi Sanctum
- Endpoint `/api/chatbot/ask` dilindungi oleh middleware `auth:sanctum`
- Permintaan dari Flutter frontend dikirim tanpa token otentikasi yang valid
- Ini menyebabkan Laravel merespons dengan status 401 (Unauthenticated)
- Yang kemudian ditangani oleh controller dan menghasilkan error 500

## Solusi yang Telah Diterapkan

### 1. Perbaikan Error Sintaks PHP
- Mengidentifikasi dan menghapus bagian kode yang salah tempat di file `FinancialChatbotService.php`
- Memastikan semua fungsi dan kelas ditutup dengan benar
- File sekarang lolos dari pemeriksaan sintaks PHP (`php -l`)

### 2. Panduan Perbaikan Otentikasi Sanctum
Harap terapkan perubahan berikut di Flutter frontend:

#### A. Simpan token setelah login
Di file yang menangani proses login (misalnya `auth_service.dart` atau `auth_provider.dart`), tambahkan kode untuk menyimpan token:

```dart
// Setelah login berhasil
final token = response.data['data']['token']; // Sesuaikan dengan struktur respons API Anda
final prefs = await SharedPreferences.getInstance();
await prefs.setString('auth_token', token);
```

#### B. Perbarui ApiRepository
Ubah fungsi `askChatbotQuestion` di `api_repository.dart` untuk memastikan token diatur sebelum permintaan:

```dart
/*
 * Ask a question to the financial chatbot
 * Uses Qwen AI model via OpenRouter API for financial advice
 */
Future<Response.ApiResponse> askChatbotQuestion(String question) async {
  try {
    print('Making request to: $baseUrl/chatbot/ask');
    print('Request data: {"question": "$question"}');

    // Pastikan token otentikasi telah diatur sebelum melakukan permintaan
    final token = await _getToken();
    if (token != null) {
      setAuthToken(token);
    } else {
      print('Warning: No authentication token found!');
      // Mungkin perlu redirect ke halaman login
    }

    final response = await dio.post(
      '$baseUrl/chatbot/ask',
      data: {
        'question': question,
      },
    );

    print('Received response: ${response.data}');
    print('Response status: ${response.statusCode}');

    return Response.ApiResponse.fromJson(response.data);
  } catch (e, stackTrace) {
    print('Error in askChatbotQuestion: $e');
    final exception = ErrorHandler.handle(e, stackTrace);
    return Response.ApiResponse.error(message: exception.message);
  }
}

// Fungsi untuk mengambil token dari storage
Future<String?> _getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('auth_token');
}
```

### 3. Tambahkan Dependency
Pastikan dependency `shared_preferences` ditambahkan ke `pubspec.yaml`:

```yaml
dependencies:
  shared_preferences: ^2.2.2
  # dependency lainnya...
```

Lalu jalankan `flutter pub get` untuk menginstal dependency baru.

## Testing
Setelah menerapkan perubahan:
1. Jalankan ulang server Laravel
2. Lakukan login di aplikasi Flutter
3. Verifikasi bahwa token disimpan di SharedPreferences
4. Coba kirim pertanyaan ke chatbot
5. Periksa log untuk memastikan permintaan sekarang menyertakan header Authorization

## Catatan Penting
- Error sintaks PHP telah diperbaiki dan aplikasi backend sekarang seharusnya berjalan tanpa error
- Namun, Anda masih perlu menerapkan perubahan otentikasi Sanctum di Flutter frontend agar endpoint chatbot dapat diakses dengan benar
- Endpoint chatbot memerlukan otentikasi yang valid untuk dapat digunakan