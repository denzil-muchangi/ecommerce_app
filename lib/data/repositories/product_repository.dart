import '../../domain/entities/product.dart';
import '../../domain/entities/category.dart';
import '../datasources/product_remote_data_source.dart';

abstract class ProductRepository {
  Future<List<Product>> getProducts();
  Future<List<Product>> getFeaturedProducts();
  Future<List<Product>> getProductsByCategory(String categoryId);
  Future<Product> getProductById(String id);
  Future<List<Category>> getCategories();
  Future<List<Product>> searchProducts(String query);
}

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;

  ProductRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Product>> getProducts() async {
    final productModels = await remoteDataSource.getProducts();
    return productModels;
  }

  @override
  Future<List<Product>> getFeaturedProducts() async {
    final productModels = await remoteDataSource.getFeaturedProducts();
    return productModels;
  }

  @override
  Future<List<Product>> getProductsByCategory(String categoryId) async {
    final productModels = await remoteDataSource.getProductsByCategory(
      categoryId,
    );
    return productModels;
  }

  @override
  Future<Product> getProductById(String id) async {
    final productModel = await remoteDataSource.getProductById(id);
    return productModel;
  }

  @override
  Future<List<Category>> getCategories() async {
    final categoryModels = await remoteDataSource.getCategories();
    return categoryModels;
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    // Fetch all products from the remote data source
    final allProducts = await remoteDataSource.getProducts();
    // Convert query to lowercase for case-insensitive search
    final lowercaseQuery = query.toLowerCase();
    // Filter products based on name or description containing the query
    return allProducts.where((product) {
      return product.name.toLowerCase().contains(lowercaseQuery) ||
          product.description.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }
}
