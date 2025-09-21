import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:ecommerce_app/bloc/order/order_bloc.dart';
import 'package:ecommerce_app/bloc/order/order_event.dart';
import 'package:ecommerce_app/bloc/order/order_state.dart';
import 'package:ecommerce_app/data/repositories/order_repository_impl.dart';
import 'package:ecommerce_app/domain/entities/order.dart';
import 'package:ecommerce_app/domain/entities/cart_item.dart';
import 'package:ecommerce_app/domain/entities/address.dart';

@GenerateMocks([OrderRepositoryImpl])
import 'order_bloc_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late OrderBloc orderBloc;
  late MockOrderRepositoryImpl mockOrderRepository;

  setUp(() {
    mockOrderRepository = MockOrderRepositoryImpl();
    orderBloc = OrderBloc(mockOrderRepository);
  });

  tearDown(() {
    orderBloc.close();
  });

  const testAddress = Address(
    id: 'addr1',
    userId: 'user1',
    name: 'John Doe',
    phone: '1234567890',
    street: '123 Main St',
    city: 'New York',
    state: 'NY',
    zipCode: '10001',
    country: 'USA',
  );

  const testCartItem = CartItem(
    productId: '1',
    name: 'Test Product',
    image: 'image.jpg',
    quantity: 2,
    price: 99.99,
  );

  final testOrder = Order(
    id: 'order1',
    userId: 'user1',
    items: [testCartItem],
    shippingAddress: testAddress,
    paymentMethod: 'Credit Card',
    status: OrderStatus.pending,
    subtotal: 199.98,
    tax: 20.00,
    shipping: 10.00,
    total: 229.98,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  group('OrderBloc', () {
    test('initial state is OrderInitial', () {
      expect(orderBloc.state, OrderInitial());
    });

    blocTest<OrderBloc, OrderState>(
      'emits [OrderLoading, OrderPlaced] when PlaceOrder is added and succeeds',
      build: () => orderBloc,
      act: (bloc) => bloc.add(
        PlaceOrder(
          userId: 'user1',
          items: [testCartItem],
          shippingAddress: testAddress,
          paymentMethod: 'Credit Card',
          subtotal: 199.98,
          tax: 20.00,
          shipping: 10.00,
          total: 229.98,
        ),
      ),
      setUp: () => when(
        mockOrderRepository.placeOrder(
          userId: 'user1',
          items: [testCartItem],
          shippingAddress: testAddress,
          paymentMethod: 'Credit Card',
          subtotal: 199.98,
          tax: 20.00,
          shipping: 10.00,
          total: 229.98,
        ),
      ).thenAnswer((_) async => testOrder),
      expect: () => [OrderLoading(), OrderPlaced(testOrder)],
    );

    blocTest<OrderBloc, OrderState>(
      'emits [OrderLoading, OrderError] when PlaceOrder fails',
      build: () => orderBloc,
      act: (bloc) => bloc.add(
        PlaceOrder(
          userId: 'user1',
          items: [testCartItem],
          shippingAddress: testAddress,
          paymentMethod: 'Credit Card',
          subtotal: 199.98,
          tax: 20.00,
          shipping: 10.00,
          total: 229.98,
        ),
      ),
      setUp: () => when(
        mockOrderRepository.placeOrder(
          userId: 'user1',
          items: [testCartItem],
          shippingAddress: testAddress,
          paymentMethod: 'Credit Card',
          subtotal: 199.98,
          tax: 20.00,
          shipping: 10.00,
          total: 229.98,
        ),
      ).thenThrow(Exception('Failed to place order')),
      expect: () => [
        OrderLoading(),
        OrderError('Exception: Failed to place order'),
      ],
    );

    blocTest<OrderBloc, OrderState>(
      'emits [OrderLoading, OrderHistoryLoaded] when LoadOrderHistory is added and succeeds',
      build: () => orderBloc,
      act: (bloc) => bloc.add(LoadOrderHistory('user1')),
      setUp: () => when(
        mockOrderRepository.getOrderHistory('user1'),
      ).thenAnswer((_) async => [testOrder]),
      expect: () => [
        OrderLoading(),
        OrderHistoryLoaded([testOrder]),
      ],
    );

    blocTest<OrderBloc, OrderState>(
      'emits [OrderLoading, OrderError] when LoadOrderHistory fails',
      build: () => orderBloc,
      act: (bloc) => bloc.add(LoadOrderHistory('user1')),
      setUp: () => when(
        mockOrderRepository.getOrderHistory('user1'),
      ).thenThrow(Exception('Failed to load order history')),
      expect: () => [
        OrderLoading(),
        OrderError('Exception: Failed to load order history'),
      ],
    );

    blocTest<OrderBloc, OrderState>(
      'emits [OrderLoading, OrderDetailLoaded] when LoadOrderDetail is added and succeeds',
      build: () => orderBloc,
      act: (bloc) => bloc.add(LoadOrderDetail('order1')),
      setUp: () => when(
        mockOrderRepository.getOrderById('order1'),
      ).thenAnswer((_) async => testOrder),
      expect: () => [OrderLoading(), OrderDetailLoaded(testOrder)],
    );

    blocTest<OrderBloc, OrderState>(
      'emits [OrderLoading, OrderError] when LoadOrderDetail fails',
      build: () => orderBloc,
      act: (bloc) => bloc.add(LoadOrderDetail('order1')),
      setUp: () => when(
        mockOrderRepository.getOrderById('order1'),
      ).thenThrow(Exception('Order not found')),
      expect: () => [OrderLoading(), OrderError('Exception: Order not found')],
    );
  });
}
