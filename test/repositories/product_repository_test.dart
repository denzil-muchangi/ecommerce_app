import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:ecommerce_app/data/repositories/product_repository.dart';
import 'package:ecommerce_app/data/datasources/product_remote_data_source.dart';
import 'package:ecommerce_app/data/models/product_model.dart';
import 'package:ecommerce_app/data/models/category_model.dart';
import 'package:ecommerce_app/domain/entities/product.dart';
import 'package:ecommerce_app/domain/entities/category.dart';

@GenerateMocks([ProductRemoteDataSource])
import 'product_repository_test.mocks.dart';

void main() {
  late ProductRepositoryImpl productRepository;
  late MockProductRemoteDataSource mockRemoteDataSource;

  setUp(() {
    mockRemoteDataSource = MockProductRemoteDataSource();
    productRepository = ProductRepositoryImpl(mockRemoteDataSource);
  });

  const testProductModel = ProductModel(
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

  const testCategoryModel = CategoryModel(
    id: 'cat1',
    name: 'Test Category',
    description: 'Test Category Description',
    imageUrl: 'category.jpg',
  );

  group('ProductRepositoryImpl', () {
    test('getProducts returns list of products', () async {
      when(
        mockRemoteDataSource.getProducts(),
      ).thenAnswer((_) async => [testProductModel]);

      final result = await productRepository.getProducts();

      expect(result, [testProductModel]);
      verify(mockRemoteDataSource.getProducts()).called(1);
    });

    test('getFeaturedProducts returns list of featured products', () async {
      when(
        mockRemoteDataSource.getFeaturedProducts(),
      ).thenAnswer((_) async => [testProductModel]);

      final result = await productRepository.getFeaturedProducts();

      expect(result, [testProductModel]);
      verify(mockRemoteDataSource.getFeaturedProducts()).called(1);
    });

    test(
      'getProductsByCategory returns products for specific category',
      () async {
        when(
          mockRemoteDataSource.getProductsByCategory('cat1'),
        ).thenAnswer((_) async => [testProductModel]);

        final result = await productRepository.getProductsByCategory('cat1');

        expect(result, [testProductModel]);
        verify(mockRemoteDataSource.getProductsByCategory('cat1')).called(1);
      },
    );

    test('getProductById returns product with specific id', () async {
      when(
        mockRemoteDataSource.getProductById('1'),
      ).thenAnswer((_) async => testProductModel);

      final result = await productRepository.getProductById('1');

      expect(result, testProductModel);
      verify(mockRemoteDataSource.getProductById('1')).called(1);
    });

    test('getCategories returns list of categories', () async {
      when(
        mockRemoteDataSource.getCategories(),
      ).thenAnswer((_) async => [testCategoryModel]);

      final result = await productRepository.getCategories();

      expect(result, [testCategoryModel]);
      verify(mockRemoteDataSource.getCategories()).called(1);
    });

    test('searchProducts returns filtered products based on query', () async {
      const query = 'test';
      when(
        mockRemoteDataSource.getProducts(),
      ).thenAnswer((_) async => [testProductModel]);

      final result = await productRepository.searchProducts(query);

      expect(result, [testProductModel]);
      verify(mockRemoteDataSource.getProducts()).called(1);
    });

    test('searchProducts returns empty list when no matches', () async {
      const query = 'nonexistent';
      when(
        mockRemoteDataSource.getProducts(),
      ).thenAnswer((_) async => [testProductModel]);

      final result = await productRepository.searchProducts(query);

      expect(result, isEmpty);
      verify(mockRemoteDataSource.getProducts()).called(1);
    });

    test('searchProducts is case insensitive', () async {
      const query = 'TEST';
      when(
        mockRemoteDataSource.getProducts(),
      ).thenAnswer((_) async => [testProductModel]);

      final result = await productRepository.searchProducts(query);

      expect(result, [testProductModel]);
      verify(mockRemoteDataSource.getProducts()).called(1);
    });
  });
}
