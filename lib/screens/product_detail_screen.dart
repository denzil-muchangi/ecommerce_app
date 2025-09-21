import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/product/product_bloc.dart';
import '../bloc/product/product_event.dart';
import '../bloc/product/product_state.dart';
import '../bloc/cart/cart_bloc.dart';
import '../bloc/cart/cart_event.dart';
import '../bloc/favorites/favorites_bloc.dart';
import '../bloc/favorites/favorites_event.dart';
import '../bloc/favorites/favorites_state.dart';
import '../domain/entities/cart_item.dart';
import '../domain/entities/review.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int quantity = 1;
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    final productId = GoRouterState.of(context).pathParameters['id'];
    if (productId != null) {
      context.read<ProductBloc>().add(LoadProductDetail(productId));
      context.read<FavoritesBloc>().add(CheckIsFavorite(productId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Product Detail'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.share), onPressed: () {}),
          BlocBuilder<FavoritesBloc, FavoritesState>(
            builder: (context, state) {
              if (state is FavoriteStatusChecked) {
                isFavorite = state.isFavorite;
              } else if (state is FavoriteToggled) {
                isFavorite = state.isFavorite;
              }
              return IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : null,
                ),
                onPressed: () {
                  final productId = GoRouterState.of(
                    context,
                  ).pathParameters['id'];
                  if (productId != null) {
                    context.read<FavoritesBloc>().add(
                      ToggleFavorite(productId),
                    );
                  }
                },
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          if (state is ProductLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ProductDetailLoaded) {
            final product = state.product;
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Image
                  Container(
                    height: 300,
                    width: double.infinity,
                    color: Colors.grey[300],
                    child: product.images.isNotEmpty
                        ? Image.network(product.images.first, fit: BoxFit.cover)
                        : const Center(
                            child: Icon(
                              Icons.image,
                              size: 100,
                              color: Colors.grey,
                            ),
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product Name and Price
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                product.name,
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Text(
                              '\$${product.price}',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Rating
                        Row(
                          children: [
                            ...List.generate(
                              product.rating.floor(),
                              (index) => const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 20,
                              ),
                            ),
                            if (product.rating % 1 != 0)
                              const Icon(
                                Icons.star_half,
                                color: Colors.amber,
                                size: 20,
                              ),
                            ...List.generate(
                              5 - product.rating.ceil(),
                              (index) => const Icon(
                                Icons.star_border,
                                color: Colors.amber,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${product.rating} (${product.reviewCount} reviews)',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Description
                        Text(
                          'Description',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          product.description,
                          style: TextStyle(
                            color: Colors.grey[700],
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Reviews Section
                        Text(
                          'Reviews',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        if (product.reviews.isEmpty)
                          const Text('No reviews yet. Be the first to review!')
                        else
                          Column(
                            children: product.reviews.map((review) {
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            review.userName,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Row(
                                            children: List.generate(
                                              5,
                                              (index) => Icon(
                                                index < review.rating
                                                    ? Icons.star
                                                    : Icons.star_border,
                                                color: Colors.amber,
                                                size: 16,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(review.comment),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${review.date.day}/${review.date.month}/${review.date.year}',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        const SizedBox(height: 16),
                        // Add Review Button
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () =>
                                _showAddReviewDialog(context, product.id),
                            child: const Text('Write a Review'),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Stock info
                        Text(
                          'In Stock: ${product.stock}',
                          style: TextStyle(
                            color: product.stock > 0
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Quantity Selector
                        Row(
                          children: [
                            Text(
                              'Quantity:',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(width: 16),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove),
                                    onPressed: quantity > 1
                                        ? () => setState(() => quantity--)
                                        : null,
                                  ),
                                  Text('$quantity'),
                                  IconButton(
                                    icon: const Icon(Icons.add),
                                    onPressed: quantity < product.stock
                                        ? () => setState(() => quantity++)
                                        : null,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Add to Cart Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: product.stock > 0
                                ? () {
                                    final cartItem = CartItem(
                                      productId: product.id,
                                      name: product.name,
                                      image: product.images.isNotEmpty
                                          ? product.images.first
                                          : '',
                                      quantity: quantity,
                                      price: product.price,
                                    );
                                    context.read<CartBloc>().add(
                                      AddItem(cartItem),
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          '${product.name} added to cart',
                                        ),
                                      ),
                                    );
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Add to Cart'),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Buy Now Button
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: product.stock > 0
                                ? () {
                                    // TODO: Implement buy now
                                    context.go('/checkout');
                                  }
                                : null,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Buy Now'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          } else if (state is ProductError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const Center(child: Text('Product not found'));
        },
      ),
    );
  }

  void _showAddReviewDialog(BuildContext context, String productId) {
    int rating = 5;
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Write a Review'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Rating:'),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                5,
                (index) => IconButton(
                  icon: Icon(
                    index < rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                  ),
                  onPressed: () {
                    setState(() => rating = index + 1);
                  },
                ),
              ),
            ),
            TextField(
              controller: commentController,
              decoration: const InputDecoration(
                hintText: 'Write your review...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Submit review to backend
              // For now, just show a success message
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Review submitted successfully!')),
              );
              Navigator.of(context).pop();
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
