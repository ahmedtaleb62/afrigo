class DishCategory {
  const DishCategory({required this.id, required this.name, required this.sortOrder});

  final String id;
  final String name;
  final int sortOrder;

  factory DishCategory.fromRow(Map<String, dynamic> row) => DishCategory(
        id: row['id'] as String,
        name: row['name'] as String,
        sortOrder: (row['sort_order'] as num?)?.toInt() ?? 0,
      );
}

/// Mirrors a `restaurant_dishes` row.
class Dish {
  const Dish({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.description,
    required this.price,
    required this.isAvailable,
    required this.availableForDelivery,
    required this.stock,
    this.imageUrl,
  });

  final String id;
  final String categoryId;
  final String name;
  final String description;
  final num price;
  final bool isAvailable;
  final bool availableForDelivery;
  final int stock;
  final String? imageUrl;

  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;

  factory Dish.fromRow(Map<String, dynamic> row) => Dish(
        id: row['id'] as String,
        categoryId: row['category_id'] as String? ?? '',
        name: row['name'] as String,
        description: (row['description'] as String?) ?? '',
        price: (row['price'] as num?) ?? 0,
        isAvailable: row['is_available'] as bool? ?? true,
        availableForDelivery: row['available_for_delivery'] as bool? ?? true,
        stock: (row['stock_quantity'] as num?)?.toInt() ?? 0,
        imageUrl: row['image_url'] as String?,
      );

  Dish copyWith({bool? isAvailable, bool? availableForDelivery, int? stock, String? imageUrl}) => Dish(
        id: id,
        categoryId: categoryId,
        name: name,
        description: description,
        price: price,
        isAvailable: isAvailable ?? this.isAvailable,
        availableForDelivery: availableForDelivery ?? this.availableForDelivery,
        stock: stock ?? this.stock,
        imageUrl: imageUrl ?? this.imageUrl,
      );

  (String label, int bg, int fg) get stockBadge => switch (stock) {
        0 => ('نفذ المخزون', 0xFFFEE2E2, 0xFFDC2626),
        <= 5 => ('كمية منخفضة', 0xFFFEF9C3, 0xFF854D0E),
        _ => ('متوفر', 0xFFDCFCE7, 0xFF166534),
      };
}
