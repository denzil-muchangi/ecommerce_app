import 'package:equatable/equatable.dart';
import '../../../domain/entities/cart_item.dart';
import '../../../domain/entities/address.dart';

abstract class OrderEvent extends Equatable {
  const OrderEvent();

  @override
  List<Object> get props => [];
}

class PlaceOrder extends OrderEvent {
  final String userId;
  final List<CartItem> items;
  final Address shippingAddress;
  final String paymentMethod;
  final double subtotal;
  final double tax;
  final double shipping;
  final double total;
  final String? paymentReference;
  final String? paymentStatus;

  const PlaceOrder({
    required this.userId,
    required this.items,
    required this.shippingAddress,
    required this.paymentMethod,
    required this.subtotal,
    required this.tax,
    required this.shipping,
    required this.total,
    this.paymentReference,
    this.paymentStatus,
  });

  @override
  List<Object> get props => [
    userId,
    items,
    shippingAddress,
    paymentMethod,
    subtotal,
    tax,
    shipping,
    total,
    if (paymentReference != null) paymentReference!,
    if (paymentStatus != null) paymentStatus!,
  ];
}

class LoadOrderHistory extends OrderEvent {
  final String userId;

  const LoadOrderHistory(this.userId);

  @override
  List<Object> get props => [userId];
}

class LoadOrderDetail extends OrderEvent {
  final String orderId;

  const LoadOrderDetail(this.orderId);

  @override
  List<Object> get props => [orderId];
}
