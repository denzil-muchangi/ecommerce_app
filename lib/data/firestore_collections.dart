/// Firestore collection names and structure definitions
/// This file defines the Firestore database structure for the ecommerce app

class FirestoreCollections {
  // Main collections
  static const String users = 'users';
  static const String products = 'products';
  static const String categories = 'categories';
  static const String orders = 'orders';

  // Subcollections (if needed in the future)
  // static const String userOrders = 'orders'; // under users
  // static const String productReviews = 'reviews'; // under products
}

/// Firestore document structure notes:
/// - users: User documents with user data
/// - products: Product documents with product information
/// - categories: Category documents for product categorization
/// - orders: Order documents containing order details
///
/// Each collection should follow the corresponding model structure
/// defined in lib/data/models/
