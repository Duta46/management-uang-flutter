import 'environment_config.dart';

class ApiConfig {
  // === Base URL utama pakai TUNNEL ===
  // Ganti ini setiap kali URL tunnel berubah menggunakan TUNNEL_URL environment variable
  static String get realDevice {
    String tunnelUrl = const String.fromEnvironment('TUNNEL_URL', defaultValue: 'default');
    // Jika TUNNEL_URL diatur dan bukan default, gunakan itu
    if (tunnelUrl != 'default' && tunnelUrl.isNotEmpty) {
      // Tambahkan https jika tidak ada skema
      if (!tunnelUrl.startsWith('http://') && !tunnelUrl.startsWith('https://')) {
        tunnelUrl = 'https://$tunnelUrl';
      }
      return '${tunnelUrl}/api';
    } else {
      // Jika tidak, gunakan EnvironmentConfig.tunnelUrl (fallback)
      String fallbackUrl = EnvironmentConfig.tunnelUrl;
      if (!fallbackUrl.startsWith('http://') && !fallbackUrl.startsWith('https://')) {
        fallbackUrl = 'https://$fallbackUrl';
      }
      return '${fallbackUrl}/api';
    }
  }

  // Emulator & development lokal (optional)
  static const String androidEmulator = 'http://10.0.2.2:8000/api';
  static const String iosSimulator = 'http://localhost:8000/api';
  static const String development = 'http://127.0.0.1:8000/api';

  // Getter untuk base URL aktif
  // Gunakan development untuk lokal (laragon),
  // androidEmulator untuk emulator Android,
  // realDevice untuk perangkat fisik
  static String get baseUrl {
    // Cek apakah TUNNEL_URL disetel secara eksplisit (bukan default), jika ya, gunakan realDevice
    String tunnelUrl = const String.fromEnvironment('TUNNEL_URL', defaultValue: 'default');
    if (tunnelUrl != 'default' && tunnelUrl.isNotEmpty) {
      return realDevice;
    }

    // Ini bisa dikonfigurasi lebih lanjut tergantung kebutuhan
    // Untuk development lokal dengan Laragon, gunakan development
    // Untuk perangkat fisik saat ini, gunakan realDevice (ngrok)
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

  // Optional: untuk dinamis switch berdasarkan lingkungan
  static String getBaseURL() {
    // Cek apakah TUNNEL_URL disetel secara eksplisit (bukan default), jika ya, gunakan realDevice
    String tunnelUrl = const String.fromEnvironment('TUNNEL_URL', defaultValue: 'default');
    if (tunnelUrl != 'default' && tunnelUrl.isNotEmpty) {
      return realDevice;
    }

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
