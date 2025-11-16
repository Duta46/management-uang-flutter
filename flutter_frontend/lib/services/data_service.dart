import 'dart:convert';
import 'dart:io'; // Tambahkan ini untuk timeout
import 'dart:async'; // Tambahkan ini untuk TimeoutException
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/user.dart';
import '../models/category.dart';
import '../models/transaction.dart';
import '../models/budget.dart';
import '../models/saving.dart';
import '../models/api_response.dart';
import '../models/financial_summary.dart';

class DataService {
  static const String _tokenKey = 'user_token';
  static String? _token;

  // Menambahkan timeout default
  static const Duration _timeout = Duration(seconds: 30); // 30 detik timeout

  static Future<Map<String, String>> getHeaders() async {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
      print("Token digunakan: ${_token!.substring(0, 10)}..."); // Debug log
    } else {
      print("Token tidak tersedia!"); // Debug log
    }

    return headers;
  }

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

  // Authentication methods
  static Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/register'),
        headers: await getHeaders(),
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        }),
      ).timeout(_timeout);

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final data = jsonDecode(response.body);
        return AuthResponse.fromJson(data);
      } else {
        return AuthResponse(
          success: false,
          message: 'Error: ${response.statusCode} - ${response.body.isEmpty ? "Empty response" : response.body}',
        );
      }
    } catch (e) {
      if (e is TimeoutException) {
        return AuthResponse(
          success: false,
          message: 'Request timeout: $e',
        );
      } else if (e is FormatException) {
        return AuthResponse(
          success: false,
          message: 'Invalid JSON response format: $e',
        );
      } else {
        return AuthResponse(
          success: false,
          message: 'Network error: $e',
        );
      }
    }
  }

  static Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/login'),
        headers: await getHeaders(),
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(_timeout);

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final data = jsonDecode(response.body);
        final authResponse = AuthResponse.fromJson(data);

        if (authResponse.success && authResponse.data?.token != null) {
          await saveToken(authResponse.data?.token);
        }

        return authResponse;
      } else {
        return AuthResponse(
          success: false,
          message: 'Error: ${response.statusCode} - ${response.body.isEmpty ? "Empty response" : response.body}',
        );
      }
    } catch (e) {
      if (e is TimeoutException) {
        return AuthResponse(
          success: false,
          message: 'Request timeout: $e',
        );
      } else if (e is FormatException) {
        return AuthResponse(
          success: false,
          message: 'Invalid JSON response format: $e',
        );
      } else {
        return AuthResponse(
          success: false,
          message: 'Network error: $e',
        );
      }
    }
  }

  static Future<ApiResponse> logout() async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/logout'),
        headers: await getHeaders(),
      ).timeout(_timeout);

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final data = jsonDecode(response.body);
        final apiResponse = ApiResponse.fromJson(data);

        if (apiResponse.success) {
          await clearToken();
        }

        return apiResponse;
      } else {
        return ApiResponse(
          success: false,
          message: 'Error: ${response.statusCode} - ${response.body.isEmpty ? "Empty response" : response.body}',
        );
      }
    } catch (e) {
      if (e is TimeoutException) {
        return ApiResponse(
          success: false,
          message: 'Request timeout: $e',
        );
      } else if (e is FormatException) {
        return ApiResponse(
          success: false,
          message: 'Invalid JSON response format: $e',
        );
      } else {
        return ApiResponse(
          success: false,
          message: 'Network error: $e',
        );
      }
    }
  }

  // Category methods
  static Future<CategoryApiResponse> getCategories() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/categories'),
        headers: await getHeaders(),
      ).timeout(_timeout);

      print("Raw response from getCategories: ${response.body}"); // Debug log
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final data = jsonDecode(response.body);
        print("Parsed JSON: $data"); // Debug log
        return CategoryApiResponse.fromJson(data);
      } else {
        print("Non-success status code: ${response.statusCode} or empty response body");
        return CategoryApiResponse(
          success: false,
          message: 'Error: ${response.statusCode} - ${response.body.isEmpty ? "Empty response" : response.body}',
          data: null,
        );
      }
    } catch (e) {
      if (e is TimeoutException) {
        return CategoryApiResponse(
          success: false,
          message: 'Request timeout: $e',
          data: null,
        );
      } else if (e is FormatException) {
        print("JSON parsing error: $e");
        return CategoryApiResponse(
          success: false,
          message: 'Invalid JSON response format: $e',
          data: null,
        );
      } else {
        print("Network error: $e");
        return CategoryApiResponse(
          success: false,
          message: 'Network error: $e',
          data: null,
        );
      }
    }
  }

  static Future<CategoryApiResponse> createCategory({
    required String name,
    required String type,
  }) async {
    try {
      print("Sending create category request: name=$name, type=$type"); // Debug log
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/categories'),
        headers: await getHeaders(),
        body: jsonEncode({
          'name': name,
          'type': type,
        }),
      ).timeout(_timeout);

      print("Raw response from createCategory: ${response.body}"); // Debug log
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final data = jsonDecode(response.body);
        print("Parsed JSON from create: $data"); // Debug log
        return CategoryApiResponse.fromJson(data);
      } else {
        print("Non-success status code: ${response.statusCode} or empty response body");
        return CategoryApiResponse(
          success: false,
          message: 'Error: ${response.statusCode} - ${response.body.isEmpty ? "Empty response" : response.body}',
          data: null,
        );
      }
    } catch (e) {
      if (e is TimeoutException) {
        return CategoryApiResponse(
          success: false,
          message: 'Request timeout: $e',
          data: null,
        );
      } else if (e is FormatException) {
        print("JSON parsing error: $e");
        return CategoryApiResponse(
          success: false,
          message: 'Invalid JSON response format: $e',
          data: null,
        );
      } else {
        print("Network error: $e");
        return CategoryApiResponse(
          success: false,
          message: 'Network error: $e',
          data: null,
        );
      }
    }
  }

  static Future<CategoryApiResponse> updateCategory({
    required int id,
    required String name,
    required String type,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/categories/$id'),
        headers: await getHeaders(),
        body: jsonEncode({
          'name': name,
          'type': type,
        }),
      ).timeout(_timeout);

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final data = jsonDecode(response.body);
        return CategoryApiResponse.fromJson(data);
      } else {
        return CategoryApiResponse(
          success: false,
          message: 'Error: ${response.statusCode} - ${response.body.isEmpty ? "Empty response" : response.body}',
          data: null,
        );
      }
    } catch (e) {
      if (e is TimeoutException) {
        return CategoryApiResponse(
          success: false,
          message: 'Request timeout: $e',
          data: null,
        );
      } else if (e is FormatException) {
        return CategoryApiResponse(
          success: false,
          message: 'Invalid JSON response format: $e',
          data: null,
        );
      } else {
        return CategoryApiResponse(
          success: false,
          message: 'Network error: $e',
          data: null,
        );
      }
    }
  }

  static Future<ApiResponse> deleteCategory(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/categories/$id'),
        headers: await getHeaders(),
      ).timeout(_timeout);

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final data = jsonDecode(response.body);
        return ApiResponse.fromJson(data);
      } else {
        return ApiResponse(
          success: false,
          message: 'Error: ${response.statusCode} - ${response.body.isEmpty ? "Empty response" : response.body}',
        );
      }
    } catch (e) {
      if (e is TimeoutException) {
        return ApiResponse(
          success: false,
          message: 'Request timeout: $e',
        );
      } else if (e is FormatException) {
        return ApiResponse(
          success: false,
          message: 'Invalid JSON response format: $e',
        );
      } else {
        return ApiResponse(
          success: false,
          message: 'Network error: $e',
        );
      }
    }
  }

  // Transaction methods
  static Future<TransactionApiResponse> getTransactions() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/transactions'),
        headers: await getHeaders(),
      ).timeout(_timeout);

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final data = jsonDecode(response.body);
        return TransactionApiResponse.fromJson(data);
      } else {
        return TransactionApiResponse(
          success: false,
          message: 'Error: ${response.statusCode} - ${response.body.isEmpty ? "Empty response" : response.body}',
          data: null,
        );
      }
    } catch (e) {
      if (e is TimeoutException) {
        return TransactionApiResponse(
          success: false,
          message: 'Request timeout: $e',
          data: null,
        );
      } else if (e is FormatException) {
        return TransactionApiResponse(
          success: false,
          message: 'Invalid JSON response format: $e',
          data: null,
        );
      } else {
        return TransactionApiResponse(
          success: false,
          message: 'Network error: $e',
          data: null,
        );
      }
    }
  }

  static Future<TransactionApiResponse> createTransaction({
    required int categoryId,
    required String amount,
    required String type,
    String? description,
    String? date,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/transactions'),
        headers: await getHeaders(),
        body: jsonEncode({
          'category_id': categoryId,
          'amount': amount,
          'type': type,
          'description': description ?? '',
          'date': date ?? DateTime.now().toIso8601String().split('T')[0],
        }),
      ).timeout(_timeout);

      final data = jsonDecode(response.body);
      return TransactionApiResponse.fromJson(data);
    } catch (e) {
      if (e is TimeoutException) {
        return TransactionApiResponse(
          success: false,
          message: 'Request timeout: $e',
          data: null,
        );
      } else {
        return TransactionApiResponse(
          success: false,
          message: 'Network error: $e',
          data: null,
        );
      }
    }
  }

  static Future<TransactionApiResponse> updateTransaction({
    required int id,
    required int categoryId,
    required String amount,
    required String type,
    String? description,
    String? date,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/transactions/$id'),
        headers: await getHeaders(),
        body: jsonEncode({
          'category_id': categoryId,
          'amount': amount,
          'type': type,
          'description': description ?? '',
          'date': date ?? DateTime.now().toIso8601String().split('T')[0],
        }),
      ).timeout(_timeout);

      final data = jsonDecode(response.body);
      return TransactionApiResponse.fromJson(data);
    } catch (e) {
      if (e is TimeoutException) {
        return TransactionApiResponse(
          success: false,
          message: 'Request timeout: $e',
          data: null,
        );
      } else {
        return TransactionApiResponse(
          success: false,
          message: 'Network error: $e',
          data: null,
        );
      }
    }
  }

  static Future<ApiResponse> deleteTransaction(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/transactions/$id'),
        headers: await getHeaders(),
      ).timeout(_timeout);

      final data = jsonDecode(response.body);
      return ApiResponse.fromJson(data);
    } catch (e) {
      if (e is TimeoutException) {
        return ApiResponse(
          success: false,
          message: 'Request timeout: $e',
        );
      } else {
        return ApiResponse(
          success: false,
          message: 'Network error: $e',
        );
      }
    }
  }

  // Budget methods
  static Future<BudgetApiResponse> getBudgets() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/budgets'),
        headers: await getHeaders(),
      ).timeout(_timeout);

      final data = jsonDecode(response.body);
      return BudgetApiResponse.fromJson(data);
    } catch (e) {
      if (e is TimeoutException) {
        return BudgetApiResponse(
          success: false,
          message: 'Request timeout: $e',
          data: null,
        );
      } else {
        return BudgetApiResponse(
          success: false,
          message: 'Network error: $e',
          data: null,
        );
      }
    }
  }

  static Future<BudgetApiResponse> createBudget({
    required int categoryId,
    required String amount,
    required String month,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/budgets'),
        headers: await getHeaders(),
        body: jsonEncode({
          'category_id': categoryId,
          'amount': amount,
          'month': month,
        }),
      ).timeout(_timeout);

      final data = jsonDecode(response.body);
      return BudgetApiResponse.fromJson(data);
    } catch (e) {
      if (e is TimeoutException) {
        return BudgetApiResponse(
          success: false,
          message: 'Request timeout: $e',
          data: null,
        );
      } else {
        return BudgetApiResponse(
          success: false,
          message: 'Network error: $e',
          data: null,
        );
      }
    }
  }

  static Future<BudgetApiResponse> updateBudget({
    required int id,
    required int categoryId,
    required String amount,
    required String month,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/budgets/$id'),
        headers: await getHeaders(),
        body: jsonEncode({
          'category_id': categoryId,
          'amount': amount,
          'month': month,
        }),
      ).timeout(_timeout);

      final data = jsonDecode(response.body);
      return BudgetApiResponse.fromJson(data);
    } catch (e) {
      if (e is TimeoutException) {
        return BudgetApiResponse(
          success: false,
          message: 'Request timeout: $e',
          data: null,
        );
      } else {
        return BudgetApiResponse(
          success: false,
          message: 'Network error: $e',
          data: null,
        );
      }
    }
  }

  static Future<ApiResponse> deleteBudget(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/budgets/$id'),
        headers: await getHeaders(),
      ).timeout(_timeout);

      final data = jsonDecode(response.body);
      return ApiResponse.fromJson(data);
    } catch (e) {
      if (e is TimeoutException) {
        return ApiResponse(
          success: false,
          message: 'Request timeout: $e',
        );
      } else {
        return ApiResponse(
          success: false,
          message: 'Network error: $e',
        );
      }
    }
  }

  // Financial summary methods
  static Future<FinancialSummaryResponse> getFinancialSummary({required int year, required int month}) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/financial-summary?year=$year&month=${month.toString().padLeft(2, '0')}'),
        headers: await getHeaders(),
      ).timeout(_timeout);

      print("Raw response from getFinancialSummary: ${response.body}"); // Debug log
      final data = jsonDecode(response.body);
      print("Parsed JSON from financial summary: $data"); // Debug log
      return FinancialSummaryResponse.fromJson(data);
    } catch (e) {
      if (e is TimeoutException) {
        return FinancialSummaryResponse(
          success: false,
          message: 'Request timeout: $e',
          data: null,
        );
      } else {
        return FinancialSummaryResponse(
          success: false,
          message: 'Network error: $e',
          data: null,
        );
      }
    }
  }

  static Future<MonthlyFinancialDataResponse> getMonthlyFinancialData({required int year}) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/monthly-financial-data?year=$year'),
        headers: await getHeaders(),
      ).timeout(_timeout);

      print("Raw response from getMonthlyFinancialData: ${response.body}"); // Debug log
      final data = jsonDecode(response.body);
      print("Parsed JSON from monthly financial data: $data"); // Debug log

      // Return MonthlyFinancialDataResponse
      // Since we don't have this model yet, let's create a temporary solution
      // For now, we'll directly return the response as FinancialSummaryResponse
      // and handle the data parsing in the provider
      final parsedData = jsonDecode(response.body);
      if (parsedData['success']) {
        return MonthlyFinancialDataResponse(
          success: parsedData['success'],
          data: MonthlyFinancialData.fromJson(parsedData['data']),
          message: parsedData['message'],
        );
      } else {
        return MonthlyFinancialDataResponse(
          success: false,
          data: null,
          message: parsedData['message'] ?? 'Failed to get monthly financial data',
        );
      }
    } catch (e) {
      if (e is TimeoutException) {
        return MonthlyFinancialDataResponse(
          success: false,
          message: 'Request timeout: $e',
          data: null,
        );
      } else {
        return MonthlyFinancialDataResponse(
          success: false,
          message: 'Network error: $e',
          data: null,
        );
      }
    }
  }

  // Saving methods
  static Future<SavingApiResponse> getSavings() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/savings'),
        headers: await getHeaders(),
      ).timeout(_timeout);

      final data = jsonDecode(response.body);
      return SavingApiResponse.fromJson(data);
    } catch (e) {
      if (e is TimeoutException) {
        return SavingApiResponse(
          success: false,
          message: 'Request timeout: $e',
          data: null,
        );
      } else {
        return SavingApiResponse(
          success: false,
          message: 'Network error: $e',
          data: null,
        );
      }
    }
  }

  static Future<SavingApiResponse> createSaving({
    required String goalName,
    required String targetAmount,
    required String currentAmount,
    required String deadline,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/savings'),
        headers: await getHeaders(),
        body: jsonEncode({
          'goal_name': goalName,
          'target_amount': targetAmount,
          'current_amount': currentAmount,
          'deadline': deadline,
        }),
      ).timeout(_timeout);

      final data = jsonDecode(response.body);
      return SavingApiResponse.fromJson(data);
    } catch (e) {
      if (e is TimeoutException) {
        return SavingApiResponse(
          success: false,
          message: 'Request timeout: $e',
          data: null,
        );
      } else {
        return SavingApiResponse(
          success: false,
          message: 'Network error: $e',
          data: null,
        );
      }
    }
  }

  static Future<SavingApiResponse> updateSaving({
    required int id,
    required String goalName,
    required String targetAmount,
    required String currentAmount,
    required String deadline,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/savings/$id'),
        headers: await getHeaders(),
        body: jsonEncode({
          'goal_name': goalName,
          'target_amount': targetAmount,
          'current_amount': currentAmount,
          'deadline': deadline,
        }),
      ).timeout(_timeout);

      final data = jsonDecode(response.body);
      return SavingApiResponse.fromJson(data);
    } catch (e) {
      if (e is TimeoutException) {
        return SavingApiResponse(
          success: false,
          message: 'Request timeout: $e',
          data: null,
        );
      } else {
        return SavingApiResponse(
          success: false,
          message: 'Network error: $e',
          data: null,
        );
      }
    }
  }

  static Future<ApiResponse> deleteSaving(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/savings/$id'),
        headers: await getHeaders(),
      ).timeout(_timeout);

      final data = jsonDecode(response.body);
      return ApiResponse.fromJson(data);
    } catch (e) {
      if (e is TimeoutException) {
        return ApiResponse(
          success: false,
          message: 'Request timeout: $e',
        );
      } else {
        return ApiResponse(
          success: false,
          message: 'Network error: $e',
        );
      }
    }
  }
}