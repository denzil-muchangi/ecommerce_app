# E-Commerce Flutter App

A modern, feature-rich e-commerce mobile application built with Flutter, implementing clean architecture and BLoC pattern for state management. This app provides a seamless shopping experience with user authentication, product browsing, cart management, order processing, and more.

## Features

### Core Features
- **User Authentication**: Secure login and registration with persistent sessions
- **Product Browsing**: Browse products by categories, featured items, and search functionality
- **Shopping Cart**: Add/remove items, quantity management, and cart persistence
- **Order Management**: Place orders, view order history, and track order status
- **Favorites**: Save favorite products for quick access
- **User Profile**: Manage personal information and addresses
- **Push Notifications**: Real-time notifications for orders and promotions

### Technical Features
- **Clean Architecture**: Separation of concerns with domain, data, and presentation layers
- **BLoC Pattern**: Reactive state management for predictable UI updates
- **Offline Support**: Local data persistence for cart and favorites
- **Responsive Design**: Optimized for various screen sizes
- **Material Design**: Modern UI following Material Design principles

## Architecture Overview

This application follows Clean Architecture principles:

- **Domain Layer**: Contains business logic entities, use cases, and repository interfaces
- **Data Layer**: Implements data sources (remote/local) and repository implementations
- **Presentation Layer**: UI components using BLoC for state management

### Design Patterns Used
- **Repository Pattern**: Abstracts data access logic
- **BLoC Pattern**: Manages state and business logic
- **Dependency Injection**: Loose coupling between components
- **Observer Pattern**: Reactive UI updates

## Folder Structure

```
lib/
├── bloc/                    # BLoC classes for state management
│   ├── auth/               # Authentication BLoC
│   ├── cart/               # Shopping cart BLoC
│   ├── favorites/          # Favorites BLoC
│   ├── order/              # Order management BLoC
│   ├── product/            # Product-related BLoC
│   └── user/               # User profile BLoC
├── constants/              # App-wide constants (colors, strings)
├── data/                   # Data layer
│   ├── datasources/        # Data source implementations
│   ├── models/            # Data transfer objects
│   └── repositories/      # Repository implementations
├── domain/                 # Domain layer
│   ├── entities/          # Business entities
│   └── repositories/      # Repository interfaces
├── routes/                 # App routing configuration
├── screens/                # UI screens
├── services/               # External services (notifications, etc.)
└── widgets/                # Reusable UI components
```

## Setup Instructions

### Prerequisites
- Flutter SDK (^3.9.2)
- Dart SDK (^3.9.2)
- Android Studio or VS Code with Flutter extensions
- Android/iOS device or emulator

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/your-username/ecommerce_app.git
   cd ecommerce_app
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Set up environment variables**:
   Create a `.env` file in the root directory with your API endpoints:
   ```
   API_BASE_URL=https://your-api-endpoint.com
   ```

4. **Run code generation** (if using build_runner):
   ```bash
   flutter pub run build_runner build
   ```

## Running the App

### Development Mode
```bash
flutter run
```

### Release Mode
```bash
flutter run --release
```

### Platform-Specific Commands

**Android**:
```bash
flutter run -d android
```

**iOS** (macOS only):
```bash
flutter run -d ios
```

**Web**:
```bash
flutter run -d chrome
```

## Testing

### Unit Tests
Run unit tests for business logic:
```bash
flutter test
```

### Widget Tests
Run UI component tests:
```bash
flutter test test/widget/
```

### Integration Tests
Run end-to-end tests:
```bash
flutter test integration_test/
```

### Test Coverage
Generate test coverage report:
```bash
flutter test --coverage
# View coverage: open coverage/html/index.html
```

## Deployment

### Android APK
```bash
flutter build apk --release
```

### Android App Bundle
```bash
flutter build appbundle --release
```

### iOS (macOS only)
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

### Firebase App Distribution (Optional)
```bash
flutter build apk --release
firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk \
  --app YOUR_APP_ID \
  --groups "testers"
```

## Usage Examples

### User Authentication
1. Launch the app
2. Tap "Login" or "Register" on the splash screen
3. Enter credentials or create a new account
4. Access authenticated features like cart and orders

### Product Browsing
1. Navigate to the home screen
2. Browse featured products in the horizontal list
3. Tap on categories to filter products
4. Use the search icon to find specific products
5. Tap on a product card to view details

### Shopping Cart
1. From product detail screen, tap "Add to Cart"
2. View cart by tapping the cart icon in the bottom navigation
3. Adjust quantities or remove items
4. Proceed to checkout when ready

### Order Management
1. Complete checkout process from cart
2. View order history in the profile/orders section
3. Track order status and details

## Screenshots

### Splash Screen
Displays the app logo and loading animation while initializing services and checking authentication status.

### Home Screen
Features a welcome banner, horizontal category list, and featured products carousel. Includes search and notification icons in the app bar.

### Product List Screen
Grid view of products with category filtering dropdown. Each product card shows image, name, price, and rating.

### Product Detail Screen
Detailed view with product images, description, specifications, reviews, and add-to-cart functionality.

### Login Screen
Clean authentication form with email/password fields, validation, and navigation to registration.

### Cart Screen
List of cart items with quantity controls, total price calculation, and checkout button.

### Profile Screen
User information display with options to edit profile, view orders, manage addresses, and logout.

## API Documentation

### Key Classes

#### Entities
- `Product`: Represents a product with id, name, description, price, images, category, stock, rating
- `User`: User account information including profile details and addresses
- `Order`: Order details with items, status, and shipping information
- `CartItem`: Individual cart item with product and quantity

#### BLoCs
- `AuthBloc`: Manages authentication state (login, logout, registration)
- `ProductBloc`: Handles product-related operations (loading, searching, filtering)
- `CartBloc`: Manages shopping cart state and operations
- `OrderBloc`: Processes orders and manages order history

#### Repositories
- `AuthRepository`: Authentication data operations
- `ProductRepository`: Product data access and search
- `CartRepository`: Cart persistence and management
- `OrderRepository`: Order creation and history retrieval

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For support, email support@ecommerceapp.com or join our Discord community.

---

Built with ❤️ using Flutter
