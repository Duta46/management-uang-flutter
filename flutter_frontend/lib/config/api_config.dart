class ApiConfig {
  // === Base URL utama pakai NGROK ===
  static const String realDevice = 'https://4b9d5b6cfa31.ngrok-free.app/api';

  // Emulator & development lokal (optional)
  static const String androidEmulator = 'http://10.0.2.2:8000/api';
  static const String iosSimulator = 'http://localhost:8000/api';
  static const String development = 'http://127.0.0.1:8000/api';

  // Getter untuk base URL aktif 
  // Gunakan development untuk lokal (laragon), 
  // androidEmulator untuk emulator Android, 
  // realDevice untuk perangkat fisik
  static String get baseUrl {
    // Ini bisa dikonfigurasi lebih lanjut tergantung kebutuhan
    // Untuk development lokal dengan Laragon, gunakan development
    // Untuk perangkat fisik saat ini, gunakan realDevice (ngrok)
    return realDevice; // Ubah ke realDevice untuk menggunakan ngrok
  }

  // Optional: untuk dinamis switch berdasarkan lingkungan
  static String getBaseURL() {
    // Anda bisa mengganti ini tergantung kebutuhan lingkungan
    String env = const String.fromEnvironment('FLUTTER_ENV', defaultValue: 'development');
    switch (env) {
      case 'android_emulator':
        return androidEmulator;
      case 'ios_simulator':
        return iosSimulator;
      case 'real_device': // Tambahkan case untuk perangkat fisik
      case 'production':
        return realDevice;
      case 'development':
      default:
        return development;
    }
  }
}
