import 'meta.dart';

class Saving {
  final int? id;
  final int? userId;
  final String goalName;
  final String targetAmount; // Using String to preserve decimal precision
  final String currentAmount; // Using String to preserve decimal precision
  final String deadline; // Format: YYYY-MM-DD
  final String? createdAt;
  final String? updatedAt;
  final double? progressPercentage;

  Saving({
    this.id,
    this.userId,
    required this.goalName,
    required this.targetAmount,
    required this.currentAmount,
    required this.deadline,
    this.createdAt,
    this.updatedAt,
    this.progressPercentage,
  });

  factory Saving.fromJson(dynamic json) {
    return Saving(
      id: json['id'] as int?,
      userId: json['user_id'] as int?,
      goalName: json['goal_name'] as String? ?? '',
      targetAmount: json['target_amount'] as String? ?? '',
      currentAmount: json['current_amount'] as String? ?? '',
      deadline: json['deadline'] as String? ?? '',
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      progressPercentage: json['progress_percentage'] as double?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'goal_name': goalName,
      'target_amount': targetAmount,
      'current_amount': currentAmount,
      'deadline': deadline,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class SavingApiResponse {
  final bool success;
  final SavingData? data;
  final String message;

  SavingApiResponse({
    required this.success,
    this.data,
    required this.message,
  });

  factory SavingApiResponse.fromJson(dynamic json) {
    SavingData? savingData;
    if (json['data'] != null) {
      savingData = SavingData.fromJson(json);
    }

    return SavingApiResponse(
      success: json['success'] as bool,
      data: savingData,
      message: json['message'] as String,
    );
  }
}

class SavingData {
  final List<Saving>? data;
  final List<dynamic>? links;
  final Meta? meta;

  SavingData({
    this.data,
    this.links,
    this.meta,
  });

  factory SavingData.fromJson(dynamic json) {
    List<Saving>? savings = [];
    List<dynamic>? links;

    if (json != null) {
      // Jika json['data'] adalah List (untuk single saving response atau create response)
      if (json['data'] is List) {
        savings = (json['data'] as List).map((e) => Saving.fromJson(e)).toList();
        // Untuk response non-paginated, links dan meta tidak ada
        links = null;
      }
      // Jika json['data'] adalah Map, berarti ini adalah paginated response
      else if (json['data'] is Map) {
        // Cek apakah ini response paginated (memiliki field 'data' lagi di dalamnya)
        if (json['data']['data'] is List) {
          // Ini adalah response paginated, ambil daftar savingsnya
          savings = (json['data']['data'] as List).map((e) => Saving.fromJson(e)).toList();
          links = json['data']['links'] as List<dynamic>?;
        } else {
          // Ini mungkin single saving response yang dibungkus dalam map
          savings = [Saving.fromJson(json['data'])];
          links = null;
        }
      }
      // Jika json itu sendiri langsung berisi array savings (kasus tertentu)
      else if (json is List) {
        savings = (json as List).map((e) => Saving.fromJson(e)).toList();
        links = null;
      }
    }

    return SavingData(
      data: savings,
      links: links,
      meta: (json != null && json['data'] is Map && json['data']['meta'] != null) ? Meta.fromJson(json['data']['meta']) : (json?['meta'] != null ? Meta.fromJson(json['meta']) : null),
    );
  }
}