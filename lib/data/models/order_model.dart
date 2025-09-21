import 'dart:convert';
import '../../domain/entities/order.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/entities/address.dart';
import 'cart_item_model.dart';
import 'address_model.dart';

class OrderModel extends Order {
  const OrderModel({
    required super.id,
    required super.userId,
    required super.items,
    required super.shippingAddress,
    required super.paymentMethod,
    required super.status,
    required super.subtotal,
    required super.tax,
    required super.shipping,
    required super.total,
    required super.createdAt,
    required super.updatedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      items: (json['items'] as List<dynamic>)
          .map((item) => CartItemModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      shippingAddress: AddressModel.fromJson(
        json['shippingAddress'] as Map<String, dynamic>,
      ),
      paymentMethod: json['paymentMethod'] as String,
      status: OrderStatus.values.byName(json['status'] as String),
      subtotal: (json['subtotal'] as num).toDouble(),
      tax: (json['tax'] as num).toDouble(),
      shipping: (json['shipping'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'items': items
          .map((item) => CartItemModel.fromEntity(item).toJson())
          .toList(),
      'shippingAddress': AddressModel.fromEntity(shippingAddress).toJson(),
      'paymentMethod': paymentMethod,
      'status': status.toString().split('.').last,
      'subtotal': subtotal,
      'tax': tax,
      'shipping': shipping,
      'total': total,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory OrderModel.fromEntity(Order order) {
    return OrderModel(
      id: order.id,
      userId: order.userId,
      items: order.items,
      shippingAddress: order.shippingAddress,
      paymentMethod: order.paymentMethod,
      status: order.status,
      subtotal: order.subtotal,
      tax: order.tax,
      shipping: order.shipping,
      total: order.total,
      createdAt: order.createdAt,
      updatedAt: order.updatedAt,
    );
  }
}
