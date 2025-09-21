import 'dart:convert';
import '../../domain/entities/product.dart';
import 'review_model.dart';

class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.name,
    required super.description,
    required super.price,
    required super.images,
    required super.categoryId,
    required super.isFeatured,
    required super.stock,
    required super.rating,
    required super.reviewCount,
    super.reviews,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      images: List<String>.from(json['images'] as List),
      categoryId: json['categoryId'] as String,
      isFeatured: json['isFeatured'] as bool,
      stock: json['stock'] as int,
      rating: (json['rating'] as num).toDouble(),
      reviewCount: json['reviewCount'] as int,
      reviews:
          (json['reviews'] as List<dynamic>?)
              ?.map(
                (review) =>
                    ReviewModel.fromJson(review as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'images': images,
      'categoryId': categoryId,
      'isFeatured': isFeatured,
      'stock': stock,
      'rating': rating,
      'reviewCount': reviewCount,
      'reviews': reviews
          .map((review) => ReviewModel.fromEntity(review).toJson())
          .toList(),
    };
  }

  factory ProductModel.fromEntity(Product product) {
    return ProductModel(
      id: product.id,
      name: product.name,
      description: product.description,
      price: product.price,
      images: product.images,
      categoryId: product.categoryId,
      isFeatured: product.isFeatured,
      stock: product.stock,
      rating: product.rating,
      reviewCount: product.reviewCount,
      reviews: product.reviews,
    );
  }
}
