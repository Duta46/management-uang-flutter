import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/api_response.dart';
import '../models/category.dart';

class ApiService {
  static const String _tokenKey = 'user_token';
  static String? _token;

  // Initialize token from shared preferences
  static Future<void> initialize() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
  }

  // Save token to shared preferences
  static Future<void> saveToken(String? token) async {
    _token = token;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (token != null) {
      await prefs.setString(_tokenKey, token);
    } else {
      await prefs.remove(_tokenKey);
    }
  }

  // Get current token
  static String? getToken() {
    return _token;
  }

  // Clear token
  static Future<void> clearToken() async {
    _token = null;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // Get headers with authorization
  static Future<Map<String, String>> getHeaders() async {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }

    return headers;
  }


  // Category methods
  static Future<ApiResponse> getCategories() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/categories'),
        headers: await getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ApiResponse.fromJson(data);
      } else {
        return ApiResponse(
          success: false,
          message: 'Error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Network error: $e',
      );
    }
  }

  static Future<ApiResponse> createCategory(String name, String type) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/categories'),
        headers: await getHeaders(),
        body: jsonEncode({
          'name': name,
          'type': type,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return ApiResponse.fromJson(data);
      } else {
        return ApiResponse(
          success: false,
          message: 'Error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Network error: $e',
      );
    }
  }
}