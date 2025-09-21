import '../../domain/entities/product.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../datasources/favorites_local_data_source.dart';
import 'product_repository.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  final FavoritesLocalDataSource localDataSource;
  final ProductRepositoryImpl productRepository;

  FavoritesRepositoryImpl(this.localDataSource, this.productRepository);

  @override
  Future<List<String>> getFavoriteProductIds() async {
    return await localDataSource.getFavoriteProductIds();
  }

  @override
  Future<void> addToFavorites(String productId) async {
    final favorites = await getFavoriteProductIds();
    if (!favorites.contains(productId)) {
      favorites.add(productId);
      await localDataSource.saveFavoriteProductIds(favorites);
    }
  }

  @override
  Future<void> removeFromFavorites(String productId) async {
    final favorites = await getFavoriteProductIds();
    favorites.remove(productId);
    await localDataSource.saveFavoriteProductIds(favorites);
  }

  @override
  Future<bool> isFavorite(String productId) async {
    final favorites = await getFavoriteProductIds();
    return favorites.contains(productId);
  }

  @override
  Future<void> toggleFavorite(String productId) async {
    final isFav = await isFavorite(productId);
    if (isFav) {
      await removeFromFavorites(productId);
    } else {
      await addToFavorites(productId);
    }
  }

  @override
  Future<List<Product>> getFavoriteProducts() async {
    final favoriteIds = await getFavoriteProductIds();
    final products = <Product>[];
    for (final id in favoriteIds) {
      try {
        final product = await productRepository.getProductById(id);
        products.add(product);
      } catch (e) {
        // Skip products that can't be loaded
        continue;
      }
    }
    return products;
  }
}
