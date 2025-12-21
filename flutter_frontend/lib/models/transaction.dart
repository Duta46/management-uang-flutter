import 'package:flutter/foundation.dart';
import 'category.dart' as CategoryModel;

class Transaction {
  final int? id;
  final int? userId;
  final int? categoryId;
  final String amount;
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

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: _parseId(json['id']),
      userId: _parseId(json['user_id']),
      categoryId: _parseId(json['category_id']),
      amount: json['amount']?.toString() ?? '0',
      type: json['type']?.toString() ?? '',
      description: json['description']?.toString(),
      date: json['date']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      category: json['category'] != null && json['category'] is Map<String, dynamic>
          ? CategoryModel.Category.fromJson(json['category'])
          : null,
    );
  }

  static int? _parseId(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) {
      return int.tryParse(value) ?? null;
    }
    // Jika tipe lain, coba konversi ke string dulu lalu parse
    return int.tryParse(value.toString()) ?? null;
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
  final dynamic data;
  final String message;

  TransactionApiResponse({
    required this.success,
    this.data,
    required this.message,
  });

  factory TransactionApiResponse.fromJson(Map<String, dynamic> json) {
    return TransactionApiResponse(
      success: json['success'] ?? false,
      data: json['data'],
      message: json['message'] ?? 'Unknown error occurred',
    );
  }
}