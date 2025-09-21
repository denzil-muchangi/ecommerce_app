import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_item_model.dart';
import '../../domain/entities/cart_item.dart';

class CartLocalDataSource {
  static const String _cartKey = 'cart_items';

  Future<List<CartItem>> getCartItems() async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = prefs.getString(_cartKey);
    if (cartJson == null) return [];
    final List<dynamic> cartList = json.decode(cartJson);
    return cartList.map((item) => CartItemModel.fromJson(item)).toList();
  }

  Future<void> saveCartItems(List<CartItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final cartList = items
        .map((item) => CartItemModel.fromEntity(item).toJson())
        .toList();
    final cartJson = json.encode(cartList);
    await prefs.setString(_cartKey, cartJson);
  }
}
