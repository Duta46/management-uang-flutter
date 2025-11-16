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