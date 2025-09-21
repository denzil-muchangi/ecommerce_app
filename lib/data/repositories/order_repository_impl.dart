import '../../domain/entities/order.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/entities/address.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/order_remote_data_source.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource remoteDataSource;

  OrderRepositoryImpl(this.remoteDataSource);

  @override
  Future<Order> placeOrder({
    required String userId,
    required List<CartItem> items,
    required Address shippingAddress,
    required String paymentMethod,
    required double subtotal,
    required double tax,
    required double shipping,
    required double total,
    String? paymentReference,
    String? paymentStatus,
  }) async {
    final orderModel = await remoteDataSource.placeOrder(
      userId: userId,
      items: items,
      shippingAddress: shippingAddress,
      paymentMethod: paymentMethod,
      subtotal: subtotal,
      tax: tax,
      shipping: shipping,
      total: total,
      paymentReference: paymentReference,
      paymentStatus: paymentStatus,
    );
    return orderModel;
  }

  @override
  Future<List<Order>> getOrderHistory(String userId) async {
    final orderModels = await remoteDataSource.getOrderHistory(userId);
    return orderModels;
  }

  @override
  Future<Order> getOrderById(String orderId) async {
    final orderModel = await remoteDataSource.getOrderById(orderId);
    return orderModel;
  }
}
