/*
 * Patch untuk fungsi askChatbotQuestion di ApiRepository
 * 
 * Perubahan yang perlu dilakukan:
 * 1. Tambahkan fungsi _getToken() untuk mengambil token dari storage
 * 2. Pastikan token diatur sebelum melakukan permintaan ke endpoint yang dilindungi
 */

import 'dart:io';
import 'package:dio/dio.dart';
import '../models/api_models.dart' as Model;
import '../models/api_response.dart' as Response;
import '../config/api_config.dart';
import '../utils/error_handler.dart';
import 'base_repository.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Tambahkan dependency ini

class ApiRepository extends BaseRepository {
  String get baseUrl {
    String url = ApiConfig.baseUrl;
    print('ApiRepository: Current baseUrl is $url');
    return url;
  }

  @override
  void setAuthToken(String? token) {
    super.setAuthToken(token);
  }

  // Fungsi untuk mengambil token dari storage
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

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
  
  // Fungsi lainnya tetap sama...
}