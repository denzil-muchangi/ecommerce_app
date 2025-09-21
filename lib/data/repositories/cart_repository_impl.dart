import '../../domain/entities/cart_item.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_local_data_source.dart';

class CartRepositoryImpl implements CartRepository {
  final CartLocalDataSource localDataSource;

  CartRepositoryImpl(this.localDataSource);

  @override
  Future<List<CartItem>> getCartItems() async {
    return await localDataSource.getCartItems();
  }

  @override
  Future<void> addItem(CartItem item) async {
    final items = await getCartItems();
    final existingIndex = items.indexWhere(
      (i) => i.productId == item.productId,
    );
    if (existingIndex != -1) {
      final existingItem = items[existingIndex];
      final updatedItem = CartItem(
        productId: existingItem.productId,
        name: existingItem.name,
        image: existingItem.image,
        quantity: existingItem.quantity + item.quantity,
        price: item.price, // Update price to new one if needed
      );
      items[existingIndex] = updatedItem;
    } else {
      items.add(item);
    }
    await localDataSource.saveCartItems(items);
  }

  @override
  Future<void> removeItem(String productId) async {
    final items = await getCartItems();
    items.removeWhere((item) => item.productId == productId);
    await localDataSource.saveCartItems(items);
  }

  @override
  Future<void> updateQuantity(String productId, int quantity) async {
    final items = await getCartItems();
    final index = items.indexWhere((item) => item.productId == productId);
    if (index != -1) {
      if (quantity > 0) {
        final updatedItem = CartItem(
          productId: items[index].productId,
          name: items[index].name,
          image: items[index].image,
          quantity: quantity,
          price: items[index].price,
        );
        items[index] = updatedItem;
      } else {
        items.removeAt(index);
      }
      await localDataSource.saveCartItems(items);
    }
  }

  @override
  Future<void> clearCart() async {
    await localDataSource.saveCartItems([]);
  }
}
