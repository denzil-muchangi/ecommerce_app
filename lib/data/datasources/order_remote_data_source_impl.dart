import 'package:cloud_firestore/cloud_firestore.dart';
import 'order_remote_data_source.dart';
import '../models/order_model.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/entities/address.dart';
import '../models/cart_item_model.dart';
import '../models/address_model.dart';
import '../firestore_collections.dart';

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
    String? paymentReference,
    String? paymentStatus,
  }) async {
    try {
      final orderId = 'ORD${DateTime.now().millisecondsSinceEpoch}';
      final now = DateTime.now();

      final orderData = {
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
        'paymentReference': paymentReference,
        'paymentStatus': paymentStatus,
      };

      await _firestore
          .collection(FirestoreCollections.orders)
          .doc(orderId)
          .set(orderData);

      return OrderModel.fromJson({...orderData, 'id': orderId});
    } catch (e) {
      throw Exception('Failed to place order: $e');
    }
  }

  @override
  Future<List<OrderModel>> getOrderHistory(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(FirestoreCollections.orders)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        return OrderModel.fromJson({...doc.data(), 'id': doc.id});
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch order history: $e');
    }
  }

  @override
  Future<OrderModel> getOrderById(String orderId) async {
    try {
      final docSnapshot = await _firestore
          .collection(FirestoreCollections.orders)
          .doc(orderId)
          .get();

      if (!docSnapshot.exists) {
        throw Exception('Order not found');
      }

      return OrderModel.fromJson({
        ...docSnapshot.data()!,
        'id': docSnapshot.id,
      });
    } catch (e) {
      throw Exception('Failed to fetch order: $e');
    }
  }
}
