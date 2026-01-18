import 'package:dio/dio.dart';
import '../models/api_response.dart';
import '../utils/error_handler.dart';

/// Base repository class that provides common API functionality
abstract class BaseRepository {
  late Dio _dio;

  BaseRepository() {
    _dio = Dio();
    
    // Set default options
    _dio.options.headers['Content-Type'] = 'application/json';
    _dio.options.headers['Accept'] = 'application/json';
    _dio.options.headers['X-Requested-With'] = 'XMLHttpRequest';
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);

    // Add interceptors for error handling
    _dio.interceptors.add(InterceptorsWrapper(
      onError: (DioException err, ErrorInterceptorHandler handler) async {
        // Handle specific error cases
        if (err.response?.statusCode == 401) {
          // Token expired or unauthorized - clear the token
          print("BaseRepository: Received 401 Unauthorized - clearing token");
          _dio.options.headers.remove('Authorization');
          // You might want to trigger a logout here or redirect to login
        }

        return handler.next(err);
      },
    ));
  }

  /// Get the Dio instance
  Dio get dio => _dio;

  /// Set authentication token
  void setAuthToken(String? token) {
    if (token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    } else {
      _dio.options.headers.remove('Authorization');
    }
  }

  /// Check if the request is unauthorized (401)
  bool isUnauthorized(DioException err) {
    return err.response?.statusCode == 401;
  }

  /// Make a GET request
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? dataMapper,
  }) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
      );

      return ApiResponse<T>.fromJson(
        response.data,
        dataMapper: dataMapper,
      );
    } on DioException catch (e, stackTrace) {
      if (isUnauthorized(e)) {
        print("BaseRepository: GET request received 401 - clearing token");
        _dio.options.headers.remove('Authorization');
      }
      final exception = ErrorHandler.handle(e, stackTrace);
      return ApiResponse<T>.error(
        message: exception.message,
        statusCode: e.response?.statusCode,
      );
    } catch (e, stackTrace) {
      final exception = ErrorHandler.handle(e, stackTrace);
      return ApiResponse<T>.error(message: exception.message);
    }
  }

  /// Make a POST request
  Future<ApiResponse<T>> post<T>(
    String endpoint,
    Map<String, dynamic> data, {
    T Function(dynamic)? dataMapper,
  }) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: data,
      );

      return ApiResponse<T>.fromJson(
        response.data,
        dataMapper: dataMapper,
      );
    } on DioException catch (e, stackTrace) {
      if (isUnauthorized(e)) {
        print("BaseRepository: POST request received 401 - clearing token");
        _dio.options.headers.remove('Authorization');
      }
      final exception = ErrorHandler.handle(e, stackTrace);
      return ApiResponse<T>.error(
        message: exception.message,
        statusCode: e.response?.statusCode,
      );
    } catch (e, stackTrace) {
      final exception = ErrorHandler.handle(e, stackTrace);
      return ApiResponse<T>.error(message: exception.message);
    }
  }

  /// Make a PUT request
  Future<ApiResponse<T>> put<T>(
    String endpoint,
    Map<String, dynamic> data, {
    T Function(dynamic)? dataMapper,
  }) async {
    try {
      final response = await _dio.put(
        endpoint,
        data: data,
      );

      return ApiResponse<T>.fromJson(
        response.data,
        dataMapper: dataMapper,
      );
    } on DioException catch (e, stackTrace) {
      if (isUnauthorized(e)) {
        print("BaseRepository: PUT request received 401 - clearing token");
        _dio.options.headers.remove('Authorization');
      }
      final exception = ErrorHandler.handle(e, stackTrace);
      return ApiResponse<T>.error(
        message: exception.message,
        statusCode: e.response?.statusCode,
      );
    } catch (e, stackTrace) {
      final exception = ErrorHandler.handle(e, stackTrace);
      return ApiResponse<T>.error(message: exception.message);
    }
  }

  /// Make a DELETE request
  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    T Function(dynamic)? dataMapper,
  }) async {
    try {
      final response = await _dio.delete(endpoint);

      return ApiResponse<T>.fromJson(
        response.data,
        dataMapper: dataMapper,
      );
    } on DioException catch (e, stackTrace) {
      if (isUnauthorized(e)) {
        print("BaseRepository: DELETE request received 401 - clearing token");
        _dio.options.headers.remove('Authorization');
      }
      final exception = ErrorHandler.handle(e, stackTrace);
      return ApiResponse<T>.error(
        message: exception.message,
        statusCode: e.response?.statusCode,
      );
    } catch (e, stackTrace) {
      final exception = ErrorHandler.handle(e, stackTrace);
      return ApiResponse<T>.error(message: exception.message);
    }
  }
}