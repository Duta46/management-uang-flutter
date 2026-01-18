/// API Response models for the application
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String message;
  final Map<String, dynamic>? errors;
  final int? statusCode;

  ApiResponse({
    required this.success,
    this.data,
    required this.message,
    this.errors,
    this.statusCode,
  });

  factory ApiResponse.fromJson(
    dynamic json, {
    T Function(dynamic)? dataMapper,
  }) {
    if (json == null) {
      return ApiResponse<T>(
        success: false,
        message: 'Response is null',
      );
    }

    // Ensure json is a Map before accessing properties
    if (json is! Map<String, dynamic>) {
      return ApiResponse<T>(
        success: false,
        message: 'Invalid response format: expected Map<String, dynamic>',
      );
    }

    final data = json['data'];
    final mappedData = dataMapper != null && data != null ? dataMapper(data) : data;

    return ApiResponse<T>(
      success: json['success'] is bool ? json['success'] : false,
      data: mappedData,
      message: json['message'] is String ? json['message'] : 'Unknown error occurred',
      errors: json['errors'] is Map ? json['errors'] as Map<String, dynamic>? : null,
    );
  }

  /// Creates a success response
  factory ApiResponse.success({
    T? data,
    String message = 'Success',
    int? statusCode,
  }) {
    return ApiResponse<T>(
      success: true,
      data: data,
      message: message,
      statusCode: statusCode,
    );
  }

  /// Creates an error response
  factory ApiResponse.error({
    String message = 'An error occurred',
    Map<String, dynamic>? errors,
    int? statusCode,
  }) {
    return ApiResponse<T>(
      success: false,
      data: null,
      message: message,
      errors: errors,
      statusCode: statusCode,
    );
  }
}

/// Base model for paginated responses
class PaginatedResponse<T> {
  final List<T> data;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final String? nextPageUrl;
  final String? prevPageUrl;

  PaginatedResponse({
    required this.data,
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    this.nextPageUrl,
    this.prevPageUrl,
  });

  factory PaginatedResponse.fromJson(
    dynamic json, {
    required T Function(dynamic) dataMapper,
  }) {
    if (json is! Map<String, dynamic>) {
      throw FormatException('Invalid paginated response format');
    }

    final dataList = json['data'] as List?;
    final mappedData = dataList
        ?.map((item) => dataMapper(item))
        .toList()
        .cast<T>() ?? [];

    return PaginatedResponse<T>(
      data: mappedData,
      currentPage: json['current_page'] ?? 1,
      lastPage: json['last_page'] ?? 1,
      perPage: json['per_page'] ?? 0,
      total: json['total'] ?? 0,
      nextPageUrl: json['next_page_url'],
      prevPageUrl: json['prev_page_url'],
    );
  }
}

/// Base API result class for better type safety
sealed class ApiResult<T> {
  const ApiResult();
}

/// Success result
class ApiSuccess<T> extends ApiResult<T> {
  final T data;

  const ApiSuccess(this.data);
}

/// Error result
class ApiError<T> extends ApiResult<T> {
  final String message;
  final dynamic error;
  final StackTrace? stackTrace;

  const ApiError({
    required this.message,
    this.error,
    this.stackTrace,
  });
}

/// Extension to convert ApiResponse to ApiResult
extension ApiResponseExtension<T> on ApiResponse<T> {
  ApiResult<T> toResult() {
    if (success) {
      return ApiSuccess(data!);
    } else {
      return ApiError<T>(message: message, error: errors);
    }
  }
}