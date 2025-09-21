import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';
import '../firestore_collections.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getProducts();
  Future<List<ProductModel>> getFeaturedProducts();
  Future<List<ProductModel>> getProductsByCategory(String categoryId);
  Future<ProductModel> getProductById(String id);
  Future<List<CategoryModel>> getCategories();
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<ProductModel>> getProducts() async {
    try {
      final querySnapshot = await _firestore
          .collection(FirestoreCollections.products)
          .orderBy('name')
          .get();

      return querySnapshot.docs.map((doc) {
        return ProductModel.fromJson({...doc.data(), 'id': doc.id});
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch products: $e');
    }
  }

  @override
  Future<List<ProductModel>> getFeaturedProducts() async {
    try {
      final querySnapshot = await _firestore
          .collection(FirestoreCollections.products)
          .where('isFeatured', isEqualTo: true)
          .orderBy('name')
          .get();

      return querySnapshot.docs.map((doc) {
        return ProductModel.fromJson({...doc.data(), 'id': doc.id});
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch featured products: $e');
    }
  }

  @override
  Future<List<ProductModel>> getProductsByCategory(String categoryId) async {
    try {
      final querySnapshot = await _firestore
          .collection(FirestoreCollections.products)
          .where('categoryId', isEqualTo: categoryId)
          .orderBy('name')
          .get();

      return querySnapshot.docs.map((doc) {
        return ProductModel.fromJson({...doc.data(), 'id': doc.id});
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch products by category: $e');
    }
  }

  @override
  Future<ProductModel> getProductById(String id) async {
    try {
      final docSnapshot = await _firestore
          .collection(FirestoreCollections.products)
          .doc(id)
          .get();

      if (!docSnapshot.exists) {
        throw Exception('Product not found');
      }

      return ProductModel.fromJson({
        ...docSnapshot.data()!,
        'id': docSnapshot.id,
      });
    } catch (e) {
      throw Exception('Failed to fetch product: $e');
    }
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    try {
      final querySnapshot = await _firestore
          .collection(FirestoreCollections.categories)
          .orderBy('name')
          .get();

      return querySnapshot.docs.map((doc) {
        return CategoryModel.fromJson({...doc.data(), 'id': doc.id});
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch categories: $e');
    }
  }
}
