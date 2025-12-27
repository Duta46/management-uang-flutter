import 'dart:convert';
import 'package:dio/dio.dart';
import '../models/api_models.dart' as Model;
import '../models/api_response.dart' as Response;
import '../config/api_config.dart';

class ApiRepository {
  final Dio _dio = Dio();

  String get baseUrl {
    return ApiConfig.baseUrl;
  }

  ApiRepository() {
    _dio.options.headers['Content-Type'] = 'application/json';
    _dio.options.headers['Accept'] = 'application/json';
    _dio.options.headers['X-Requested-With'] = 'XMLHttpRequest'; // Header untuk Laravel
    // Tambahkan timeout untuk mengatasi potensi masalah jaringan
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);

    // Tambahkan interceptor untuk menangani error 401
    _dio.interceptors.add(InterceptorsWrapper(
      onError: (DioException err, ErrorInterceptorHandler handler) async {
        // Jika mendapatkan error 401 (Unauthorized), bisa jadi token telah kadaluarsa
        if (err.response?.statusCode == 401) {
          print("API Repository: Received 401 Unauthorized - Token mungkin telah kadaluarsa");
          // Di sini Anda bisa menambahkan logika untuk merefresh token atau redirect ke login
          // Untuk saat ini, kita hanya log error dan biarkan aplikasi menangani sesuai kebijakan
        }
        return handler.next(err);
      },
    ));
  }

  void setAuthToken(String? token) {
    if (token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
      print("API Repository: Authorization token set - Bearer $token"); // Debug log
    } else {
      _dio.options.headers.remove('Authorization');
      print("API Repository: Authorization token removed"); // Debug log
    }
  }

  Future<Response.ApiResponse> testConnection() async {
    try {
      print("Testing connection to: $baseUrl/health"); // Debug log
      final response = await _dio.get('$baseUrl/health');
      print("Health check response: ${response.data}"); // Debug log
      return Response.ApiResponse.fromJson(response.data);
    } catch (e) {
      print("Health check error: $e"); // Debug log
      return Response.ApiResponse(
        success: false,
        message: e.toString(),
      );
    }
  }

  Future<Map<String, dynamic>> testLoginConnection(String email, String password) async {
    try {
      print("Testing login connection to: $baseUrl/auth/login"); // Debug log
      print("Login test data: email=$email, password=$password"); // Debug log
      final response = await _dio.post(
        '$baseUrl/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );
      print("Login test response status: ${response.statusCode}"); // Debug log
      print("Login test response headers: ${response.headers}"); // Debug log
      print("Login test response data: ${response.data}"); // Debug log
      return {
        'success': true,
        'data': response.data,
        'status_code': response.statusCode,
      };
    } catch (e) {
      print("Login test error: $e"); // Debug log
      if (e is DioException) {
        print("DioError details: ${e.response?.data}"); // Debug log
        print("DioError headers: ${e.response?.headers}"); // Debug log
        print("DioError status code: ${e.response?.statusCode}"); // Debug log
      }
      return {
        'success': false,
        'error': e.toString(),
        'data': null,
      };
    }
  }

  Future<Response.ApiResponse> register(String name, String email, String password) async {
    try {
      print("Sending register request to: $baseUrl/auth/register"); // Debug log
      print("Register data: name=$name, email=$email"); // Debug log

      final response = await _dio.post(
        '$baseUrl/auth/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': password,
        },
      );

      print("Register response: ${response.data}"); // Debug log
      return Response.ApiResponse.fromJson(response.data);
    } catch (e) {
      print("Register error: $e"); // Debug log
      return Response.ApiResponse(
        success: false,
        message: e.toString(),
      );
    }
  }

  Future<Response.ApiResponse> login(String email, String password) async {
    try {
      print("Sending login request to: $baseUrl/auth/login"); // Debug log
      print("Login data: email=$email, password=$password"); // Debug log

      final response = await _dio.post(
        '$baseUrl/auth/login',  // Ini benar karena Laravel menggunakan Route::prefix('auth')
        data: {
          'email': email,
          'password': password,
        },
      );

      print("Login response: ${response.data}"); // Debug log
      print("Login response status: ${response.statusCode}"); // Debug log
      return Response.ApiResponse.fromJson(response.data);
    } catch (e) {
      print("Login error: $e"); // Debug log
      if (e is DioException) {
        print("DioException details:"); // Debug log
        print("  Response: ${e.response?.data}"); // Debug log
        print("  StatusCode: ${e.response?.statusCode}"); // Debug log
        print("  Headers: ${e.response?.headers}"); // Debug log
        print("  Request options: ${e.requestOptions.uri}"); // Debug log
      }
      return Response.ApiResponse(
        success: false,
        message: e.toString(),
      );
    }
  }


  Future<Response.ApiResponse> getCategories() async {
    print("API Repository: Sending getCategories request to: $baseUrl/categories"); // Debug log
    print("API Repository: Get categories - Authorization header: ${_dio.options.headers['Authorization']}"); // Debug log
    try {
      final response = await _dio.get('$baseUrl/categories');
      print("API Repository: getCategories response - Status: ${response.statusCode}"); // Debug log
      print("API Repository: getCategories response data: ${response.data}"); // Debug log
      return Response.ApiResponse.fromJson(response.data);
    } catch (e, stackTrace) {
      print("API Repository: getCategories error: $e"); // Debug log
      print("Stack trace: $stackTrace"); // Debug log
      if (e is DioException) {
        print("API Repository: Dio error details: ${e.response?.data}"); // Debug log
        print("API Repository: Dio status code: ${e.response?.statusCode}"); // Debug log
        print("API Repository: Dio error request options: ${e.requestOptions.uri}"); // Debug log
      }
      return Response.ApiResponse(
        success: false,
        message: e.toString(),
      );
    }
  }

  Future<Response.ApiResponse> addCategory(String name) async {
    print("API Repository: Adding category - Authorization header: ${_dio.options.headers['Authorization']}"); // Debug log
    print("API Repository: Sending category data - name: $name"); // Debug log
    try {
      final response = await _dio.post(
        '$baseUrl/categories',
        data: {
          'name': name,
        },
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );
      print("API Repository: Add category response - Status: ${response.statusCode}, Data: ${response.data}"); // Debug log
      return Response.ApiResponse.fromJson(response.data);
    } catch (e) {
      print("API Repository: Add category error: $e"); // Debug log
      if (e is DioException) {
        print("API Repository: Dio error details: ${e.response?.data}"); // Debug log
        print("API Repository: Dio status code: ${e.response?.statusCode}"); // Debug log
        print("API Repository: Dio error request data: ${e.requestOptions.data}"); // Debug log
      }
      return Response.ApiResponse(
        success: false,
        message: e.toString(),
      );
    }
  }

  Future<Response.ApiResponse> updateCategory(int id, String name) async {
    print("API Repository: Updating category - Authorization header: ${_dio.options.headers['Authorization']}"); // Debug log
    try {
      final response = await _dio.put(
        '$baseUrl/categories/$id',
        data: {
          'name': name,
        },
      );
      return Response.ApiResponse.fromJson(response.data);
    } catch (e) {
      return Response.ApiResponse(
        success: false,
        message: e.toString(),
      );
    }
  }

  Future<Response.ApiResponse> deleteCategory(int id) async {
    print("API Repository: Deleting category - Authorization header: ${_dio.options.headers['Authorization']}"); // Debug log
    try {
      final response = await _dio.delete('$baseUrl/categories/$id');
      return Response.ApiResponse.fromJson(response.data);
    } catch (e) {
      return Response.ApiResponse(
        success: false,
        message: e.toString(),
      );
    }
  }

  Future<Response.ApiResponse> getTransactions() async {
    try {
      print("API Repository: Sending getTransactions request to: $baseUrl/transactions"); // Debug log
      final response = await _dio.get('$baseUrl/transactions');
      print("API Repository: getTransactions response: ${response.data}"); // Debug log
      return Response.ApiResponse.fromJson(response.data);
    } catch (e) {
      print("API Repository: getTransactions error: $e"); // Debug log
      if (e is DioException) {
        print("API Repository: Dio error details: ${e.response?.data}"); // Debug log
        print("API Repository: Dio status code: ${e.response?.statusCode}"); // Debug log
      }
      return Response.ApiResponse(
        success: false,
        message: e.toString(),
      );
    }
  }

  Future<Response.ApiResponse> createTransaction({
    required String amount,
    required String type,
    required int categoryId,
    String? description,
    String? date,
  }) async {
    try {
      final response = await _dio.post(
        '$baseUrl/transactions',
        data: {
          'amount': amount,
          'type': type,
          'category_id': categoryId,
          'description': description ?? '',
          'date': date ?? DateTime.now().toIso8601String().split('T')[0],
        },
      );
      return Response.ApiResponse.fromJson(response.data);
    } catch (e) {
      return Response.ApiResponse(
        success: false,
        message: e.toString(),
      );
    }
  }

  Future<Response.ApiResponse> createTransactionSimple(int categoryId, String amount, String type, String? description, String? date) async {
    try {
      final response = await _dio.post(
        '$baseUrl/transactions',
        data: {
          'category_id': categoryId,
          'amount': amount,
          'type': type,
          'description': description ?? '',
          'date': date ?? DateTime.now().toIso8601String().split('T')[0],
        },
      );
      return Response.ApiResponse.fromJson(response.data);
    } catch (e) {
      return Response.ApiResponse(
        success: false,
        message: e.toString(),
      );
    }
  }

  Future<Response.ApiResponse> updateTransaction(int id, int categoryId, String amount, String type, String? description, String? date) async {
    try {
      final response = await _dio.put(
        '$baseUrl/transactions/$id',
        data: {
          'category_id': categoryId,
          'amount': amount,
          'type': type,
          'description': description ?? '',
          'date': date ?? DateTime.now().toIso8601String().split('T')[0],
        },
      );
      return Response.ApiResponse.fromJson(response.data);
    } catch (e) {
      return Response.ApiResponse(
        success: false,
        message: e.toString(),
      );
    }
  }

  Future<Response.ApiResponse> addTransaction(Model.Transaction transaction) async {
    try {
      final response = await _dio.post(
        '$baseUrl/transactions',
        data: {
          'category_id': transaction.categoryId,
          'amount': transaction.amount,
          'type': transaction.type,
          'description': transaction.description ?? '',
          'date': transaction.date,
        },
      );
      return Response.ApiResponse.fromJson(response.data);
    } catch (e) {
      return Response.ApiResponse(
        success: false,
        message: e.toString(),
      );
    }
  }

  Future<Response.ApiResponse> deleteTransaction(int id) async {
    try {
      final response = await _dio.delete('$baseUrl/transactions/$id');
      return Response.ApiResponse.fromJson(response.data);
    } catch (e) {
      return Response.ApiResponse(
        success: false,
        message: e.toString(),
      );
    }
  }

  Future<Response.ApiResponse> getMonthlyReport(int year, int month) async {
    try {
      final response = await _dio.get(
        '$baseUrl/reports/monthly',
        queryParameters: {
          'year': year,
          'month': month,
        },
      );
      return Response.ApiResponse.fromJson(response.data);
    } catch (e) {
      return Response.ApiResponse(
        success: false,
        message: e.toString(),
      );
    }
  }

  Future<Response.ApiResponse> getDashboardSummary(int year, int month) async {
    try {
      final response = await _dio.get(
        '$baseUrl/dashboard/summary',
        queryParameters: {
          'year': year,
          'month': month,
        },
      );
      return Response.ApiResponse.fromJson(response.data);
    } catch (e) {
      return Response.ApiResponse(
        success: false,
        message: e.toString(),
      );
    }
  }

  Future<Response.ApiResponse> getDashboardChart(int year, int month) async {
    try {
      final response = await _dio.get(
        '$baseUrl/dashboard/chart',
        queryParameters: {
          'year': year,
          'month': month,
        },
      );
      return Response.ApiResponse.fromJson(response.data);
    } catch (e) {
      return Response.ApiResponse(
        success: false,
        message: e.toString(),
      );
    }
  }

  Future<Response.ApiResponse> healthCheck() async {
    try {
      final response = await _dio.get('$baseUrl/health');
      return Response.ApiResponse.fromJson(response.data);
    } catch (e) {
      return Response.ApiResponse(
        success: false,
        message: e.toString(),
      );
    }
  }

  Future<Response.ApiResponse> logout() async {
    try {
      print("API Repository: Sending logout request to: $baseUrl/auth/logout"); // Debug log
      final response = await _dio.post('$baseUrl/auth/logout');
      print("API Repository: Logout response: ${response.data}"); // Debug log
      return Response.ApiResponse.fromJson(response.data);
    } catch (e) {
      print("API Repository: Logout error: $e"); // Debug log
      if (e is DioException) {
        print("API Repository: Dio error details: ${e.response?.data}"); // Debug log
        print("API Repository: Dio status code: ${e.response?.statusCode}"); // Debug log
      }
      return Response.ApiResponse(
        success: false,
        message: e.toString(),
      );
    }
  }

  Future<Response.ApiResponse> selfTest() async {
    try {
      final response = await _dio.get('$baseUrl/self-test');
      return Response.ApiResponse.fromJson(response.data);
    } catch (e) {
      return Response.ApiResponse(
        success: false,
        message: e.toString(),
      );
    }
  }
}