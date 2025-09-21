import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import '../screens/splash_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/home_screen.dart';
import '../screens/product_list_screen.dart';
import '../screens/product_detail_screen.dart';
import '../screens/cart_screen.dart';
import '../screens/checkout_screen.dart';
import '../screens/order_confirmation_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/orders_screen.dart';
import '../screens/favorites_screen.dart';
import '../widgets/scaffold_with_bottom_nav.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_state.dart';
import '../domain/entities/order.dart';

class AuthListenable extends ChangeNotifier {
  AuthListenable(this.authBloc) {
    authBloc.stream.listen((state) {
      notifyListeners();
    });
  }

  final AuthBloc authBloc;

  bool get isAuthenticated => authBloc.state is Authenticated;
  bool get isLoading => authBloc.state is AuthLoading;
}

GoRouter createRouter(AuthBloc authBloc) {
  final authListenable = AuthListenable(authBloc);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: authListenable,
    redirect: (context, state) {
      final isAuthenticated = authListenable.isAuthenticated;
      final isLoading = authListenable.isLoading;
      final location = state.uri.path;

      // Allow splash screen to load
      if (location == '/') return null;

      // If still loading auth status, don't redirect
      if (isLoading) return null;

      // Protected routes
      final protectedRoutes = [
        '/home',
        '/categories',
        '/cart',
        '/profile',
        '/favorites',
        '/checkout',
        '/orders',
      ];
      final isProtectedRoute =
          protectedRoutes.any((route) => location.startsWith(route)) ||
          location.startsWith('/product/');

      // Auth routes
      final authRoutes = ['/login', '/register'];
      final isAuthRoute = authRoutes.contains(location);

      if (!isAuthenticated && isProtectedRoute) {
        return '/login';
      }

      if (isAuthenticated && isAuthRoute) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithBottomNav(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/categories',
                builder: (context, state) => const ProductListScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/cart',
                builder: (context, state) => const CartScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/favorites',
                builder: (context, state) => const FavoritesScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/product/:id',
        builder: (context, state) => const ProductDetailScreen(),
      ),
      GoRoute(
        path: '/checkout',
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: '/orders',
        builder: (context, state) => const OrdersScreen(),
      ),
      GoRoute(
        path: '/order-confirmation',
        builder: (context, state) {
          final order = state.extra as Order?;
          if (order == null) {
            return const Scaffold(body: Center(child: Text('Order not found')));
          }
          return OrderConfirmationScreen(order: order);
        },
      ),
    ],
  );
}
