import 'dart:convert';
import '../models/product_model.dart';
import '../models/category_model.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getProducts();
  Future<List<ProductModel>> getFeaturedProducts();
  Future<List<ProductModel>> getProductsByCategory(String categoryId);
  Future<ProductModel> getProductById(String id);
  Future<List<CategoryModel>> getCategories();
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  // Mock data for demonstration
  final List<Map<String, dynamic>> _mockProducts = [
    {
      'id': '1',
      'name': 'Wireless Headphones',
      'description': 'High-quality wireless headphones with noise cancellation',
      'price': 199.99,
      'images': ['https://via.placeholder.com/300'],
      'categoryId': 'electronics',
      'isFeatured': true,
      'stock': 50,
      'rating': 4.5,
      'reviewCount': 120,
    },
    {
      'id': '2',
      'name': 'Smart Watch',
      'description': 'Fitness tracking smart watch with heart rate monitor',
      'price': 299.99,
      'images': ['https://via.placeholder.com/300'],
      'categoryId': 'electronics',
      'isFeatured': true,
      'stock': 30,
      'rating': 4.2,
      'reviewCount': 85,
    },
    {
      'id': '3',
      'name': 'Cotton T-Shirt',
      'description': 'Comfortable cotton t-shirt in various colors',
      'price': 19.99,
      'images': ['https://via.placeholder.com/300'],
      'categoryId': 'clothing',
      'isFeatured': false,
      'stock': 100,
      'rating': 4.0,
      'reviewCount': 45,
    },
    {
      'id': '4',
      'name': 'Running Shoes',
      'description': 'Lightweight running shoes for all terrains',
      'price': 89.99,
      'images': ['https://via.placeholder.com/300'],
      'categoryId': 'sports',
      'isFeatured': true,
      'stock': 75,
      'rating': 4.3,
      'reviewCount': 67,
    },
    {
      'id': '5',
      'name': 'Coffee Maker',
      'description': 'Automatic coffee maker with programmable timer',
      'price': 79.99,
      'images': ['https://via.placeholder.com/300'],
      'categoryId': 'home',
      'isFeatured': false,
      'stock': 25,
      'rating': 4.1,
      'reviewCount': 32,
    },
  ];

  final List<Map<String, dynamic>> _mockCategories = [
    {
      'id': 'electronics',
      'name': 'Electronics',
      'description': 'Electronic devices and gadgets',
      'imageUrl': 'https://via.placeholder.com/150',
    },
    {
      'id': 'clothing',
      'name': 'Clothing',
      'description': 'Fashion and apparel',
      'imageUrl': 'https://via.placeholder.com/150',
    },
    {
      'id': 'sports',
      'name': 'Sports',
      'description': 'Sports equipment and accessories',
      'imageUrl': 'https://via.placeholder.com/150',
    },
    {
      'id': 'home',
      'name': 'Home & Garden',
      'description': 'Home improvement and garden supplies',
      'imageUrl': 'https://via.placeholder.com/150',
    },
  ];

  @override
  Future<List<ProductModel>> getProducts() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockProducts.map((json) => ProductModel.fromJson(json)).toList();
  }

  @override
  Future<List<ProductModel>> getFeaturedProducts() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockProducts
        .where((product) => product['isFeatured'] == true)
        .map((json) => ProductModel.fromJson(json))
        .toList();
  }

  @override
  Future<List<ProductModel>> getProductsByCategory(String categoryId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _mockProducts
        .where((product) => product['categoryId'] == categoryId)
        .map((json) => ProductModel.fromJson(json))
        .toList();
  }

  @override
  Future<ProductModel> getProductById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final productJson = _mockProducts.firstWhere(
      (product) => product['id'] == id,
      orElse: () => throw Exception('Product not found'),
    );
    return ProductModel.fromJson(productJson);
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockCategories.map((json) => CategoryModel.fromJson(json)).toList();
  }
}
