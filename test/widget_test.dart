// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ecommerce_app/main.dart';

void main() {
  testWidgets('App builds and shows splash screen', (
    WidgetTester tester,
  ) async {
    // Mock SharedPreferences
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(sharedPreferences: prefs));

    // Verify that the splash screen is shown
    expect(find.text('E-Commerce App'), findsOneWidget);
    expect(find.byIcon(Icons.shopping_bag), findsOneWidget);
  });
}
