import 'package:equatable/equatable.dart';

abstract class FavoritesEvent extends Equatable {
  const FavoritesEvent();

  @override
  List<Object> get props => [];
}

class LoadFavorites extends FavoritesEvent {}

class AddToFavorites extends FavoritesEvent {
  final String productId;

  const AddToFavorites(this.productId);

  @override
  List<Object> get props => [productId];
}

class RemoveFromFavorites extends FavoritesEvent {
  final String productId;

  const RemoveFromFavorites(this.productId);

  @override
  List<Object> get props => [productId];
}

class ToggleFavorite extends FavoritesEvent {
  final String productId;

  const ToggleFavorite(this.productId);

  @override
  List<Object> get props => [productId];
}

class CheckIsFavorite extends FavoritesEvent {
  final String productId;

  const CheckIsFavorite(this.productId);

  @override
  List<Object> get props => [productId];
}
