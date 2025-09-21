import '../../domain/entities/order.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/entities/address.dart';

abstract class OrderRepository {
  Future<Order> placeOrder({
    required String userId,
    required List<CartItem> items,
    required Address shippingAddress,
    required String paymentMethod,
    required double subtotal,
    required double tax,
    required double shipping,
    required double total,
  });
  Future<List<Order>> getOrderHistory(String userId);
  Future<Order> getOrderById(String orderId);
}
