import 'package:equatable/equatable.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object> get props => [];
}

class LoadProducts extends ProductEvent {}

class LoadFeaturedProducts extends ProductEvent {}

class LoadProductsByCategory extends ProductEvent {
  final String categoryId;

  const LoadProductsByCategory(this.categoryId);

  @override
  List<Object> get props => [categoryId];
}

class SearchProducts extends ProductEvent {
  final String query;

  const SearchProducts(this.query);

  @override
  List<Object> get props => [query];
}

class LoadProductDetail extends ProductEvent {
  final String productId;

  const LoadProductDetail(this.productId);

  @override
  List<Object> get props => [productId];
}

class LoadCategories extends ProductEvent {}
