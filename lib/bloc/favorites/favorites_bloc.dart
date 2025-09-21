import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/favorites_repository_impl.dart';
import 'favorites_event.dart';
import 'favorites_state.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final FavoritesRepositoryImpl repository;

  FavoritesBloc(this.repository) : super(FavoritesInitial()) {
    on<LoadFavorites>(_onLoadFavorites);
    on<AddToFavorites>(_onAddToFavorites);
    on<RemoveFromFavorites>(_onRemoveFromFavorites);
    on<ToggleFavorite>(_onToggleFavorite);
    on<CheckIsFavorite>(_onCheckIsFavorite);
  }

  Future<void> _onLoadFavorites(
    LoadFavorites event,
    Emitter<FavoritesState> emit,
  ) async {
    emit(FavoritesLoading());
    try {
      final products = await repository.getFavoriteProducts();
      emit(FavoritesLoaded(products));
    } catch (e) {
      emit(FavoritesError(e.toString()));
    }
  }

  Future<void> _onAddToFavorites(
    AddToFavorites event,
    Emitter<FavoritesState> emit,
  ) async {
    try {
      await repository.addToFavorites(event.productId);
      emit(FavoriteToggled(true));
    } catch (e) {
      emit(FavoritesError(e.toString()));
    }
  }

  Future<void> _onRemoveFromFavorites(
    RemoveFromFavorites event,
    Emitter<FavoritesState> emit,
  ) async {
    try {
      await repository.removeFromFavorites(event.productId);
      emit(FavoriteToggled(false));
    } catch (e) {
      emit(FavoritesError(e.toString()));
    }
  }

  Future<void> _onToggleFavorite(
    ToggleFavorite event,
    Emitter<FavoritesState> emit,
  ) async {
    try {
      await repository.toggleFavorite(event.productId);
      final isFavorite = await repository.isFavorite(event.productId);
      emit(FavoriteToggled(isFavorite));
    } catch (e) {
      emit(FavoritesError(e.toString()));
    }
  }

  Future<void> _onCheckIsFavorite(
    CheckIsFavorite event,
    Emitter<FavoritesState> emit,
  ) async {
    try {
      final isFavorite = await repository.isFavorite(event.productId);
      emit(FavoriteStatusChecked(isFavorite));
    } catch (e) {
      emit(FavoritesError(e.toString()));
    }
  }
}
