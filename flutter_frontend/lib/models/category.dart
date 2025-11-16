class Category {
  final int? id;
  final int? userId;
  final String name;
  final String type; // 'income' or 'expense'
  final String? createdAt;
  final String? updatedAt;

  Category({
    this.id,
    this.userId,
    required this.name,
    required this.type,
    this.createdAt,
    this.updatedAt,
  });

  factory Category.fromJson(dynamic json) {
    return Category(
      id: json['id'] as int?,
      userId: json['user_id'] as int?,
      name: json['name'] as String? ?? '',
      type: json['type'] as String? ?? '',
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'type': type,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class CategoryApiResponse {
  final bool success;
  final CategoryData? data;
  final String message;

  CategoryApiResponse({
    required this.success,
    this.data,
    required this.message,
  });

  factory CategoryApiResponse.fromJson(dynamic json) {
    CategoryData? categoryData;
    if (json != null && json['data'] != null) {
      categoryData = CategoryData.fromJson(json);
    }

    return CategoryApiResponse(
      success: json != null && json['success'] is bool ? json['success'] : false,
      data: categoryData,
      message: json != null && json['message'] is String ? json['message'] : 'Unknown error occurred',
    );
  }
}

class CategoryData {
  final List<Category>? data;
  final List<dynamic>? links;
  final Meta? meta;

  CategoryData({
    this.data,
    this.links,
    this.meta,
  });

  factory CategoryData.fromJson(dynamic json) {
    List<Category>? categories = [];
    List<dynamic>? links;

    if (json != null) {
      // Jika json['data'] adalah List (untuk single category response atau create response)
      if (json['data'] is List) {
        categories = (json['data'] as List).map((e) => Category.fromJson(e)).toList();
        // Untuk response non-paginated, links dan meta tidak ada
        links = null;
      }
      // Jika json['data'] adalah Map, berarti ini adalah paginated response
      else if (json['data'] is Map) {
        // Cek apakah ini response paginated (memiliki field 'data' lagi di dalamnya)
        if (json['data']['data'] is List) {
          // Ini adalah response paginated, ambil daftar kategorinya
          categories = (json['data']['data'] as List).map((e) => Category.fromJson(e)).toList();
          links = json['data']['links'] as List<dynamic>?;
        } else {
          // Ini mungkin single category response yang dibungkus dalam map
          categories = [Category.fromJson(json['data'])];
          links = null;
        }
      }
      // Jika json itu sendiri langsung berisi array kategori (kasus tertentu)
      else if (json is List) {
        categories = (json as List).map((e) => Category.fromJson(e)).toList();
        links = null;
      }
    }

    return CategoryData(
      data: categories,
      links: links,
      meta: (json != null && json['data'] is Map && json['data']['meta'] != null) ? Meta.fromJson(json['data']['meta']) : (json?['meta'] != null ? Meta.fromJson(json['meta']) : null),
    );
  }
}

class Meta {
  final int? currentPage;
  final int? from;
  final int? lastPage;
  final String? path;
  final int? perPage;
  final int? to;
  final int? total;

  Meta({
    this.currentPage,
    this.from,
    this.lastPage,
    this.path,
    this.perPage,
    this.to,
    this.total,
  });

  factory Meta.fromJson(dynamic json) {
    return Meta(
      currentPage: (json is Map) ? json['current_page'] as int? : null,
      from: (json is Map) ? json['from'] as int? : null,
      lastPage: (json is Map) ? json['last_page'] as int? : null,
      path: (json is Map) ? json['path'] as String? : null,
      perPage: (json is Map) ? json['per_page'] as int? : null,
      to: (json is Map) ? json['to'] as int? : null,
      total: (json is Map) ? json['total'] as int? : null,
    );
  }
}