import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesLocalDataSource {
  static const String _favoritesKey = 'favorite_product_ids';

  Future<List<String>> getFavoriteProductIds() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = prefs.getString(_favoritesKey);
    if (favoritesJson == null) return [];
    final List<dynamic> favoritesList = json.decode(favoritesJson);
    return favoritesList.cast<String>();
  }

  Future<void> saveFavoriteProductIds(List<String> productIds) async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = json.encode(productIds);
    await prefs.setString(_favoritesKey, favoritesJson);
  }
}
