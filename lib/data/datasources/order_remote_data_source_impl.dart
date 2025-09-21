import 'dart:convert';
import 'order_remote_data_source.dart';
import '../models/order_model.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/entities/address.dart';
import '../models/cart_item_model.dart';
import '../models/address_model.dart';

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  // Mock storage for orders
  final List<Map<String, dynamic>> _mockOrders = [];

  @override
  Future<OrderModel> placeOrder({
    required String userId,
    required List<CartItem> items,
    required Address shippingAddress,
    required String paymentMethod,
    required double subtotal,
    required double tax,
    required double shipping,
    required double total,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1000));

    final orderId = 'ORD${DateTime.now().millisecondsSinceEpoch}';
    final now = DateTime.now();

    final orderJson = {
      'id': orderId,
      'userId': userId,
      'items': items
          .map((item) => CartItemModel.fromEntity(item).toJson())
          .toList(),
      'shippingAddress': AddressModel.fromEntity(shippingAddress).toJson(),
      'paymentMethod': paymentMethod,
      'status': 'pending',
      'subtotal': subtotal,
      'tax': tax,
      'shipping': shipping,
      'total': total,
      'createdAt': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
    };

    _mockOrders.add(orderJson);

    return OrderModel.fromJson(orderJson);
  }

  @override
  Future<List<OrderModel>> getOrderHistory(String userId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    final userOrders = _mockOrders
        .where((order) => order['userId'] == userId)
        .toList();

    // Sort by created date (newest first)
    userOrders.sort(
      (a, b) => DateTime.parse(
        b['createdAt'],
      ).compareTo(DateTime.parse(a['createdAt'])),
    );

    return userOrders.map((json) => OrderModel.fromJson(json)).toList();
  }

  @override
  Future<OrderModel> getOrderById(String orderId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    final orderJson = _mockOrders.firstWhere(
      (order) => order['id'] == orderId,
      orElse: () => throw Exception('Order not found'),
    );

    return OrderModel.fromJson(orderJson);
  }
}
