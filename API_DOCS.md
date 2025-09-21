# API Documentation

This document provides detailed API documentation for the key classes in the e-commerce Flutter application.

## Domain Entities

### Product

Represents a product in the e-commerce system.

**Properties:**
- `id` (String): Unique identifier for the product
- `name` (String): Product name
- `description` (String): Detailed product description
- `price` (double): Product price
- `images` (List<String>): List of product image URLs
- `categoryId` (String): ID of the product's category
- `isFeatured` (bool): Whether the product is featured
- `stock` (int): Available stock quantity
- `rating` (double): Average customer rating
- `reviewCount` (int): Number of customer reviews
- `reviews` (List<Review>): List of customer reviews

**Usage:**
```dart
final product = Product(
  id: '1',
  name: 'iPhone 15',
  description: 'Latest iPhone model',
  price: 999.99,
  images: ['image1.jpg', 'image2.jpg'],
  categoryId: 'electronics',
  isFeatured: true,
  stock: 50,
  rating: 4.5,
  reviewCount: 128,
);
```

### User

Represents a user account in the system.

**Properties:**
- `id` (String): Unique user identifier
- `email` (String): User's email address
- `name` (String): User's full name
- `phone` (String?): Optional phone number
- `addresses` (List<Address>): List of user's addresses

**Usage:**
```dart
final user = User(
  id: 'user123',
  email: 'john@example.com',
  name: 'John Doe',
  phone: '+1234567890',
  addresses: [address1, address2],
);
```

### Order

Represents a customer order.

**Properties:**
- `id` (String): Unique order identifier
- `userId` (String): ID of the user who placed the order
- `items` (List<CartItem>): List of items in the order
- `shippingAddress` (Address): Shipping address for the order
- `paymentMethod` (String): Payment method used
- `status` (OrderStatus): Current order status
- `subtotal` (double): Order subtotal before tax and shipping
- `tax` (double): Tax amount
- `shipping` (double): Shipping cost
- `total` (double): Total order amount
- `createdAt` (DateTime): Order creation timestamp
- `updatedAt` (DateTime): Last update timestamp

**OrderStatus Enum:**
- `pending`: Order placed, awaiting processing
- `processing`: Order being prepared
- `shipped`: Order has been shipped
- `delivered`: Order delivered to customer
- `cancelled`: Order cancelled

**Usage:**
```dart
final order = Order(
  id: 'order123',
  userId: 'user123',
  items: cartItems,
  shippingAddress: address,
  paymentMethod: 'Credit Card',
  status: OrderStatus.pending,
  subtotal: 99.99,
  tax: 9.99,
  shipping: 5.99,
  total: 115.97,
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);
```

### Category

Represents a product category.

**Properties:**
- `id` (String): Unique category identifier
- `name` (String): Category name
- `description` (String?): Optional category description
- `imageUrl` (String?): Optional category image URL

## BLoC Classes

### ProductBloc

Manages product-related state and business logic.

**Events:**
- `LoadProducts`: Load all products
- `LoadFeaturedProducts`: Load featured products only
- `LoadProductsByCategory(String categoryId)`: Load products by category
- `SearchProducts(String query)`: Search products by name/description
- `LoadProductDetail(String productId)`: Load detailed product information
- `LoadCategories`: Load all product categories

**States:**
- `ProductInitial`: Initial state
- `ProductLoading`: Loading state
- `ProductsLoaded(List<Product>)`: Products loaded successfully
- `FeaturedProductsLoaded(List<Product>)`: Featured products loaded
- `ProductDetailLoaded(Product)`: Product detail loaded
- `CategoriesLoaded(List<Category>)`: Categories loaded
- `ProductError(String message)`: Error state with message

**Usage:**
```dart
// In a widget
BlocBuilder<ProductBloc, ProductState>(
  builder: (context, state) {
    if (state is ProductsLoaded) {
      return ListView.builder(
        itemCount: state.products.length,
        itemBuilder: (context, index) {
          return ProductCard(product: state.products[index]);
        },
      );
    }
    return CircularProgressIndicator();
  },
)

// Dispatching events
context.read<ProductBloc>().add(LoadProducts());
context.read<ProductBloc>().add(SearchProducts('iPhone'));
```

### AuthBloc

Manages authentication state and user sessions.

**Events:**
- `LoginRequested(String email, String password)`: User login attempt
- `RegisterRequested(String email, String password, String name)`: User registration
- `LogoutRequested`: User logout
- `CheckAuthStatus`: Check current authentication status

