import 'package:flutter/foundation.dart';
import 'category.dart' as CategoryModel;
import 'meta.dart' as MetaModel;

class Budget {
  final int? id;
  final int? userId;
  final int? categoryId;
  final String? name;
  final String amount; // Using String to preserve decimal precision
  final String? description;
  final String month; // Format: YYYY-MM
  final String? spentAmount;
  final String? createdAt;
  final String? updatedAt;
  final CategoryModel.Category? category;

  Budget({
    this.id,
    this.userId,
    this.categoryId,
    this.name,
    required this.amount,
    this.description,
    required this.month,
    this.spentAmount,
    this.createdAt,
    this.updatedAt,
    this.category,
  });

  factory Budget.fromJson(dynamic json) {
    return Budget(
      id: json['id'] as int?,
      userId: json['user_id'] as int?,
      categoryId: json['category_id'] as int?,
      name: json['name'] as String?,
      amount: json['amount'] as String? ?? '',
      description: json['description'] as String?,
      month: json['month'] as String? ?? '',
      spentAmount: json['spent_amount'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      category: json['category'] != null
          ? CategoryModel.Category.fromJson(json['category'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'category_id': categoryId,
      'name': name,
      'amount': amount,
      'description': description,
      'month': month,
      'spent_amount': spentAmount,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class BudgetApiResponse {
  final bool success;
  final BudgetData? data;
  final String message;

  BudgetApiResponse({
    required this.success,
    this.data,
    required this.message,
  });

  factory BudgetApiResponse.fromJson(dynamic json) {
    BudgetData? budgetData;
    if (json != null && json['data'] != null) {
      budgetData = BudgetData.fromJson(json);
    }

    return BudgetApiResponse(
      success: json != null && json['success'] is bool ? json['success'] : false,
      data: budgetData,
      message: json != null && json['message'] is String ? json['message'] : 'Unknown error occurred',
    );
  }
}

class BudgetData {
  final List<Budget>? data;
  final List<dynamic>? links;
  final MetaModel.Meta? meta;

  BudgetData({
    this.data,
    this.links,
    this.meta,
  });

  factory BudgetData.fromJson(dynamic json) {
    List<Budget>? budgets = [];
    List<dynamic>? links;

    if (json != null) {
      // Jika json['data'] adalah List (untuk single budget response atau create response)
      if (json['data'] is List) {
        budgets = (json['data'] as List).map((e) => Budget.fromJson(e)).toList();
        // Untuk response non-paginated, links dan meta tidak ada
        links = null;
      }
      // Jika json['data'] adalah Map, berarti ini adalah paginated response
      else if (json['data'] is Map) {
        // Cek apakah ini response paginated (memiliki field 'data' lagi di dalamnya)
        if (json['data']['data'] is List) {
          // Ini adalah response paginated, ambil daftar budgetsnya
          budgets = (json['data']['data'] as List).map((e) => Budget.fromJson(e)).toList();
          links = json['data']['links'] as List<dynamic>?;
        } else {
          // Ini mungkin single budget response yang dibungkus dalam map
          budgets = [Budget.fromJson(json['data'])];
          links = null;
        }
      }
      // Jika json itu sendiri langsung berisi array budgets (kasus tertentu)
      else if (json is List) {
        budgets = (json as List).map((e) => Budget.fromJson(e)).toList();
        links = null;
      }
    }

    return BudgetData(
      data: budgets,
      links: links,
      meta: (json != null && json['data'] is Map && json['data']['meta'] != null) ? MetaModel.Meta.fromJson(json['data']['meta']) : (json?['meta'] != null ? MetaModel.Meta.fromJson(json['meta']) : null),
    );
  }
}