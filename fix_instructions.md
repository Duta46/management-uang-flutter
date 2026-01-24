# Petunjuk Perbaikan untuk Mengatasi Error HTTP 500 pada Endpoint Chatbot

## Masalah
Error HTTP 500 terjadi saat mengakses endpoint `/api/chatbot/ask` dari Flutter frontend ke Laravel backend. Berdasarkan log Flutter, permintaan gagal dengan pesan "Terjadi kesalahan server. Silakan coba lagi nanti."

## Penyebab
Endpoint `/api/chatbot/ask` dilindungi oleh middleware `auth:sanctum` di Laravel, yang memerlukan token otentikasi Sanctum yang valid. Namun, permintaan dari Flutter frontend dikirim tanpa header Authorization, menyebabkan Laravel merespons dengan status 401 (Unauthenticated), yang kemudian ditangani oleh controller dan menghasilkan error 500.

## Solusi

### 1. Di Flutter Frontend
Pastikan token otentikasi Sanctum disimpan setelah login dan digunakan dalam permintaan ke endpoint yang dilindungi:

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

### 2. Di Laravel Backend
Konfigurasi CORS sudah benar dan mencakup domain yang digunakan oleh Flutter frontend.

### 3. Testing
Setelah menerapkan perubahan:
1. Lakukan login di aplikasi Flutter
2. Verifikasi bahwa token disimpan di SharedPreferences
3. Coba kirim pertanyaan ke chatbot
4. Periksa log untuk memastikan permintaan sekarang menyertakan header Authorization

## Tambahan
Pastikan juga dependency `shared_preferences` ditambahkan ke `pubspec.yaml`:

```yaml
dependencies:
  shared_preferences: ^2.2.2
  # dependency lainnya...
```

Lalu jalankan `flutter pub get` untuk menginstal dependency baru.