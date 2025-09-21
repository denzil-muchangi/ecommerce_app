import '../entities/product.dart';

abstract class FavoritesRepository {
  Future<List<String>> getFavoriteProductIds();
  Future<void> addToFavorites(String productId);
  Future<void> removeFromFavorites(String productId);
  Future<bool> isFavorite(String productId);
  Future<void> toggleFavorite(String productId);
  Future<List<Product>> getFavoriteProducts();
}
