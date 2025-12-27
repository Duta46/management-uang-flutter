class EnvironmentConfig {
  // Gunakan ini untuk mengganti URL tunnel dengan mudah (bisa untuk ngrok atau cloudflare)
  static const String tunnelUrl = String.fromEnvironment('TUNNEL_URL', defaultValue: 'note-grill-spencer-non.trycloudflare.com');

  // Cara penggunaan:
  // 1. Jalankan flutter dengan: flutter run --dart-define=TUNNEL_URL=your-tunnel-url.com
  // 2. Atau untuk build: flutter build apk --dart-define=TUNNEL_URL=your-tunnel-url.com
}