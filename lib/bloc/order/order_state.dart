import 'package:equatable/equatable.dart';
import '../../../domain/entities/order.dart';

abstract class OrderState extends Equatable {
  const OrderState();

  @override
  List<Object> get props => [];
}

class OrderInitial extends OrderState {}

class OrderLoading extends OrderState {}

class OrderPlaced extends OrderState {
  final Order order;

  const OrderPlaced(this.order);

  @override
  List<Object> get props => [order];
}

class OrderHistoryLoaded extends OrderState {
  final List<Order> orders;

  const OrderHistoryLoaded(this.orders);

  @override
  List<Object> get props => [orders];
}

class OrderDetailLoaded extends OrderState {
  final Order order;

  const OrderDetailLoaded(this.order);

  @override
  List<Object> get props => [order];
}

class OrderError extends OrderState {
  final String message;

  const OrderError(this.message);

  @override
  List<Object> get props => [message];
}
