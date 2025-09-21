import 'cart_item.dart';
import 'address.dart';

enum OrderStatus { pending, processing, shipped, delivered, cancelled }

class Order {
  final String id;
  final String userId;
  final List<CartItem> items;
  final Address shippingAddress;
  final String paymentMethod;
  final OrderStatus status;
  final double subtotal;
  final double tax;
  final double shipping;
  final double total;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? paymentReference;
  final String? paymentStatus;

  const Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.shippingAddress,
    required this.paymentMethod,
    required this.status,
    required this.subtotal,
    required this.tax,
    required this.shipping,
    required this.total,
    required this.createdAt,
    required this.updatedAt,
    this.paymentReference,
    this.paymentStatus,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Order && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
