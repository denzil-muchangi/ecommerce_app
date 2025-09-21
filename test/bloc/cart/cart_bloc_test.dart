import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:ecommerce_app/bloc/cart/cart_bloc.dart';
import 'package:ecommerce_app/bloc/cart/cart_event.dart';
import 'package:ecommerce_app/bloc/cart/cart_state.dart';
import 'package:ecommerce_app/domain/repositories/cart_repository.dart';
import 'package:ecommerce_app/domain/entities/cart_item.dart';

@GenerateMocks([CartRepository])
import 'cart_bloc_test.mocks.dart';

void main() {
  late CartBloc cartBloc;
  late MockCartRepository mockCartRepository;

  setUp(() {
    mockCartRepository = MockCartRepository();
    cartBloc = CartBloc(mockCartRepository);
  });

  tearDown(() {
    cartBloc.close();
  });

  const testCartItem = CartItem(
    productId: '1',
    name: 'Test Product',
    image: 'image.jpg',
    quantity: 2,
    price: 99.99,
  );

  group('CartBloc', () {
    test('initial state is CartInitial', () {
      expect(cartBloc.state, CartInitial());
    });

    blocTest<CartBloc, CartState>(
      'emits [CartLoading, CartLoaded] when LoadCart is added and succeeds',
      build: () => cartBloc,
      act: (bloc) => bloc.add(LoadCart()),
      setUp: () => when(
        mockCartRepository.getCartItems(),
      ).thenAnswer((_) async => [testCartItem]),
      expect: () => [
        CartLoading(),
        CartLoaded([testCartItem]),
      ],
      verify: (_) => verify(mockCartRepository.getCartItems()).called(1),
    );

    blocTest<CartBloc, CartState>(
      'emits [CartLoading, CartError] when LoadCart fails',
      build: () => cartBloc,
      act: (bloc) => bloc.add(LoadCart()),
      setUp: () => when(
        mockCartRepository.getCartItems(),
      ).thenThrow(Exception('Failed to load cart')),
      expect: () => [
        CartLoading(),
        CartError('Exception: Failed to load cart'),
      ],
    );

    blocTest<CartBloc, CartState>(
      'emits [CartLoading, CartLoaded] when AddItem is added and succeeds',
      build: () => cartBloc,
      act: (bloc) => bloc.add(AddItem(testCartItem)),
      setUp: () {
        when(
          mockCartRepository.addItem(testCartItem),
        ).thenAnswer((_) async => {});
        when(
          mockCartRepository.getCartItems(),
        ).thenAnswer((_) async => [testCartItem]);
      },
      expect: () => [
        CartLoading(),
        CartLoaded([testCartItem]),
      ],
    );

    blocTest<CartBloc, CartState>(
      'emits [CartLoading, CartError] when AddItem fails',
      build: () => cartBloc,
      act: (bloc) => bloc.add(AddItem(testCartItem)),
      setUp: () => when(
        mockCartRepository.addItem(testCartItem),
      ).thenThrow(Exception('Failed to add item')),
      expect: () => [CartLoading(), CartError('Exception: Failed to add item')],
    );

    blocTest<CartBloc, CartState>(
      'emits [CartLoading, CartLoaded] when RemoveItem is added and succeeds',
      build: () => cartBloc,
      act: (bloc) => bloc.add(RemoveItem('1')),
      setUp: () {
        when(mockCartRepository.removeItem('1')).thenAnswer((_) async => {});
        when(mockCartRepository.getCartItems()).thenAnswer((_) async => []);
      },
      expect: () => [CartLoading(), CartLoaded([])],
    );

    blocTest<CartBloc, CartState>(
      'emits [CartLoading, CartError] when RemoveItem fails',
      build: () => cartBloc,
      act: (bloc) => bloc.add(RemoveItem('1')),
      setUp: () => when(
        mockCartRepository.removeItem('1'),
      ).thenThrow(Exception('Failed to remove item')),
      expect: () => [
        CartLoading(),
        CartError('Exception: Failed to remove item'),
      ],
    );

    blocTest<CartBloc, CartState>(
      'emits [CartLoading, CartLoaded] when UpdateQuantity is added and succeeds',
      build: () => cartBloc,
      act: (bloc) => bloc.add(UpdateQuantity('1', 3)),
      setUp: () {
        when(
          mockCartRepository.updateQuantity('1', 3),
        ).thenAnswer((_) async => {});
        when(mockCartRepository.getCartItems()).thenAnswer(
          (_) async => [
            const CartItem(
              productId: '1',
              name: 'Test Product',
              image: 'image.jpg',
              quantity: 3,
              price: 99.99,
            ),
          ],
        );
      },
      expect: () => [
        CartLoading(),
        CartLoaded([
          const CartItem(
            productId: '1',
            name: 'Test Product',
            image: 'image.jpg',
            quantity: 3,
            price: 99.99,
          ),
        ]),
      ],
    );

    blocTest<CartBloc, CartState>(
      'emits [CartLoading, CartError] when UpdateQuantity fails',
      build: () => cartBloc,
      act: (bloc) => bloc.add(UpdateQuantity('1', 3)),
      setUp: () => when(
        mockCartRepository.updateQuantity('1', 3),
      ).thenThrow(Exception('Failed to update quantity')),
      expect: () => [
        CartLoading(),
        CartError('Exception: Failed to update quantity'),
      ],
    );

    blocTest<CartBloc, CartState>(
      'emits [CartLoading, CartLoaded] when ClearCart is added and succeeds',
      build: () => cartBloc,
      act: (bloc) => bloc.add(ClearCart()),
      setUp: () {
        when(mockCartRepository.clearCart()).thenAnswer((_) async => {});
      },
      expect: () => [CartLoading(), CartLoaded([])],
    );

    blocTest<CartBloc, CartState>(
      'emits [CartLoading, CartError] when ClearCart fails',
      build: () => cartBloc,
      act: (bloc) => bloc.add(ClearCart()),
      setUp: () => when(
        mockCartRepository.clearCart(),
      ).thenThrow(Exception('Failed to clear cart')),
      expect: () => [
        CartLoading(),
        CartError('Exception: Failed to clear cart'),
      ],
    );
  });
}
