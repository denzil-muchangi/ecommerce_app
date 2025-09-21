import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:ecommerce_app/bloc/product/product_bloc.dart';
import 'package:ecommerce_app/bloc/product/product_event.dart';
import 'package:ecommerce_app/bloc/product/product_state.dart';
import 'package:ecommerce_app/data/repositories/product_repository.dart';
import 'package:ecommerce_app/domain/entities/product.dart';
import 'package:ecommerce_app/domain/entities/category.dart';

@GenerateMocks([ProductRepository])
import 'product_bloc_test.mocks.dart';

void main() {
  late ProductBloc productBloc;
  late MockProductRepository mockProductRepository;

  setUp(() {
    mockProductRepository = MockProductRepository();
    productBloc = ProductBloc(mockProductRepository);
  });

  tearDown(() {
    productBloc.close();
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

  group('ProductBloc', () {
    test('initial state is ProductInitial', () {
      expect(productBloc.state, ProductInitial());
    });

    blocTest<ProductBloc, ProductState>(
      'emits [ProductLoading, ProductsLoaded] when LoadProducts is added and succeeds',
      build: () => productBloc,
      act: (bloc) => bloc.add(LoadProducts()),
      setUp: () => when(
        mockProductRepository.getProducts(),
      ).thenAnswer((_) async => [testProduct]),
      expect: () => [
        ProductLoading(),
        ProductsLoaded([testProduct]),
      ],
      verify: (_) => verify(mockProductRepository.getProducts()).called(1),
    );

    blocTest<ProductBloc, ProductState>(
      'emits [ProductLoading, ProductError] when LoadProducts fails',
      build: () => productBloc,
      act: (bloc) => bloc.add(LoadProducts()),
      setUp: () => when(
        mockProductRepository.getProducts(),
      ).thenThrow(Exception('Network error')),
      expect: () => [
        ProductLoading(),
        ProductError('Exception: Network error'),
      ],
    );

    blocTest<ProductBloc, ProductState>(
      'emits [ProductLoading, FeaturedProductsLoaded] when LoadFeaturedProducts is added and succeeds',
      build: () => productBloc,
      act: (bloc) => bloc.add(LoadFeaturedProducts()),
      setUp: () => when(
        mockProductRepository.getFeaturedProducts(),
      ).thenAnswer((_) async => [testProduct]),
      expect: () => [
        ProductLoading(),
        FeaturedProductsLoaded([testProduct]),
      ],
    );

    blocTest<ProductBloc, ProductState>(
      'emits [ProductLoading, ProductError] when LoadFeaturedProducts fails',
      build: () => productBloc,
      act: (bloc) => bloc.add(LoadFeaturedProducts()),
      setUp: () => when(
        mockProductRepository.getFeaturedProducts(),
      ).thenThrow(Exception('Server error')),
      expect: () => [ProductLoading(), ProductError('Exception: Server error')],
    );

    blocTest<ProductBloc, ProductState>(
      'emits [ProductLoading, ProductsLoaded] when LoadProductsByCategory is added and succeeds',
      build: () => productBloc,
      act: (bloc) => bloc.add(LoadProductsByCategory('cat1')),
      setUp: () => when(
        mockProductRepository.getProductsByCategory('cat1'),
      ).thenAnswer((_) async => [testProduct]),
      expect: () => [
        ProductLoading(),
        ProductsLoaded([testProduct]),
      ],
    );

    blocTest<ProductBloc, ProductState>(
      'emits [ProductLoading, ProductError] when LoadProductsByCategory fails',
      build: () => productBloc,
      act: (bloc) => bloc.add(LoadProductsByCategory('cat1')),
      setUp: () => when(
        mockProductRepository.getProductsByCategory('cat1'),
      ).thenThrow(Exception('Category not found')),
      expect: () => [
        ProductLoading(),
        ProductError('Exception: Category not found'),
      ],
    );

    blocTest<ProductBloc, ProductState>(
      'emits [ProductLoading, ProductsLoaded] when SearchProducts is added and succeeds',
      build: () => productBloc,
      act: (bloc) => bloc.add(SearchProducts('test')),
      setUp: () => when(
        mockProductRepository.searchProducts('test'),
      ).thenAnswer((_) async => [testProduct]),
      expect: () => [
        ProductLoading(),
        ProductsLoaded([testProduct]),
      ],
    );

    blocTest<ProductBloc, ProductState>(
      'emits [ProductLoading, ProductError] when SearchProducts fails',
      build: () => productBloc,
      act: (bloc) => bloc.add(SearchProducts('test')),
      setUp: () => when(
        mockProductRepository.searchProducts('test'),
      ).thenThrow(Exception('Search failed')),
      expect: () => [
        ProductLoading(),
        ProductError('Exception: Search failed'),
      ],
    );

    blocTest<ProductBloc, ProductState>(
      'emits [ProductLoading, ProductDetailLoaded] when LoadProductDetail is added and succeeds',
      build: () => productBloc,
      act: (bloc) => bloc.add(LoadProductDetail('1')),
      setUp: () => when(
        mockProductRepository.getProductById('1'),
      ).thenAnswer((_) async => testProduct),
      expect: () => [ProductLoading(), ProductDetailLoaded(testProduct)],
    );

    blocTest<ProductBloc, ProductState>(
      'emits [ProductLoading, ProductError] when LoadProductDetail fails',
      build: () => productBloc,
      act: (bloc) => bloc.add(LoadProductDetail('1')),
      setUp: () => when(
        mockProductRepository.getProductById('1'),
      ).thenThrow(Exception('Product not found')),
      expect: () => [
        ProductLoading(),
        ProductError('Exception: Product not found'),
      ],
    );

    blocTest<ProductBloc, ProductState>(
      'emits [ProductLoading, CategoriesLoaded] when LoadCategories is added and succeeds',
      build: () => productBloc,
      act: (bloc) => bloc.add(LoadCategories()),
      setUp: () => when(
        mockProductRepository.getCategories(),
      ).thenAnswer((_) async => [testCategory]),
      expect: () => [
        ProductLoading(),
        CategoriesLoaded([testCategory]),
      ],
    );

    blocTest<ProductBloc, ProductState>(
      'emits [ProductLoading, ProductError] when LoadCategories fails',
      build: () => productBloc,
      act: (bloc) => bloc.add(LoadCategories()),
      setUp: () => when(
        mockProductRepository.getCategories(),
      ).thenThrow(Exception('Failed to load categories')),
      expect: () => [
        ProductLoading(),
        ProductError('Exception: Failed to load categories'),
      ],
    );
  });
}
