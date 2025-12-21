class User {
  final int? id;
  final String name;
  final String email;
  final String token;

  User({
    this.id,
    required this.name,
    required this.email,
    required this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: _parseValueAsInt(json['id']),
      name: _parseValueAsString(json['name']) ?? '',
      email: _parseValueAsString(json['email']) ?? '',
      token: _parseValueAsString(json['token']) ?? '',
    );
  }

  static int? _parseValueAsInt(dynamic value) {
    try {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) {
        return int.tryParse(value);
      }
      if (value is double) return value.toInt();
      return int.tryParse(value.toString());
    } catch (e) {
      print("Error parsing int value in User: $e");
      return null;
    }
  }

  static String? _parseValueAsString(dynamic value) {
    try {
      if (value == null) return null;
      return value.toString();
    } catch (e) {
      print("Error parsing string value in User: $e");
      return null;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'token': token,
    };
  }
}


class Category {
  final int? id;
  final int? userId;
  final String name;

  Category({
    this.id,
    this.userId,
    required this.name,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: _parseValueAsInt(json['id']),
      userId: _parseValueAsInt(json['user_id']),
      name: _parseValueAsString(json['name']) ?? '',
    );
  }

  static int? _parseValueAsInt(dynamic value) {
    try {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) {
        return int.tryParse(value);
      }
      if (value is double) return value.toInt();
      return int.tryParse(value.toString());
    } catch (e) {
      print("Error parsing int value in Category: $e");
      return null;
    }
  }

  static String? _parseValueAsString(dynamic value) {
    try {
      if (value == null) return null;
      return value.toString();
    } catch (e) {
      print("Error parsing string value in Category: $e");
      return null;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
    };
  }
}

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
  final Category? category;

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
      id: _parseValueAsInt(json['id']),
      userId: _parseValueAsInt(json['user_id']),
      categoryId: _parseValueAsInt(json['category_id']),
      amount: _parseValueAsString(json['amount']) ?? '0',
      type: _parseValueAsString(json['type']) ?? '',
      description: _parseValueAsString(json['description']),
      date: _parseValueAsString(json['date']),
      createdAt: _parseValueAsString(json['created_at']),
      updatedAt: _parseValueAsString(json['updated_at']),
      category: json['category'] != null
          ? Category.fromJson(json['category'] as Map<String, dynamic>)
          : null,
    );
  }

  static int? _parseValueAsInt(dynamic value) {
    try {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) {
        return int.tryParse(value);
      }
      if (value is double) return value.toInt();
      return int.tryParse(value.toString());
    } catch (e) {
      print("Error parsing int value in Transaction: $e");
      return null;
    }
  }

  static String? _parseValueAsString(dynamic value) {
    try {
      if (value == null) return null;
      return value.toString();
    } catch (e) {
      print("Error parsing string value in Transaction: $e");
      return null;
    }
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

