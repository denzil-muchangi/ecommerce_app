# Architecture Documentation

This document provides a comprehensive overview of the e-commerce Flutter application's architecture, design patterns, and data flow.

## Clean Architecture Overview

The application follows Clean Architecture principles, separating concerns into distinct layers:

### 1. Domain Layer
The innermost layer containing business logic and entities.

**Components:**
- **Entities**: Core business objects (Product, User, Order, etc.)
- **Repository Interfaces**: Abstract contracts for data operations
- **Use Cases**: Application-specific business rules (if implemented)

**Responsibilities:**
- Define business entities and their relationships
- Establish contracts for data operations
- Contain pure business logic independent of frameworks

### 2. Data Layer
Handles data persistence and external service communication.

**Components:**
- **Repository Implementations**: Concrete implementations of domain repository interfaces
- **Data Sources**: Remote (API) and local (database/cache) data access
- **Models**: Data transfer objects for API communication
- **Mappers**: Transform between domain entities and data models

**Responsibilities:**
- Implement data access logic
- Handle API calls and local storage
- Transform data between layers
- Manage caching and offline support

### 3. Presentation Layer
UI and state management components.

**Components:**
- **Screens/Pages**: UI components displaying data
- **Widgets**: Reusable UI elements
- **BLoCs**: Business logic components managing state
- **Events**: User actions triggering state changes
- **States**: Immutable representations of UI state

**Responsibilities:**
- Render UI based on state
- Handle user interactions
- Manage UI state and navigation
- Display loading, error, and success states

## Design Patterns

### BLoC (Business Logic Component) Pattern

The app uses BLoC pattern for state management, providing a clear separation between UI and business logic.

**Key Components:**
- **Events**: Represent user actions or system events
- **States**: Immutable snapshots of the current state
- **BLoC**: Processes events and emits states

**Example Flow:**
```
User Action → Event → BLoC → State → UI Update
```

**Benefits:**
- Predictable state changes
- Testable business logic
- Separation of concerns
- Reactive programming model

### Repository Pattern

Abstracts data access logic, allowing the domain layer to remain independent of data sources.

**Structure:**
```
Domain Layer ← Repository Interface ← Repository Implementation → Data Sources
```

**Benefits:**
- Decoupling of business logic from data access
- Easy testing with mock repositories
- Support for multiple data sources
- Consistent data access interface

### Dependency Injection

Uses constructor injection to provide dependencies, promoting loose coupling.

**Implementation:**
- BLoCs receive repository instances via constructor
- Repositories receive data sources via constructor
- Main.dart configures the dependency graph

**Benefits:**
- Testability with mock dependencies
- Flexibility in implementation swapping
- Clear dependency relationships

### Observer Pattern

BLoC streams act as observable subjects that widgets subscribe to for state updates.

**Flow:**
```
BLoC Stream → BlocBuilder/BlocListener → UI Rebuild
```

## Data Flow

### Authentication Flow

```
UI (LoginScreen) → AuthEvent → AuthBloc → AuthRepository → AuthRemoteDataSource
                                                            ↓
UI Update ← AuthState ← AuthBloc ← AuthRepository ← API Response
```

1. User enters credentials in LoginScreen
2. LoginScreen dispatches LoginRequested event
3. AuthBloc processes event, calls repository
4. Repository delegates to remote data source
5. API call made, response received
6. Data flows back through layers
7. AuthBloc emits Authenticated state
8. UI updates based on new state

### Product Loading Flow

```
UI (HomeScreen) → ProductEvent → ProductBloc → ProductRepository → ProductRemoteDataSource
                                                               ↓
UI Update ← ProductState ← ProductBloc ← ProductRepository ← API Response
```

1. Screen initializes, dispatches LoadProducts event
2. ProductBloc handles event, calls repository
3. Repository fetches from remote data source
4. Data transformed from models to entities
5. ProductBloc emits ProductsLoaded state
6. UI rebuilds with new product data

### Cart Management Flow

```
UI (CartScreen) → CartEvent → CartBloc → CartRepository → CartLocalDataSource
                                                          ↓
UI Update ← CartState ← CartBloc ← CartRepository ← Local Storage
```

1. User adds item to cart
2. CartBloc processes AddToCart event
3. Repository saves to local storage
4. CartBloc emits updated CartState
5. UI reflects changes immediately

## State Management Details

### BLoC Event Handling

Each BLoC extends the base Bloc class and defines event handlers:

```dart
class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository repository;

  ProductBloc(this.repository) : super(ProductInitial()) {
    on<LoadProducts>(_onLoadProducts);
    on<SearchProducts>(_onSearchProducts);
    // ... other event handlers
  }
}
```

### State Immutability

All states are immutable, ensuring predictable updates:

```dart
abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object> get props => [];
}

class ProductsLoaded extends ProductState {
  final List<Product> products;

  const ProductsLoaded(this.products);

  @override
  List<Object> get props => [products];
}
```

### Error Handling

Errors are propagated through states:

```dart
class ProductError extends ProductState {
  final String message;

  const ProductError(this.message);

  @override
  List<Object> get props => [message];
}
```

## Data Transformation

### Entity to Model Mapping

Data flows between layers with appropriate transformations:

```
API Response → Model → Entity → UI
```

**Example:**
```dart
// In repository implementation
Future<List<Product>> getProducts() async {
  final productModels = await remoteDataSource.getProducts();
  return productModels.map((model) => model.toEntity()).toList();
}
```

## Navigation and Routing

Uses GoRouter for declarative routing with state-based navigation:

```dart
final router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    // ... other routes
  ],
  redirect: (context, state) => _handleRedirect(context, state),
);
```

## Dependency Graph

The app configures dependencies in main.dart:

```
SharedPreferences → AuthRepository → AuthBloc
Dio → RemoteDataSources → Repositories → BLoCs
LocalDataSources → Repositories → BLoCs
```

## Testing Strategy

### Unit Tests
- Test BLoC event handling
- Test repository implementations with mocks
- Test data source operations

### Widget Tests
- Test UI components with mock BLoCs
- Test user interactions
- Test state-dependent rendering

### Integration Tests
- Test complete user flows
- Test API integration
- Test local storage operations

## Performance Considerations

### State Optimization
- Use `buildWhen` in BlocBuilder to prevent unnecessary rebuilds
- Implement efficient state comparisons with Equatable

### Data Caching
- Local storage for offline cart and favorites
- In-memory caching for frequently accessed data

### UI Optimization
- Lazy loading for product lists
- Image caching with CachedNetworkImage
- Efficient list rendering with GridView

## Security Considerations

### Authentication
- Secure token storage with SharedPreferences
- Automatic token refresh handling
- Secure API communication with HTTPS

### Data Validation
- Input validation in UI forms
- Server-side validation through API
- Sanitization of user inputs

## Scalability

### Modular Structure
- Feature-based organization allows easy addition of new features
- Independent BLoCs enable parallel development
- Repository pattern supports new data sources

### Code Organization
- Clear separation of concerns
- Consistent naming conventions
- Comprehensive documentation

This architecture ensures maintainability, testability, and scalability while providing a smooth user experience.