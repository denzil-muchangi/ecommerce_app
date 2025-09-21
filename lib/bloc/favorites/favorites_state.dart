import 'package:equatable/equatable.dart';
import '../../domain/entities/product.dart';

abstract class FavoritesState extends Equatable {
  const FavoritesState();

  @override
  List<Object> get props => [];
}

class FavoritesInitial extends FavoritesState {}

class FavoritesLoading extends FavoritesState {}

class FavoritesLoaded extends FavoritesState {
  final List<Product> products;

  const FavoritesLoaded(this.products);

  @override
  List<Object> get props => [products];
}

class FavoriteStatusChecked extends FavoritesState {
  final bool isFavorite;

  const FavoriteStatusChecked(this.isFavorite);

  @override
  List<Object> get props => [isFavorite];
}

class FavoriteToggled extends FavoritesState {
  final bool isFavorite;

  const FavoriteToggled(this.isFavorite);

  @override
  List<Object> get props => [isFavorite];
}

class FavoritesError extends FavoritesState {
  final String message;

  const FavoritesError(this.message);

  @override
  List<Object> get props => [message];
}
