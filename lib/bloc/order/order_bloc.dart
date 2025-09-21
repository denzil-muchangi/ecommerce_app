import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/order_repository_impl.dart';
import '../../services/notification_service.dart';
import 'order_event.dart';
import 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final OrderRepositoryImpl repository;

  OrderBloc(this.repository) : super(OrderInitial()) {
    on<PlaceOrder>(_onPlaceOrder);
    on<LoadOrderHistory>(_onLoadOrderHistory);
    on<LoadOrderDetail>(_onLoadOrderDetail);
  }

  Future<void> _onPlaceOrder(PlaceOrder event, Emitter<OrderState> emit) async {
    emit(OrderLoading());
    try {
      final order = await repository.placeOrder(
        userId: event.userId,
        items: event.items,
        shippingAddress: event.shippingAddress,
        paymentMethod: event.paymentMethod,
        subtotal: event.subtotal,
        tax: event.tax,
        shipping: event.shipping,
        total: event.total,
        paymentReference: event.paymentReference,
        paymentStatus: event.paymentStatus,
      );
      emit(OrderPlaced(order));

      // Send order confirmation notification
      await NotificationService().showOrderStatusNotification(
        title: 'Order Confirmed',
        body:
            'Your order #${order.id} has been confirmed and is being processed.',
        orderId: order.id,
      );

      // Schedule mock status update notifications
      _scheduleMockOrderUpdates(order.id);
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  Future<void> _onLoadOrderHistory(
    LoadOrderHistory event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());
    try {
      final orders = await repository.getOrderHistory(event.userId);
      emit(OrderHistoryLoaded(orders));
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  Future<void> _onLoadOrderDetail(
    LoadOrderDetail event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());
    try {
      final order = await repository.getOrderById(event.orderId);
      emit(OrderDetailLoaded(order));
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  void _scheduleMockOrderUpdates(String orderId) {
    // Mock order status updates - in a real app, these would come from server
    Future.delayed(const Duration(seconds: 10), () async {
      await NotificationService().showOrderStatusNotification(
        title: 'Order Shipped',
        body: 'Your order #$orderId has been shipped and is on its way!',
        orderId: orderId,
      );
    });

    Future.delayed(const Duration(seconds: 30), () async {
      await NotificationService().showOrderStatusNotification(
        title: 'Order Delivered',
        body:
            'Your order #$orderId has been successfully delivered. Thank you for shopping with us!',
        orderId: orderId,
      );
    });
  }
}
