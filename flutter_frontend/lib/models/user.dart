class User {
  final String? token;
  final String? name;
  final String? email;
  final double? autoSavePercentage;
  final double? autoSaveFixedAmount;
  final int? autoSavePercentageSavingId;
  final int? autoSaveFixedAmountSavingId;

  User({
    this.token,
    this.name,
    this.email,
    this.autoSavePercentage,
    this.autoSaveFixedAmount,
    this.autoSavePercentageSavingId,
    this.autoSaveFixedAmountSavingId,
  });

  factory User.fromJson(dynamic json) {
    try {
      if (json == null) {
        return User(
          token: null,
          name: null,
          email: null,
          autoSavePercentage: null,
          autoSaveFixedAmount: null,
          autoSavePercentageSavingId: null,
          autoSaveFixedAmountSavingId: null,
        );
      }

      return User(
        token: json['token'] as String?,
        name: json['name'] as String?,
        email: json['email'] as String?,
        autoSavePercentage: json['auto_save_percentage'] != null ? (json['auto_save_percentage'] is int ? json['auto_save_percentage'].toDouble() : json['auto_save_percentage']) : null,
        autoSaveFixedAmount: json['auto_save_fixed_amount'] != null ? (json['auto_save_fixed_amount'] is int ? json['auto_save_fixed_amount'].toDouble() : json['auto_save_fixed_amount']) : null,
        autoSavePercentageSavingId: json['auto_save_percentage_saving_id'],
        autoSaveFixedAmountSavingId: json['auto_save_fixed_amount_saving_id'],
      );
    } catch (e, stackTrace) {
      print('Error parsing User from JSON: $e');
      print('Stack trace: $stackTrace');
      print('JSON data: $json');
      rethrow; // Re-throw untuk ditangani di level yang lebih tinggi
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'name': name,
      'email': email,
      'auto_save_percentage': autoSavePercentage,
      'auto_save_fixed_amount': autoSaveFixedAmount,
      'auto_save_percentage_saving_id': autoSavePercentageSavingId,
      'auto_save_fixed_amount_saving_id': autoSaveFixedAmountSavingId,
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
    try {
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
    } catch (e, stackTrace) {
      print('Error parsing AuthResponse from JSON: $e');
      print('Stack trace: $stackTrace');
      print('JSON data: $json');
      rethrow; // Re-throw untuk ditangani di level yang lebih tinggi
    }
  }
}