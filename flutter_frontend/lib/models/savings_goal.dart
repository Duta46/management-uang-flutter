class SavingsGoal {
  final int? id;
  final int? userId;
  final String name;
  final String? description;
  final String targetAmount;
  final String currentAmount;
  final String targetDate; // Format: YYYY-MM-DD
  final String status; // active, achieved, cancelled
  final String? createdAt;
  final String? updatedAt;

  SavingsGoal({
    this.id,
    this.userId,
    required this.name,
    this.description,
    required this.targetAmount,
    required this.currentAmount,
    required this.targetDate,
    this.status = 'active',
    this.createdAt,
    this.updatedAt,
  });

  factory SavingsGoal.fromJson(dynamic json) {
    return SavingsGoal(
      id: json['id'] as int?,
      userId: json['user_id'] as int?,
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      targetAmount: json['target_amount']?.toString() ?? '0',
      currentAmount: json['current_amount']?.toString() ?? '0',
      targetDate: json['target_date'] as String? ?? '',
      status: json['status'] as String? ?? 'active',
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'description': description,
      'target_amount': targetAmount,
      'current_amount': currentAmount,
      'target_date': targetDate,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class SavingsGoalApiResponse {
  final bool success;
  final SavingsGoalData? data;
  final String message;

  SavingsGoalApiResponse({
    required this.success,
    this.data,
    required this.message,
  });

  factory SavingsGoalApiResponse.fromJson(dynamic json) {
    SavingsGoalData? savingsGoalData;
    if (json != null && json['data'] != null) {
      savingsGoalData = SavingsGoalData.fromJson(json);
    }

    return SavingsGoalApiResponse(
      success: json != null && json['success'] is bool ? json['success'] : false,
      data: savingsGoalData,
      message: json != null && json['message'] is String ? json['message'] : 'Unknown error occurred',
    );
  }
}

class SavingsGoalData {
  final List<SavingsGoal>? data;
  final List<dynamic>? links;
  final dynamic meta;

  SavingsGoalData({
    this.data,
    this.links,
    this.meta,
  });

  factory SavingsGoalData.fromJson(dynamic json) {
    List<SavingsGoal>? savingsGoals = [];
    List<dynamic>? links;

    if (json != null) {
      // Jika json['data'] adalah List (untuk single savings goal response atau create response)
      if (json['data'] is List) {
        savingsGoals = (json['data'] as List).map((e) => SavingsGoal.fromJson(e)).toList();
        // Untuk response non-paginated, links dan meta tidak ada
        links = null;
      }
      // Jika json['data'] adalah Map, berarti ini adalah paginated response
      else if (json['data'] is Map) {
        // Cek apakah ini response paginated (memiliki field 'data' lagi di dalamnya)
        if (json['data']['data'] is List) {
          // Ini adalah response paginated, ambil daftar savingsGoalsnya
          savingsGoals = (json['data']['data'] as List).map((e) => SavingsGoal.fromJson(e)).toList();
          links = json['data']['links'] as List<dynamic>?;
        } else {
          // Ini mungkin single savings goal response yang dibungkus dalam map
          savingsGoals = [SavingsGoal.fromJson(json['data'])];
          links = null;
        }
      }
      // Jika json itu sendiri langsung berisi array savingsGoals (kasus tertentu)
      else if (json is List) {
        savingsGoals = (json as List).map((e) => SavingsGoal.fromJson(e)).toList();
        links = null;
      }
    }

    return SavingsGoalData(
      data: savingsGoals,
      links: links,
      meta: json['data'] != null ? json['data']['meta'] : json['meta'],
    );
  }
}