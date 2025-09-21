# Role-Based Access Control (RBAC) System Design for Ecommerce App

## Overview

This document outlines the design for implementing a role-based access control system in the ecommerce Flutter application. The system will differentiate between admin users and regular users, providing appropriate permissions and UI features for each role.

## 1. User Roles and Permissions

### Roles Defined
- **USER**: Regular customer with standard shopping permissions
- **ADMIN**: Administrative user with elevated permissions for managing the platform

### Permissions Matrix

| Permission | USER | ADMIN |
|------------|------|-------|
| View products | ✅ | ✅ |
| Add to cart | ✅ | ✅ |
| Checkout | ✅ | ✅ |
| View own orders | ✅ | ✅ |
| Manage profile | ✅ | ✅ |
| Manage products (CRUD) | ❌ | ✅ |
| Manage orders (view all, update status) | ❌ | ✅ |
| Manage users (view, update roles) | ❌ | ✅ |
| Access admin dashboard | ❌ | ✅ |

## 2. Database Schema Changes

### User Collection Updates

**Current User Document Structure:**
```json
{
  "id": "string",
  "email": "string",
  "name": "string",
  "phone": "string|null",
  "addresses": [],
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

**Updated User Document Structure:**
```json
{
  "id": "string",
  "email": "string",
  "name": "string",
  "phone": "string|null",
  "role": "USER|ADMIN",
  "addresses": [],
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

### Migration Strategy
- Add `role` field with default value "USER" to existing user documents
- Update user creation logic to include role field
- Implement server-side validation for role values

## 3. Domain Layer Changes

### User Entity Updates

**File: `lib/domain/entities/user.dart`**
```dart
class User {
  final String id;
  final String email;
  final String name;
  final String? phone;
  final UserRole role;  // New field
  final List<Address> addresses;

  const User({
    required this.id,
    required this.email,
    required this.name,
    this.phone,
    this.role = UserRole.user,  // Default to user
    this.addresses = const [],
  });

  bool get isAdmin => role == UserRole.admin;
  bool get isUser => role == UserRole.user;
}

enum UserRole {
  user,
  admin;

  String get displayName {
    switch (this) {
      case UserRole.user:
        return 'User';
      case UserRole.admin:
        return 'Admin';
    }
  }
}
```

### User Model Updates

**File: `lib/data/models/user_model.dart`**
- Add `role` field to constructor and JSON serialization
- Implement role parsing from Firestore

## 4. Authentication and Authorization Enforcement

### Auth State Updates

**File: `lib/bloc/auth/auth_state.dart`**
- Authenticated state remains the same, but user object now includes role
- Add role-based helper methods to Authenticated state

### Authorization Service

**New File: `lib/services/authorization_service.dart`**
```dart
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
}

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
```

### Route Guards

**File: `lib/routes/app_router.dart`**
- Add admin route protection
- Redirect unauthorized access attempts
- Add admin-specific routes

### BLoC-Level Enforcement

**UserBloc Updates:**
- Add role validation in user management operations
- Prevent non-admin users from updating roles

**ProductBloc Updates:**
- Add admin-only events for product CRUD operations
- Validate permissions before executing admin actions

**OrderBloc Updates:**
- Add admin events for order management
- Implement order status updates (admin only)

## 5. UI Differentiation

### Navigation Updates

**File: `lib/widgets/scaffold_with_bottom_nav.dart`**
- Conditionally show admin navigation items
- Add admin dashboard tab for admin users

### Profile Screen Updates

**File: `lib/screens/profile_screen.dart`**
- Show role information in profile display
- Add admin menu items for admin users:
  - Manage Products
  - Manage Orders
  - Manage Users
  - Admin Dashboard

### Admin Screens (New)

**Admin Dashboard Screen:**
- Overview metrics (total users, orders, products)
- Recent activity
- Quick actions

**Product Management Screen:**
- List all products with CRUD operations
- Add/edit product forms
- Bulk operations

**Order Management Screen:**
- List all orders with filtering
- Update order status
- Order details view

**User Management Screen:**
- List all users
- Update user roles (admin only)
- User activity overview

## 6. Admin Features Implementation

### Product Management

**Core CRUD Operations:**
- **Create Product**: Admin form with fields for name, description, price, images, category, stock quantity, SKU
- **Read/Update Product**: Detailed product editing with image upload/management
- **Delete Product**: Soft delete with confirmation dialog and impact assessment
- **Bulk Operations**: Select multiple products for batch updates, deletion, or category changes

**Category Management:**
- Create/edit/delete product categories
- Hierarchical category structure (parent/child relationships)
- Category-based product filtering and organization

**Advanced Features:**
- **Inventory Management**: Stock level alerts, low stock notifications, automatic reorder suggestions
- **Product Analytics**: View metrics like sales volume, revenue, popular products, conversion rates
- **Bulk Import/Export**: CSV import for product data, export for backup or analysis
- **Product Variants**: Support for size, color, style variations with pricing
- **SEO Management**: Meta descriptions, URL slugs, search optimization

**UI Components:**
- Product list with search, filter, and sort capabilities
- Product detail modal/drawer for quick edits
- Image gallery management with drag-and-drop upload
- Rich text editor for product descriptions

### Order Management

**Order Overview:**
- Comprehensive order list with pagination and advanced filtering
- Filter by status, date range, customer, order value, payment method
- Search by order ID, customer name, email, or product name
- Export order data to CSV/PDF for reporting

**Order Status Workflow:**
- **Pending**: Initial state after checkout
- **Processing**: Order confirmed, payment verified
- **Shipped**: Order dispatched with tracking number
- **Delivered**: Order completed successfully
- **Cancelled**: Order cancelled (by admin or customer)
- **Refunded**: Order refunded with reason tracking

**Order Operations:**
- **Status Updates**: One-click status changes with automatic email notifications
- **Order Details**: Complete order view with customer info, items, shipping, payment details
- **Modify Orders**: Add/remove items, change quantities, update shipping addresses
- **Order Notes**: Internal admin notes and customer communication history
- **Tracking Integration**: Integration with shipping providers for real-time tracking

**Reporting and Analytics:**
- Order volume by period (daily, weekly, monthly)
- Revenue analytics with growth trends
- Popular products and categories
- Customer order frequency and lifetime value
- Geographic sales distribution

### User Management

**User Administration:**
- Complete user directory with search and filtering
- User profiles with order history, activity logs, and preferences
- Role management with promotion/demotion workflows
- Account status control (active, suspended, deactivated)

**User Analytics:**
- User registration trends and growth metrics
- Active user statistics and engagement rates
- Customer segmentation by order value, frequency, location
- User behavior analysis (browsing patterns, cart abandonment)

**Account Management:**
- **Bulk User Operations**: Select multiple users for role changes or status updates
- **User Communication**: Send notifications, newsletters, or targeted messages
- **Account Recovery**: Reset passwords, recover accounts for users
- **Data Export**: GDPR-compliant user data export functionality

**Security Features:**
- **Audit Trail**: Complete log of all user-related admin actions
- **Suspicious Activity Detection**: Flag unusual login patterns or bulk actions
- **Two-Factor Authentication**: Enforce 2FA for admin accounts
- **Session Management**: View active sessions and force logout capabilities

### Admin Dashboard

**Key Metrics Display:**
- Total revenue (today, this week, this month, all time)
- Order count and conversion rates
- Active users and new registrations
- Low stock alerts and inventory status
- Recent orders and customer feedback

**Quick Actions Panel:**
- Create new product
- View pending orders
- Manage user roles
- Generate reports
- System health checks

**Charts and Visualizations:**
- Revenue trends over time
- Order status distribution
- Popular products chart
- User growth metrics
- Geographic sales map

**Real-time Notifications:**
- New order alerts
- Low stock warnings
- System error notifications
- Security alerts

### Additional Admin Features

**Content Management:**
- Static page editing (About Us, Terms of Service, Privacy Policy)
- Banner and promotional content management
- Email template customization
- FAQ and help center management

**System Configuration:**
- Payment gateway settings
- Shipping rate configuration
- Tax rule management
- Email/SMS notification settings
- API key management for third-party integrations

**Reporting System:**
- Custom report builder with date ranges and filters
- Scheduled report generation and email delivery
- Export capabilities (PDF, Excel, CSV)
- Dashboard sharing with other admins

**Integration Management:**
- Third-party service connections (payment processors, shipping providers)
- API webhook configuration
- Data synchronization settings
- Import/export job monitoring

## 7. BLoC Architecture Changes

### New Admin BLoC

**File: `lib/bloc/admin/admin_bloc.dart`**
```dart
abstract class AdminEvent {}
class LoadAdminDashboard extends AdminEvent {}
class LoadAllUsers extends AdminEvent {}
class UpdateUserRole extends AdminEvent {
  final String userId;
  final UserRole newRole;
}

abstract class AdminState {}
class AdminDashboardLoaded extends AdminState {
  final AdminMetrics metrics;
}
class AllUsersLoaded extends AdminState {
  final List<User> users;
}
```

### Existing BLoC Updates

**ProductBloc:**
- Add admin events: `CreateProduct`, `UpdateProduct`, `DeleteProduct`
- Add corresponding states

**OrderBloc:**
- Add admin events: `LoadAllOrders`, `UpdateOrderStatus`
- Add admin states: `AllOrdersLoaded`

**UserBloc:**
- Add admin events: `LoadAllUsers`, `UpdateUserRole`
- Add admin states: `AllUsersLoaded`

## 8. Security Considerations

### Role Assignment Security
- **Server-side validation**: All role changes must be validated on Firebase Functions
- **Admin-only operations**: Only admin users can modify roles
- **Audit logging**: Log all role changes with timestamp, actor, and target
- **Two-person rule**: Consider requiring multiple admins for critical role changes

### Authorization Enforcement
- **Client-side checks**: Prevent UI from showing unauthorized actions
- **Server-side validation**: Firebase Security Rules must enforce permissions
- **API-level protection**: Backend functions validate user permissions
- **Session validation**: Regularly verify user roles during session

### Data Protection
- **Field-level security**: Use Firestore security rules to restrict data access
- **Encryption**: Sensitive data should be encrypted at rest and in transit
- **Access logging**: Log all admin actions for compliance

### Firebase Security Rules Example
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      // Only admins can update roles
      allow update: if request.auth != null &&
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'ADMIN';
    }

    // Products: read for all authenticated, write for admins
    match /products/{productId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null &&
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'ADMIN';
    }

    // Orders: users see own orders, admins see all
    match /orders/{orderId} {
      allow read: if request.auth != null &&
        (request.auth.uid == resource.data.userId ||
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'ADMIN');
      allow write: if request.auth != null &&
        (request.auth.uid == resource.data.userId ||
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'ADMIN');
    }
  }
}
```

## 9. Implementation Phases

### Phase 1: Core RBAC Infrastructure
1. Update User entity and model
2. Add role field to database
3. Implement authorization service
4. Update authentication flow

### Phase 2: Admin UI and Features
1. Create admin screens
2. Implement admin BLoC
3. Add admin navigation
4. Update existing screens for role-based UI

### Phase 3: Security Hardening
1. Implement Firebase Security Rules
2. Add server-side validation functions
3. Implement audit logging
4. Add comprehensive testing

### Phase 4: Testing and Deployment
1. Unit and integration tests
2. Security testing
3. User acceptance testing
4. Production deployment with gradual rollout

## 10. Testing Strategy

### Unit Tests
- Authorization service logic
- Role-based UI rendering
- BLoC state transitions with role checks

### Integration Tests
- End-to-end admin workflows
- Permission enforcement across app
- Database security rule validation

### Security Testing
- Attempt unauthorized actions
- Role escalation prevention
- Data access validation

## 11. Migration and Rollout Plan

### Database Migration
1. Add role field to existing users (default: USER)
2. Create initial admin user(s)
3. Update application code to handle roles

### Gradual Rollout
1. Deploy RBAC infrastructure
2. Enable admin features for designated users
3. Monitor for issues
4. Full rollout to all users

### Rollback Plan
- Feature flags to disable RBAC features
- Database backup before migration
- Clear rollback procedures documented

This design provides a comprehensive, secure, and scalable RBAC system that maintains backward compatibility while adding powerful administrative capabilities to the ecommerce platform.