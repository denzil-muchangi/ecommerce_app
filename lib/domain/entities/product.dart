import 'review.dart';

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final List<String> images;
  final String categoryId;
  final bool isFeatured;
  final int stock;
  final double rating;
  final int reviewCount;
  final List<Review> reviews;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.images,
    required this.categoryId,
    required this.isFeatured,
    required this.stock,
    required this.rating,
    required this.reviewCount,
    this.reviews = const [],
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Product && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
