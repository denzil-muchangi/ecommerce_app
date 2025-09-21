class Category {
  final String id;
  final String name;
  final String description;
  final String imageUrl;

  const Category({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Category && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
