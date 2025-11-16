class User {
  final String? token;
  final String? name;
  final String? email;

  User({
    this.token,
    this.name,
    this.email,
  });

  factory User.fromJson(dynamic json) {
    if (json == null) {
      return User(
        token: null,
        name: null,
        email: null,
      );
    }

    return User(
      token: json['token'] as String?,
      name: json['name'] as String?,
      email: json['email'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'name': name,
      'email': email,
    };
  }
}

class AuthResponse {
  final bool success;
  final User? data;
  final String message;
  final Map<String, dynamic>? errors;

  AuthResponse({
    required this.success,
    this.data,
    required this.message,
    this.errors,
  });

  factory AuthResponse.fromJson(dynamic json) {
    if (json == null) {
      return AuthResponse(
        success: false,
        data: null,
        message: 'Response is null',
        errors: null,
      );
    }

    User? userData;
    if (json['data'] != null) {
      userData = User.fromJson(json['data']);
    }

    Map<String, dynamic>? errors;
    if (json['data'] is Map && (json['data'] as Map).containsKey('email') ||
        (json['data'] as Map).containsKey('password')) {
      errors = json['data'] as Map<String, dynamic>?;
    }

    return AuthResponse(
      success: json['success'] is bool ? json['success'] : false,
      data: userData,
      message: json['message'] is String ? json['message'] : 'Unknown error occurred',
      errors: errors,
    );
  }
}