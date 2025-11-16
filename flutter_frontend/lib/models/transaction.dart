import 'package:flutter/foundation.dart';
import 'category.dart' as CategoryModel;
import 'meta.dart' as MetaModel;

class Transaction {
  final int? id;
  final int? userId;
  final int? categoryId;
  final String amount; // Using String to preserve decimal precision
  final String type; // 'income' or 'expense'
  final String? description;
  final String? date;
  final String? createdAt;
  final String? updatedAt;
  final CategoryModel.Category? category;

  Transaction({
    this.id,
    this.userId,
    this.categoryId,
    required this.amount,
    required this.type,
    this.description,
    this.date,
    this.createdAt,
    this.updatedAt,
    this.category,
  });

  factory Transaction.fromJson(dynamic json) {
    return Transaction(
      id: json['id'] as int?,
      userId: json['user_id'] as int?,
      categoryId: json['category_id'] as int?,
      amount: json['amount'] as String? ?? '',
      type: json['type'] as String? ?? '',
      description: json['description'] as String?,
      date: json['date'] as String?,
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
      'amount': amount,
      'type': type,
      'description': description,
      'date': date,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class TransactionApiResponse {
  final bool success;
  final TransactionData? data;
  final String message;

  TransactionApiResponse({
    required this.success,
    this.data,
    required this.message,
  });

  factory TransactionApiResponse.fromJson(dynamic json) {
    TransactionData? transactionData;
    if (json != null && json['data'] != null) {
      transactionData = TransactionData.fromJson(json);
    }

    return TransactionApiResponse(
      success: json != null && json['success'] is bool ? json['success'] : false,
      data: transactionData,
      message: json != null && json['message'] is String ? json['message'] : 'Unknown error occurred',
    );
  }
}

class TransactionData {
  final List<Transaction>? data;
  final List<dynamic>? links;
  final MetaModel.Meta? meta;

  TransactionData({
    this.data,
    this.links,
    this.meta,
  });

  factory TransactionData.fromJson(dynamic json) {
    List<Transaction>? transactions = [];
    List<dynamic>? links;

    if (json != null) {
      // Jika json['data'] adalah List (untuk single transaction response atau create response)
      if (json['data'] is List) {
        transactions = (json['data'] as List).map((e) => Transaction.fromJson(e)).toList();
        // Untuk response non-paginated, links dan meta tidak ada
        links = null;
      }
      // Jika json['data'] adalah Map, berarti ini adalah paginated response
      else if (json['data'] is Map) {
        // Cek apakah ini response paginated (memiliki field 'data' lagi di dalamnya)
        if (json['data']['data'] is List) {
          // Ini adalah response paginated, ambil daftar transactionsnya
          transactions = (json['data']['data'] as List).map((e) => Transaction.fromJson(e)).toList();
          links = json['data']['links'] as List<dynamic>?;
        } else {
          // Ini mungkin single transaction response yang dibungkus dalam map
          transactions = [Transaction.fromJson(json['data'])];
          links = null;
        }
      }
      // Jika json itu sendiri langsung berisi array transactions (kasus tertentu)
      else if (json is List) {
        transactions = (json as List).map((e) => Transaction.fromJson(e)).toList();
        links = null;
      }
    }

    return TransactionData(
      data: transactions,
      links: links,
      meta: (json != null && json['data'] is Map && json['data']['meta'] != null) ? MetaModel.Meta.fromJson(json['data']['meta']) : (json?['meta'] != null ? MetaModel.Meta.fromJson(json['meta']) : null),
    );
  }
}