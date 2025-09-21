import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/cart_repository.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final CartRepository repository;

  CartBloc(this.repository) : super(CartInitial()) {
    on<LoadCart>(_onLoadCart);
    on<AddItem>(_onAddItem);
    on<RemoveItem>(_onRemoveItem);
    on<UpdateQuantity>(_onUpdateQuantity);
    on<ClearCart>(_onClearCart);
  }

  Future<void> _onLoadCart(LoadCart event, Emitter<CartState> emit) async {
    emit(CartLoading());
    try {
      final items = await repository.getCartItems();
      emit(CartLoaded(items));
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> _onAddItem(AddItem event, Emitter<CartState> emit) async {
    emit(CartLoading());
    try {
      await repository.addItem(event.item);
      final items = await repository.getCartItems();
      emit(CartLoaded(items));
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> _onRemoveItem(RemoveItem event, Emitter<CartState> emit) async {
    emit(CartLoading());
    try {
      await repository.removeItem(event.productId);
      final items = await repository.getCartItems();
      emit(CartLoaded(items));
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> _onUpdateQuantity(
    UpdateQuantity event,
    Emitter<CartState> emit,
  ) async {
    emit(CartLoading());
    try {
      await repository.updateQuantity(event.productId, event.quantity);
      final items = await repository.getCartItems();
      emit(CartLoaded(items));
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> _onClearCart(ClearCart event, Emitter<CartState> emit) async {
    emit(CartLoading());
    try {
      await repository.clearCart();
      emit(CartLoaded([]));
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }
}
