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
      print('Register request to: ${ApiConfig.baseUrl}/register');
      print('Register data: name=$name, email=$email');

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

      print('Register response status: ${response.statusCode}');
      print('Register response body: ${response.body}');

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
      } else if (e is SocketException) {
        return AuthResponse(
          success: false,
          message: 'Network error - please check your internet connection: $e',
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
      print('Login request to: ${ApiConfig.baseUrl}/login');
      print('Login data: email=$email');

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/login'),
        headers: await getHeaders(),
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(_timeout);

      print('Login response status: ${response.statusCode}');
      print('Login response body: ${response.body}');

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
      } else if (e is SocketException) {
        return AuthResponse(
          success: false,
          message: 'Network error - please check your internet connection: $e',
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
      print("Requesting categories from: ${ApiConfig.baseUrl}/categories");
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/categories'),
        headers: await getHeaders(),
      ).timeout(_timeout);

      print("Raw response from getCategories: ${response.body}"); // Debug log
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final data = jsonDecode(response.body);
        print("Parsed JSON: $data"); // Debug log
        return CategoryApiResponse.fromJson(data);
      } else if (response.statusCode == 401) {
        print("Unauthorized access - token might be expired");
        await clearToken(); // Clear invalid token
        return CategoryApiResponse(
          success: false,
          message: 'Unauthorized access. Please login again.',
          data: null,
        );
      } else {
        print("Non-success status code: ${response.statusCode} or empty response body");
        return CategoryApiResponse(
          success: false,
          message: 'Error: ${response.statusCode} - ${response.body.isEmpty ? "Empty response" : response.body}',
          data: null,
        );
      }
    } catch (e, stackTrace) {
      print("Error in getCategories: $e");
      print("Stack trace: $stackTrace");
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
      } else if (e is SocketException) {
        return CategoryApiResponse(
          success: false,
          message: 'Network error - please check your internet connection: $e',
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
      print("Requesting transactions from: ${ApiConfig.baseUrl}/transactions");
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/transactions'),
        headers: await getHeaders(),
      ).timeout(_timeout);

      print("Get transactions response status: ${response.statusCode}");
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final data = jsonDecode(response.body);
        print("Transactions data: $data");
        return TransactionApiResponse.fromJson(data);
      } else if (response.statusCode == 401) {
        print("Unauthorized access - token might be expired");
        await clearToken(); // Clear invalid token
        return TransactionApiResponse(
          success: false,
          message: 'Unauthorized access. Please login again.',
          data: null,
        );
      } else {
        return TransactionApiResponse(
          success: false,
          message: 'Error: ${response.statusCode} - ${response.body.isEmpty ? "Empty response" : response.body}',
          data: null,
        );
      }
    } catch (e, stackTrace) {
      print("Error in getTransactions: $e");
      print("Stack trace: $stackTrace");
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
      } else if (e is SocketException) {
        return TransactionApiResponse(
          success: false,
          message: 'Network error - please check your internet connection: $e',
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
        Uri.parse('${ApiConfig.baseUrl}/reports/monthly?year=$year&month=$month'),
        headers: await getHeaders(),
      ).timeout(_timeout);

      print("Raw response from getFinancialSummary: ${response.body}"); // Debug log
      final data = jsonDecode(response.body);
      print("Parsed JSON from financial summary: $data"); // Debug log

      // Convert the report data to financial summary format
      if (data['success'] && data['data'] != null) {
        final summaryData = data['data']['summary'];
        final financialSummary = FinancialSummary(
          month: month.toString().padLeft(2, '0'),
          year: year,
          totalIncome: (summaryData['income'] as num?)?.toDouble() ?? 0.0,
          totalExpense: (summaryData['expense'] as num?)?.toDouble() ?? 0.0,
          netTotal: (summaryData['balance'] as num?)?.toDouble() ?? 0.0,
          totalSaving: 0.0, // Calculate saving based on income and expense if needed
        );

        return FinancialSummaryResponse(
          success: true,
          data: financialSummary,
          message: data['message'],
        );
      } else {
        return FinancialSummaryResponse(
          success: false,
          message: data['message'] ?? 'Failed to get financial summary',
          data: null,
        );
      }
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
      // First, get all monthly data for the year by calling the endpoint 12 times
      // This is not efficient but works for now
      List<Future<FinancialSummaryResponse>> futures = [];
      for (int month = 1; month <= 12; month++) {
        futures.add(getFinancialSummary(year: year, month: month));
      }

      final results = await Future.wait(futures);
      List<FinancialSummary> monthlyData = [];
      FinancialSummary? currentMonth;
      FinancialSummary? nextMonth;

      final currentDateTime = DateTime.now();
      final currentMonthNum = currentDateTime.month;
      final currentYear = currentDateTime.year;

      for (int i = 0; i < results.length; i++) {
        final result = results[i];
        if (result.success && result.data != null) {
          final summary = result.data!;
          // Only add to monthlyData if it has actual values
          if (summary.totalIncome != 0 || summary.totalExpense != 0) {
            monthlyData.add(summary);
          }

          // Set current month data
          if (i + 1 == currentMonthNum && year == currentYear) {
            currentMonth = summary;
          }

          // Set next month data
          if (i + 1 == currentMonthNum + 1 && year == currentYear) {
            nextMonth = summary;
          } else if (currentMonthNum == 12 && i + 1 == 1 && year == currentYear + 1) {
            // Handle year rollover
            nextMonth = summary;
          }
        }
      }

      return MonthlyFinancialDataResponse(
        success: true,
        data: MonthlyFinancialData(
          monthlyData: monthlyData,
          currentMonth: currentMonth,
          nextMonth: nextMonth,
        ),
        message: 'Monthly financial data retrieved successfully',
      );
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

}