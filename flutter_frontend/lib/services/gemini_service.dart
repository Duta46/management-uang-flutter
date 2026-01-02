import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/**
 * AI Service for financial chatbot using Qwen model via OpenRouter API
 * This service replaces the original Gemini service to use OpenRouter with Qwen model
 */
class GeminiService {
  static String? _apiKey;
  static String? _baseUrl;
  static String? _model;

  static Future<void> _loadConfig() async {
    await dotenv.load(fileName: ".env");
    _apiKey = dotenv.env['OPENAI_API_KEY'];
    _baseUrl = dotenv.env['OPENAI_BASE_URL'];
    _model = dotenv.env['OPENAI_MODEL'];
  }

  static Future<String> sendMessage(String message) async {
    try {
      await _loadConfig();

      if (_apiKey == null || _apiKey!.isEmpty) {
        throw Exception('API key not found. Please check your .env file.');
      }

      if (_baseUrl == null || _baseUrl!.isEmpty) {
        throw Exception('Base URL not found. Please check your .env file.');
      }

      if (_model == null || _model!.isEmpty) {
        throw Exception('Model not found. Please check your .env file.');
      }

      // System prompt for financial assistant
      final systemPrompt = '''
Kamu adalah asisten keuangan pribadi.
Jawaban harus singkat, jelas, dan mudah dipahami.
Jangan memberikan saran investasi berisiko.
Gunakan bahasa Indonesia yang profesional dan ramah.
''';

      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {
              'role': 'system',
              'content': systemPrompt,
            },
            {
              'role': 'user',
              'content': message,
            }
          ],
          'temperature': 0.7,
          'max_tokens': 2048,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final choices = data['choices'];

        if (choices != null && choices.isNotEmpty) {
          final content = choices[0]['message']['content'];
          return content.trim();
        } else {
          throw Exception('Tidak ada jawaban dari AI');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception('Error ${response.statusCode}: ${errorData['error']['message'] ?? errorData['message']}');
      }
    } catch (e) {
      rethrow;
    }
  }
}