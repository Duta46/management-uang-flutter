class ApiResponse {
  final bool success;
  final dynamic data;
  final String message;
  final Map<String, dynamic>? errors;

  ApiResponse({
    required this.success,
    this.data,
    required this.message,
    this.errors,
  });

  factory ApiResponse.fromJson(dynamic json) {
    if (json == null) {
      return ApiResponse(
        success: false,
        message: 'Response is null',
      );
    }

    // Pastikan json adalah Map sebelum mengakses property-nya
    if (json is! Map<String, dynamic>) {
      return ApiResponse(
        success: false,
        message: 'Invalid response format: expected Map<String, dynamic>',
      );
    }

    return ApiResponse(
      success: json['success'] is bool ? json['success'] : false,
      data: json['data'],
      message: json['message'] is String ? json['message'] : 'Unknown error occurred',
      errors: json['errors'] is Map ? json['errors'] as Map<String, dynamic>? : null,
    );
  }
}