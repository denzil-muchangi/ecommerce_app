import '../domain/entities/user.dart';

enum Permission {
  viewProducts,
  addToCart,
  checkout,
  viewOwnOrders,
  manageProfile,
  manageProducts,
  manageOrders,
  manageUsers,
  accessAdminDashboard,
}

class AuthorizationService {
  static bool hasPermission(User user, Permission permission) {
    switch (permission) {
      case Permission.viewProducts:
      case Permission.addToCart:
      case Permission.checkout:
      case Permission.viewOwnOrders:
      case Permission.manageProfile:
        return true; // All authenticated users

      case Permission.manageProducts:
      case Permission.manageOrders:
      case Permission.manageUsers:
      case Permission.accessAdminDashboard:
        return user.isAdmin;
    }
  }

  static bool canAccessAdminFeatures(User user) {
    return user.isAdmin;
  }

  static bool canManageProducts(User user) {
    return user.isAdmin;
  }

  static bool canManageOrders(User user) {
    return user.isAdmin;
  }

  static bool canManageUsers(User user) {
    return user.isAdmin;
  }

  static bool canUpdateUserRole(User currentUser, User targetUser) {
    // Only admins can update roles, and they cannot change their own role
    return currentUser.isAdmin && currentUser.id != targetUser.id;
  }
}
