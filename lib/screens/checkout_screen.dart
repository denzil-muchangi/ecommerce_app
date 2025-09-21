import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/cart/cart_bloc.dart';
import '../bloc/cart/cart_event.dart';
import '../bloc/cart/cart_state.dart';
import '../bloc/user/user_bloc.dart';
import '../bloc/user/user_event.dart';
import '../bloc/user/user_state.dart';
import '../bloc/order/order_bloc.dart';
import '../bloc/order/order_event.dart';
import '../bloc/order/order_state.dart';
import '../domain/entities/address.dart';
import '../domain/entities/cart_item.dart';
import '../constants/app_colors.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  Address? _selectedAddress;
  String _paymentMethod = 'Credit Card';
  bool _isPlacingOrder = false;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: context.read<CartBloc>()),
        BlocProvider.value(value: context.read<UserBloc>()),
        BlocProvider(create: (context) => OrderBloc(context.read())),
      ],
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text('Checkout'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: BlocConsumer<OrderBloc, OrderState>(
          listener: (context, orderState) {
            if (orderState is OrderPlaced) {
              // Clear cart and navigate to confirmation
              context.read<CartBloc>().add(ClearCart());
              Navigator.of(context).pushReplacementNamed(
                '/order-confirmation',
                arguments: orderState.order,
              );
            } else if (orderState is OrderError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(orderState.message)));
              setState(() => _isPlacingOrder = false);
            }
          },
          builder: (context, orderState) {
            return BlocBuilder<CartBloc, CartState>(
              builder: (context, cartState) {
                return BlocBuilder<UserBloc, UserState>(
                  builder: (context, userState) {
                    if (cartState is CartLoaded &&
                        userState is UserAddressesLoaded) {
                      final cartItems = cartState.items;
                      final addresses = userState.addresses;
                      final calculations = _calculateTotals(cartItems);

                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildCartSummary(cartItems, calculations),
                            const SizedBox(height: 24),
                            _buildShippingAddress(addresses),
                            const SizedBox(height: 24),
                            _buildPaymentMethod(),
                            const SizedBox(height: 24),
                            _buildPlaceOrderButton(
                              context,
                              cartItems,
                              calculations,
                            ),
                          ],
                        ),
                      );
                    }
                    return const Center(child: CircularProgressIndicator());
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  Map<String, double> _calculateTotals(List<CartItem> items) {
    final subtotal = items.fold<double>(
      0,
      (sum, item) => sum + (item.price * item.quantity),
    );
    const taxRate = 0.08; // 8% tax
    const shippingRate = 10.0; // Fixed shipping

    final tax = subtotal * taxRate;
    final shipping = subtotal > 50 ? 0 : shippingRate; // Free shipping over $50
    final total = subtotal + tax + shipping;

    return {
      'subtotal': subtotal,
      'tax': tax,
      'shipping': shipping.toDouble(),
      'total': total,
    };
  }

  Widget _buildCartSummary(
    List<CartItem> items,
    Map<String, double> calculations,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Summary',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(child: Text('${item.name} x${item.quantity}')),
                  Text('\$${(item.price * item.quantity).toStringAsFixed(2)}'),
                ],
              ),
            ),
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Subtotal:'),
              Text('\$${calculations['subtotal']!.toStringAsFixed(2)}'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Tax:'),
              Text('\$${calculations['tax']!.toStringAsFixed(2)}'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Shipping:'),
              Text('\$${calculations['shipping']!.toStringAsFixed(2)}'),
            ],
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                '\$${calculations['total']!.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShippingAddress(List<Address> addresses) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Shipping Address',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        if (addresses.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
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
            child: const Text(
              'No addresses found. Please add an address in your profile.',
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(16),
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
              children: addresses.map((address) {
                return RadioListTile<Address>(
                  title: Text(
                    '${address.name}\n${address.street}, ${address.city}, ${address.state} ${address.zipCode}',
                  ),
                  subtitle: Text(address.phone),
                  value: address,
                  groupValue: _selectedAddress,
                  onChanged: (value) {
                    setState(() => _selectedAddress = value);
                  },
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildPaymentMethod() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Method',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
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
            children: [
              RadioListTile<String>(
                title: const Text('Credit Card'),
                value: 'Credit Card',
                groupValue: _paymentMethod,
                onChanged: (value) {
                  setState(() => _paymentMethod = value!);
                },
              ),
              RadioListTile<String>(
                title: const Text('PayPal'),
                value: 'PayPal',
                groupValue: _paymentMethod,
                onChanged: (value) {
                  setState(() => _paymentMethod = value!);
                },
              ),
              RadioListTile<String>(
                title: const Text('Cash on Delivery'),
                value: 'Cash on Delivery',
                groupValue: _paymentMethod,
                onChanged: (value) {
                  setState(() => _paymentMethod = value!);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceOrderButton(
    BuildContext context,
    List<CartItem> items,
    Map<String, double> calculations,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isPlacingOrder || _selectedAddress == null
            ? null
            : () => _placeOrder(context, items, calculations),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isPlacingOrder
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text('Place Order'),
      ),
    );
  }

  void _placeOrder(
    BuildContext context,
    List<CartItem> items,
    Map<String, double> calculations,
  ) {
    if (_selectedAddress == null) return;

    setState(() => _isPlacingOrder = true);

    // Get current user ID (assuming it's stored in auth state)
    // For now, using a mock user ID
    const userId = 'user1';

    context.read<OrderBloc>().add(
      PlaceOrder(
        userId: userId,
        items: items,
        shippingAddress: _selectedAddress!,
        paymentMethod: _paymentMethod,
        subtotal: calculations['subtotal']!,
        tax: calculations['tax']!,
        shipping: calculations['shipping']!,
        total: calculations['total']!,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Load user addresses
    context.read<UserBloc>().add(const LoadUserAddresses('user1'));
  }
}
