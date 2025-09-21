import 'dart:convert';
import '../../domain/entities/cart_item.dart';

class CartItemModel extends CartItem {
  const CartItemModel({
    required super.productId,
    required super.name,
    required super.image,
    required super.quantity,
    required super.price,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      productId: json['productId'] as String,
      name: json['name'] as String,
      image: json['image'] as String,
      quantity: json['quantity'] as int,
      price: (json['price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'name': name,
      'image': image,
      'quantity': quantity,
      'price': price,
    };
  }

  factory CartItemModel.fromEntity(CartItem cartItem) {
    return CartItemModel(
      productId: cartItem.productId,
      name: cartItem.name,
      image: cartItem.image,
      quantity: cartItem.quantity,
      price: cartItem.price,
    );
  }
}
