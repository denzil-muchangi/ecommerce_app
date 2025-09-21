import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/product/product_bloc.dart';
import '../bloc/product/product_event.dart';
import '../bloc/product/product_state.dart';
import '../widgets/product_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(LoadFeaturedProducts());
    context.read<ProductBloc>().add(LoadCategories());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showSearchDialog(BuildContext context) {
    // Display a dialog for product search functionality
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Products'),
        content: TextField(
          controller: _searchController,
          decoration: const InputDecoration(hintText: 'Enter product name...'),
          onSubmitted: (query) {
            if (query.isNotEmpty) {
              // Dispatch search event to ProductBloc
              context.read<ProductBloc>().add(SearchProducts(query));
              Navigator.of(context).pop();
              // Navigate to product list screen with search results
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (_searchController.text.isNotEmpty) {
                // Dispatch search event with current text input
                context.read<ProductBloc>().add(
                  SearchProducts(_searchController.text),
                );
                Navigator.of(context).pop();
                // Navigate to product list screen
              }
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('E-Commerce'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(context),
          ),
          IconButton(icon: const Icon(Icons.notifications), onPressed: () {}),
        ],
      ),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Banner
                Container(
                  height: 200,
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [Colors.blue, Colors.purple],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'Welcome to Our Store!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                // Categories
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Categories',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                BlocBuilder<ProductBloc, ProductState>(
                  buildWhen: (previous, current) =>
                      current is CategoriesLoaded || current is ProductLoading,
                  builder: (context, categoryState) {
                    if (categoryState is CategoriesLoaded) {
                      return SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: categoryState.categories.length,
                          itemBuilder: (context, index) {
                            final category = categoryState.categories[index];
                            return GestureDetector(
                              onTap: () {
                                // Navigate to product list with category
                                context.go('/categories', extra: category.id);
                              },
                              child: Container(
                                width: 80,
                                margin: const EdgeInsets.only(right: 16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.2),
                                      spreadRadius: 1,
                                      blurRadius: 5,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.category,
                                      color: Theme.of(context).primaryColor,
                                      size: 32,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      category.name,
                                      style: const TextStyle(fontSize: 12),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                // Featured Products
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Featured Products',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                BlocBuilder<ProductBloc, ProductState>(
                  buildWhen: (previous, current) =>
                      current is FeaturedProductsLoaded ||
                      current is ProductLoading ||
                      current is ProductError,
                  builder: (context, featuredState) {
                    if (featuredState is ProductLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (featuredState is FeaturedProductsLoaded) {
                      return SizedBox(
                        height: 250,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: featuredState.products.length,
                          itemBuilder: (context, index) {
                            final product = featuredState.products[index];
                            return ProductCard(
                              product: product,
                              onTap: () {
                                // Navigate to product detail
                                context.go('/product/${product.id}');
                              },
                            );
                          },
                        ),
                      );
                    } else if (featuredState is ProductError) {
                      return Center(
                        child: Text('Error: ${featuredState.message}'),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
