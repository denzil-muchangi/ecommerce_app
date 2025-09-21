import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:ecommerce_app/screens/home_screen.dart';
import 'package:ecommerce_app/bloc/product/product_bloc.dart';
import 'package:ecommerce_app/bloc/product/product_state.dart';
import 'package:ecommerce_app/bloc/product/product_event.dart';
import 'package:ecommerce_app/data/repositories/product_repository.dart';
import 'package:ecommerce_app/bloc/favorites/favorites_bloc.dart';
import 'package:ecommerce_app/data/repositories/favorites_repository_impl.dart';
import 'package:ecommerce_app/domain/entities/product.dart';
import 'package:ecommerce_app/domain/entities/category.dart';

@GenerateMocks([ProductRepository, FavoritesRepositoryImpl])
import 'home_screen_test.mocks.dart';

void main() {
  late MockProductRepository mockProductRepository;
  late MockFavoritesRepositoryImpl mockFavoritesRepository;

  setUp(() {
    mockProductRepository = MockProductRepository();
    mockFavoritesRepository = MockFavoritesRepositoryImpl();
  });

  const testProduct = Product(
    id: '1',
    name: 'Test Product',
    description: 'Test Description',
    price: 99.99,
    images: ['image1.jpg'],
    categoryId: 'cat1',
    isFeatured: true,
    stock: 10,
    rating: 4.5,
    reviewCount: 5,
  );

  const testCategory = Category(
    id: 'cat1',
    name: 'Test Category',
    description: 'Test Category Description',
    imageUrl: 'category.jpg',
  );

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<ProductBloc>(
            create: (_) => ProductBloc(mockProductRepository),
          ),
          BlocProvider<FavoritesBloc>(
            create: (_) => FavoritesBloc(mockFavoritesRepository),
          ),
        ],
        child: const HomeScreen(),
      ),
    );
  }

  testWidgets('HomeScreen displays app bar with title and actions', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('E-Commerce'), findsOneWidget);
    expect(find.byIcon(Icons.search), findsOneWidget);
    expect(find.byIcon(Icons.notifications), findsOneWidget);
  });

  testWidgets('HomeScreen displays welcome banner', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('Welcome to Our Store!'), findsOneWidget);
  });

  testWidgets('HomeScreen displays categories section', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('Categories'), findsOneWidget);
  });

  testWidgets('HomeScreen displays featured products section', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('Featured Products'), findsOneWidget);
  });

  testWidgets('HomeScreen shows loading indicator when loading', (
    WidgetTester tester,
  ) async {
    // Set up mock to return a delayed future to keep it in loading state
    when(
      mockProductRepository.getFeaturedProducts(),
    ).thenAnswer((_) => Future.delayed(const Duration(seconds: 1), () => []));
    when(
      mockProductRepository.getCategories(),
    ).thenAnswer((_) => Future.delayed(const Duration(seconds: 1), () => []));

    await tester.pumpWidget(createWidgetUnderTest());

    // Should show loading
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('HomeScreen displays categories when loaded', (
    WidgetTester tester,
  ) async {
    final bloc = ProductBloc(mockProductRepository);
    when(
      mockProductRepository.getCategories(),
    ).thenAnswer((_) async => [testCategory]);

    await tester.pumpWidget(
      MaterialApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider<ProductBloc>.value(value: bloc),
            BlocProvider<FavoritesBloc>(
              create: (_) => FavoritesBloc(mockFavoritesRepository),
            ),
          ],
          child: const HomeScreen(),
        ),
      ),
    );

    // Trigger categories load
    bloc.add(LoadCategories());
    await tester.pump();

    expect(find.text('Test Category'), findsOneWidget);
  });

  testWidgets('HomeScreen displays featured products when loaded', (
    WidgetTester tester,
  ) async {
    final bloc = ProductBloc(mockProductRepository);
    when(
      mockProductRepository.getFeaturedProducts(),
    ).thenAnswer((_) async => [testProduct]);
    when(
      mockFavoritesRepository.isFavorite('1'),
    ).thenAnswer((_) async => false);

    await tester.pumpWidget(
      MaterialApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider<ProductBloc>.value(value: bloc),
            BlocProvider<FavoritesBloc>(
              create: (_) => FavoritesBloc(mockFavoritesRepository),
            ),
          ],
          child: const HomeScreen(),
        ),
      ),
    );

    // Trigger featured products load
    bloc.add(LoadFeaturedProducts());
    await tester.pumpAndSettle();

    expect(find.text('Test Product'), findsOneWidget);
  });

  testWidgets('HomeScreen shows search dialog when search icon tapped', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest());

    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();

    expect(find.text('Search Products'), findsOneWidget);
    expect(find.text('Enter product name...'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Search'), findsOneWidget);
  });

  testWidgets('HomeScreen search dialog can be cancelled', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest());

    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Search Products'), findsNothing);
  });
}
