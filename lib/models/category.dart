class Category {
  final String id;
  final String name;
  final int? parentId;

  Category({
    required this.id,
    required this.name,
    this.parentId,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['category_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['category_name'] ?? json['name'] ?? '',
      parentId: json['parent_id'] != null ? int.tryParse(json['parent_id'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'parent_id': parentId,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Category && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Category(id: $id, name: $name, parentId: $parentId)';
  }
}