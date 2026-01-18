import 'package:flutter/foundation.dart';

class Category {
  final int? id;
  final String name;
  final bool? isGlobal;

  Category({
    this.id,
    required this.name,
    this.isGlobal,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    try {
      return Category(
        id: _parseId(json['id']),
        name: json['name']?.toString() ?? 'Unknown',
        // isGlobal field has been removed from the database
        isGlobal: null,
      );
    } catch (e, stackTrace) {
      print('Error parsing Category from JSON: $e');
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
      'name': name,
      'is_global': isGlobal,
    };
  }
}

class CategoryApiResponse {
  final bool success;
  final dynamic data;
  final String message;

  CategoryApiResponse({
    required this.success,
    this.data,
    required this.message,
  });

  factory CategoryApiResponse.fromJson(Map<String, dynamic> json) {
    return CategoryApiResponse(
      success: json['success'] ?? false,
      data: json['data'],
      message: json['message'] ?? 'Unknown error occurred',
    );
  }
}