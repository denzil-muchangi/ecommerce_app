import '../models/order_model.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/entities/address.dart';

abstract class OrderRemoteDataSource {
  Future<OrderModel> placeOrder({
    required String userId,
    required List<CartItem> items,
    required Address shippingAddress,
    required String paymentMethod,
    required double subtotal,
    required double tax,
    required double shipping,
    required double total,
  });
  Future<List<OrderModel>> getOrderHistory(String userId);
  Future<OrderModel> getOrderById(String orderId);
}
