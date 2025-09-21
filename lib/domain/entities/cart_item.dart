class CartItem {
  final String productId;
  final String name;
  final String image;
  final int quantity;
  final double price;

  const CartItem({
    required this.productId,
    required this.name,
    required this.image,
    required this.quantity,
    required this.price,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartItem &&
          runtimeType == other.runtimeType &&
          productId == other.productId;

  @override
  int get hashCode => productId.hashCode;
}
