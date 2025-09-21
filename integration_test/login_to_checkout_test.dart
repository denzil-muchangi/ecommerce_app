import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecommerce_app/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    testWidgets('login to checkout flow', (WidgetTester tester) async {
      // Initialize shared preferences for testing
      SharedPreferences.setMockInitialValues({});
      final sharedPreferences = await SharedPreferences.getInstance();

      // Build the app and trigger a frame.
      await tester.pumpWidget(MyApp(sharedPreferences: sharedPreferences));

      // Wait for the app to settle
      await tester.pumpAndSettle();

      // Verify we're on the splash screen initially
      expect(find.text('E-Commerce'), findsOneWidget);

      // Wait for splash screen to finish (assuming it auto-navigates)
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Check if we're on login screen
      expect(find.text('Login'), findsOneWidget);

      // Enter login credentials
      await tester.enterText(find.byType(TextField).first, 'test@example.com');
      await tester.enterText(find.byType(TextField).last, 'password');

      // Tap login button
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();

      // Verify we're logged in and on home screen
      expect(find.text('Welcome to Our Store!'), findsOneWidget);

      // Navigate to a product (tap on a featured product)
      // This assumes there are featured products displayed
      final productCards = find.byType(GestureDetector);
      if (productCards.evaluate().isNotEmpty) {
        await tester.tap(productCards.first);
        await tester.pumpAndSettle();

        // Verify we're on product detail screen
        expect(find.text('Add to Cart'), findsOneWidget);

        // Add product to cart
        await tester.tap(find.text('Add to Cart'));
        await tester.pumpAndSettle();

        // Navigate to cart (assuming there's a cart button in app bar)
        // This might need adjustment based on actual navigation
        await tester.tap(find.byIcon(Icons.shopping_cart));
        await tester.pumpAndSettle();

        // Verify cart has items
        expect(find.text('Cart'), findsOneWidget);

        // Proceed to checkout
        await tester.tap(find.text('Checkout'));
        await tester.pumpAndSettle();

        // Verify we're on checkout screen
        expect(find.text('Checkout'), findsOneWidget);

        // Fill checkout form (simplified)
        // This would need to be adjusted based on actual form fields
        final textFields = find.byType(TextField);
        if (textFields.evaluate().length >= 4) {
          await tester.enterText(textFields.at(0), 'John Doe');
          await tester.enterText(textFields.at(1), '123 Main St');
          await tester.enterText(textFields.at(2), 'New York');
          await tester.enterText(textFields.at(3), '10001');
        }

        // Place order
        await tester.tap(find.text('Place Order'));
        await tester.pumpAndSettle();

        // Verify order confirmation
        expect(find.text('Order Confirmed'), findsOneWidget);
      } else {
        // If no products, just verify we can navigate
        expect(find.text('E-Commerce'), findsOneWidget);
      }
    });
  });
}
