import 'package:flutter_test/flutter_test.dart';
import 'package:ecommerce_app/data/datasources/product_remote_data_source.dart';

void main() {
  late ProductRemoteDataSourceImpl dataSource;

  setUp(() {
    dataSource = ProductRemoteDataSourceImpl();
  });

  group('ProductRemoteDataSourceImpl', () {
    test('getProducts returns list of products', () async {
      final result = await dataSource.getProducts();

      expect(result, isNotEmpty);
      expect(result.first.id, isNotEmpty);
      expect(result.first.name, isNotEmpty);
    });

    test('getFeaturedProducts returns only featured products', () async {
      final result = await dataSource.getFeaturedProducts();

      expect(result, isNotEmpty);
      for (final product in result) {
        expect(product.isFeatured, true);
      }
    });

    test(
      'getProductsByCategory returns products for specific category',
      () async {
        const categoryId = 'electronics';
        final result = await dataSource.getProductsByCategory(categoryId);

        expect(result, isNotEmpty);
        for (final product in result) {
          expect(product.categoryId, categoryId);
        }
      },
    );

    test('getProductById returns product with specific id', () async {
      const productId = '1';
      final result = await dataSource.getProductById(productId);

      expect(result.id, productId);
      expect(result.name, isNotEmpty);
    });

    test('getProductById throws exception for non-existent product', () async {
      const productId = 'nonexistent';

      expect(
        () => dataSource.getProductById(productId),
        throwsA(isA<Exception>()),
      );
    });

    test('getCategories returns list of categories', () async {
      final result = await dataSource.getCategories();

      expect(result, isNotEmpty);
      expect(result.first.id, isNotEmpty);
      expect(result.first.name, isNotEmpty);
    });
  });
}
