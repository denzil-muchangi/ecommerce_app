import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/product/product_bloc.dart';
import '../bloc/product/product_event.dart';
import '../bloc/product/product_state.dart';
import '../widgets/product_card.dart';
import '../domain/entities/category.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key, this.initialCategoryId});

  final String? initialCategoryId;

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  String? selectedCategoryId;

  @override
  void initState() {
    super.initState();
    selectedCategoryId = widget.initialCategoryId;
    context.read<ProductBloc>().add(LoadCategories());
    if (widget.initialCategoryId != null) {
      context.read<ProductBloc>().add(
        LoadProductsByCategory(widget.initialCategoryId!),
      );
    } else {
      context.read<ProductBloc>().add(LoadProducts());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Products'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          BlocBuilder<ProductBloc, ProductState>(
            buildWhen: (previous, current) => current is CategoriesLoaded,
            builder: (context, state) {
              if (state is CategoriesLoaded) {
                return PopupMenuButton<String>(
                  initialValue: selectedCategoryId,
                  onSelected: (categoryId) {
                    setState(() {
                      selectedCategoryId = categoryId;
                    });
                    if (categoryId == 'all') {
                      context.read<ProductBloc>().add(LoadProducts());
                    } else {
                      context.read<ProductBloc>().add(
                        LoadProductsByCategory(categoryId),
                      );
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'all',
                      child: Text('All Categories'),
                    ),
                    ...state.categories.map(
                      (category) => PopupMenuItem(
                        value: category.id,
                        child: Text(category.name),
                      ),
                    ),
                  ],
                  icon: const Icon(Icons.filter_list),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          if (state is ProductLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ProductsLoaded) {
            if (state.products.isEmpty) {
              return const Center(child: Text('No products found'));
            }
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.75,
              ),
              itemCount: state.products.length,
              itemBuilder: (context, index) {
                final product = state.products[index];
                return ProductCard(
                  product: product,
                  onTap: () {
                    context.go('/product/${product.id}');
                  },
                  onAddToCart: () {
                    // TODO: Implement add to cart
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${product.name} added to cart')),
                    );
                  },
                );
              },
            );
          } else if (state is ProductError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const Center(child: Text('No products available'));
        },
      ),
    );
  }
}
