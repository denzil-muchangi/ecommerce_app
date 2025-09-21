import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'routes/app_router.dart';
import 'constants/app_colors.dart';
import 'services/notification_service.dart';
import 'bloc/product/product_bloc.dart';
import 'bloc/auth/auth_bloc.dart';
import 'bloc/user/user_bloc.dart';
import 'bloc/cart/cart_bloc.dart';
import 'bloc/order/order_bloc.dart';
import 'bloc/favorites/favorites_bloc.dart';
import 'data/repositories/product_repository.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/user_repository.dart';
import 'data/repositories/cart_repository_impl.dart';
import 'data/repositories/order_repository_impl.dart';
import 'data/repositories/favorites_repository_impl.dart';
import 'data/datasources/product_remote_data_source.dart';
import 'data/datasources/auth_remote_data_source.dart';
import 'data/datasources/user_remote_data_source.dart';
import 'data/datasources/cart_local_data_source.dart';
import 'data/datasources/order_remote_data_source_impl.dart';
import 'data/datasources/favorites_local_data_source.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final sharedPreferences = await SharedPreferences.getInstance();

  // Initialize notification service
  final notificationService = NotificationService();
  await notificationService.initialize();
  await notificationService.requestPermissions();

  runApp(MyApp(sharedPreferences: sharedPreferences));
}

class MyApp extends StatelessWidget {
  final SharedPreferences sharedPreferences;

  const MyApp({super.key, required this.sharedPreferences});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              ProductBloc(ProductRepositoryImpl(ProductRemoteDataSourceImpl())),
        ),
        BlocProvider(
          create: (context) => AuthBloc(
            AuthRepositoryImpl(AuthRemoteDataSourceImpl(), sharedPreferences),
          ),
        ),
        BlocProvider(
          create: (context) =>
              UserBloc(UserRepositoryImpl(UserRemoteDataSourceImpl())),
        ),
        BlocProvider(
          create: (context) =>
              CartBloc(CartRepositoryImpl(CartLocalDataSource())),
        ),
        BlocProvider(
          create: (context) =>
              OrderBloc(OrderRepositoryImpl(OrderRemoteDataSourceImpl())),
        ),
        BlocProvider(
          create: (context) => FavoritesBloc(
            FavoritesRepositoryImpl(
              FavoritesLocalDataSource(),
              ProductRepositoryImpl(ProductRemoteDataSourceImpl()),
            ),
          ),
        ),
      ],
      child: Builder(
        builder: (context) {
          final authBloc = context.read<AuthBloc>();
          return MaterialApp.router(
            title: 'E-Commerce App',
            routerConfig: createRouter(authBloc),
            theme: ThemeData(
              primaryColor: AppColors.primary,
              colorScheme: const ColorScheme.light(
                primary: AppColors.primary,
                secondary: AppColors.secondary,
                surface: AppColors.surface,
                background: AppColors.background,
                error: AppColors.error,
                onPrimary: AppColors.onPrimary,
                onSecondary: AppColors.onSecondary,
                onSurface: AppColors.onSurface,
                onBackground: AppColors.onBackground,
                onError: AppColors.onError,
              ),
              scaffoldBackgroundColor: AppColors.background,
              appBarTheme: const AppBarTheme(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                elevation: 0,
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
