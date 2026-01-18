class BillReminder {
  final int? id;
  final int? userId;
  final String name;
  final String? description;
  final String amount;
  final String dueDate; // Format: YYYY-MM-DD
  final String frequency; // monthly, weekly, yearly, one_time
  final bool isPaid;
  final bool isActive;
  final String nextDueDate; // Format: YYYY-MM-DD
  final String? createdAt;
  final String? updatedAt;

  BillReminder({
    this.id,
    this.userId,
    required this.name,
    this.description,
    required this.amount,
    required this.dueDate,
    required this.frequency,
    this.isPaid = false,
    this.isActive = true,
    this.nextDueDate = '',
    this.createdAt,
    this.updatedAt,
  });

  factory BillReminder.fromJson(dynamic json) {
    return BillReminder(
      id: json['id'] as int?,
      userId: json['user_id'] as int?,
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      amount: json['amount']?.toString() ?? '0',
      dueDate: json['due_date'] as String? ?? '',
      frequency: json['frequency'] as String? ?? 'monthly',
      isPaid: json['is_paid'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
      nextDueDate: json['next_due_date'] as String? ?? '',
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
      'amount': amount,
      'due_date': dueDate,
      'frequency': frequency,
      'is_paid': isPaid,
      'is_active': isActive,
      'next_due_date': nextDueDate,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class BillReminderApiResponse {
  final bool success;
  final BillReminderData? data;
  final String message;

  BillReminderApiResponse({
    required this.success,
    this.data,
    required this.message,
  });

  factory BillReminderApiResponse.fromJson(dynamic json) {
    BillReminderData? billReminderData;
    if (json != null && json['data'] != null) {
      billReminderData = BillReminderData.fromJson(json);
    }

    return BillReminderApiResponse(
      success: json != null && json['success'] is bool ? json['success'] : false,
      data: billReminderData,
      message: json != null && json['message'] is String ? json['message'] : 'Unknown error occurred',
    );
  }
}

class BillReminderData {
  final List<BillReminder>? data;
  final List<dynamic>? links;
  final dynamic meta;

  BillReminderData({
    this.data,
    this.links,
    this.meta,
  });

  factory BillReminderData.fromJson(dynamic json) {
    List<BillReminder>? billReminders = [];
    List<dynamic>? links;

    if (json != null) {
      // Jika json['data'] adalah List (untuk single bill reminder response atau create response)
      if (json['data'] is List) {
        billReminders = (json['data'] as List).map((e) => BillReminder.fromJson(e)).toList();
        // Untuk response non-paginated, links dan meta tidak ada
        links = null;
      }
      // Jika json['data'] adalah Map, berarti ini adalah paginated response
      else if (json['data'] is Map) {
        // Cek apakah ini response paginated (memiliki field 'data' lagi di dalamnya)
        if (json['data']['data'] is List) {
          // Ini adalah response paginated, ambil daftar billRemindersnya
          billReminders = (json['data']['data'] as List).map((e) => BillReminder.fromJson(e)).toList();
          links = json['data']['links'] as List<dynamic>?;
        } else {
          // Ini mungkin single bill reminder response yang dibungkus dalam map
          billReminders = [BillReminder.fromJson(json['data'])];
          links = null;
        }
      }
      // Jika json itu sendiri langsung berisi array billReminders (kasus tertentu)
      else if (json is List) {
        billReminders = (json as List).map((e) => BillReminder.fromJson(e)).toList();
        links = null;
      }
    }

    return BillReminderData(
      data: billReminders,
      links: links,
      meta: json['data'] != null ? json['data']['meta'] : json['meta'],
    );
  }
}