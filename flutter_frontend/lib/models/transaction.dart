import 'package:flutter/foundation.dart';
import 'category.dart' as CategoryModel;

class Transaction {
  final int? id;
  final int? userId;
  final int? categoryId;
  final double amount;
  final String type; // 'income' or 'expense'
  final String? description;
  final DateTime? date;
  final DateTime? createdAt;
  final DateTime? updatedAt;
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
    try {
      return Transaction(
        id: _parseId(json['id']),
        userId: _parseId(json['user_id']),
        categoryId: _parseId(json['category_id']),
        amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
        type: json['type']?.toString() ?? '',
        description: json['description']?.toString(),
        date: json['date'] != null
            ? DateTime.parse(json['date']).toLocal()
            : null,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at']).toLocal()
            : null,
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at']).toLocal()
            : null,
        category: json['category'] != null && json['category'] is Map<String, dynamic>
            ? CategoryModel.Category.fromJson(json['category'])
            : null,
      );
    } catch (e, stackTrace) {
      print('Error parsing Transaction from JSON: $e');
      print('Stack trace: $stackTrace');
      print('JSON data: $json');
      rethrow; // Re-throw untuk ditangani di level yang lebih tinggi
    }
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
      'date': date?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
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