**States:**
- `AuthInitial`: Initial authentication state
- `AuthLoading`: Authentication operation in progress
- `Authenticated(User)`: User successfully authenticated
- `Unauthenticated`: User not authenticated
- `AuthError(String message)`: Authentication error

**Usage:**
```dart
// Login
context.read<AuthBloc>().add(
  LoginRequested('user@example.com', 'password123')
);

// Check authentication status
BlocListener<AuthBloc, AuthState>(
  listener: (context, state) {
    if (state is Authenticated) {
      // Navigate to home screen
      context.go('/home');
    }
  },
  child: LoginScreen(),
)
```

### CartBloc

Manages shopping cart state and operations.

**Events:**
- `LoadCart`: Load cart items
- `AddItem(CartItem item)`: Add item to cart
- `RemoveItem(String productId)`: Remove item from cart
- `UpdateQuantity(String productId, int quantity)`: Update item quantity
- `ClearCart`: Remove all items from cart

**States:**
- `CartInitial`: Initial cart state
- `CartLoading`: Cart operation in progress
- `CartLoaded(List<CartItem>)`: Cart items loaded
- `CartError(String message)`: Cart operation error

**Usage:**
```dart
// Add item to cart
context.read<CartBloc>().add(AddItem(cartItem));

// Listen for cart updates
BlocBuilder<CartBloc, CartState>(
  builder: (context, state) {
    if (state is CartLoaded) {
      return CartScreen(items: state.items);
    }
    return CircularProgressIndicator();
  },
)
```

## Repository Interfaces

### ProductRepository

Abstract interface for product data operations.

**Methods:**
- `Future<List<Product>> getProducts()`: Retrieve all products
- `Future<List<Product>> getFeaturedProducts()`: Get featured products
- `Future<List<Product>> getProductsByCategory(String categoryId)`: Get products by category
- `Future<Product> getProductById(String id)`: Get product by ID
- `Future<List<Category>> getCategories()`: Get all categories
- `Future<List<Product>> searchProducts(String query)`: Search products

### AuthRepository

Abstract interface for authentication operations.

**Methods:**
- `Future<User> login(String email, String password)`: Authenticate user
- `Future<User> register(String email, String password, String name)`: Register new user
- `Future<void> logout()`: Sign out current user
- `Future<User?> getCurrentUser()`: Get current authenticated user
- `Future<bool> isAuthenticated()`: Check authentication status

### CartRepository

Abstract interface for cart operations.

**Methods:**
- `Future<List<CartItem>> getCartItems()`: Get all cart items
- `Future<void> addItem(CartItem item)`: Add item to cart
- `Future<void> removeItem(String productId)`: Remove item from cart
- `Future<void> updateQuantity(String productId, int quantity)`: Update item quantity
- `Future<void> clearCart()`: Clear all cart items

## Data Models

### ProductModel

Data transfer object for Product entity, includes JSON serialization.

**Methods:**
- `factory ProductModel.fromJson(Map<String, dynamic> json)`: Create from JSON
- `Map<String, dynamic> toJson()`: Convert to JSON
- `Product toEntity()`: Convert to domain entity

### UserModel

Data transfer object for User entity.

**Methods:**
- `factory UserModel.fromJson(Map<String, dynamic> json)`: Create from JSON
- `Map<String, dynamic> toJson()`: Convert to JSON
- `User toEntity()`: Convert to domain entity

## Error Handling

All BLoC operations include error handling that emits error states with descriptive messages:

```dart
try {
  // Operation
  emit(SuccessState(result));
} catch (e) {
  emit(ErrorState(e.toString()));
}
```

## State Management Patterns

### Reactive UI Updates

Widgets subscribe to BLoC state changes using BlocBuilder:

```dart
BlocBuilder<BlocA, StateA>(
  builder: (context, state) {
    // Return widget based on state
  },
)
```

### Side Effects

Use BlocListener for side effects like navigation:

```dart
BlocListener<AuthBloc, AuthState>(
  listener: (context, state) {
    if (state is Authenticated) {
      context.go('/home');
    }
  },
)
```

### Conditional Building

Use buildWhen to optimize rebuilds:

```dart
BlocBuilder<ProductBloc, ProductState>(
  buildWhen: (previous, current) => current is ProductsLoaded,
  builder: (context, state) {
    // Only rebuilds when ProductsLoaded
  },
)
```

This documentation covers the main API surfaces. For implementation details, refer to the source code and unit tests.