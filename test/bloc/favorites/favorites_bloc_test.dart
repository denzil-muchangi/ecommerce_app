import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:ecommerce_app/bloc/favorites/favorites_bloc.dart';
import 'package:ecommerce_app/bloc/favorites/favorites_event.dart';
import 'package:ecommerce_app/bloc/favorites/favorites_state.dart';
import 'package:ecommerce_app/data/repositories/favorites_repository_impl.dart';
import 'package:ecommerce_app/domain/entities/product.dart';

@GenerateMocks([FavoritesRepositoryImpl])
import 'favorites_bloc_test.mocks.dart';

void main() {
  late FavoritesBloc favoritesBloc;
  late MockFavoritesRepositoryImpl mockFavoritesRepository;

  setUp(() {
    mockFavoritesRepository = MockFavoritesRepositoryImpl();
    favoritesBloc = FavoritesBloc(mockFavoritesRepository);
  });

  tearDown(() {
    favoritesBloc.close();
  });

  const testProduct = Product(
    id: '1',
    name: 'Test Product',
    description: 'Test Description',
    price: 99.99,
    images: ['image1.jpg'],
    categoryId: 'cat1',
    isFeatured: true,
    stock: 10,
    rating: 4.5,
    reviewCount: 5,
  );

  group('FavoritesBloc', () {
    test('initial state is FavoritesInitial', () {
      expect(favoritesBloc.state, FavoritesInitial());
    });

    blocTest<FavoritesBloc, FavoritesState>(
      'emits [FavoritesLoading, FavoritesLoaded] when LoadFavorites is added and succeeds',
      build: () => favoritesBloc,
      act: (bloc) => bloc.add(LoadFavorites()),
      setUp: () => when(
        mockFavoritesRepository.getFavoriteProducts(),
      ).thenAnswer((_) async => [testProduct]),
      expect: () => [
        FavoritesLoading(),
        FavoritesLoaded([testProduct]),
      ],
    );

    blocTest<FavoritesBloc, FavoritesState>(
      'emits [FavoritesLoading, FavoritesError] when LoadFavorites fails',
      build: () => favoritesBloc,
      act: (bloc) => bloc.add(LoadFavorites()),
      setUp: () => when(
        mockFavoritesRepository.getFavoriteProducts(),
      ).thenThrow(Exception('Failed to load favorites')),
      expect: () => [
        FavoritesLoading(),
        FavoritesError('Exception: Failed to load favorites'),
      ],
    );

    blocTest<FavoritesBloc, FavoritesState>(
      'emits [FavoriteToggled] when AddToFavorites is added and succeeds',
      build: () => favoritesBloc,
      act: (bloc) => bloc.add(AddToFavorites('1')),
      setUp: () => when(
        mockFavoritesRepository.addToFavorites('1'),
      ).thenAnswer((_) async => {}),
      expect: () => [FavoriteToggled(true)],
    );

    blocTest<FavoritesBloc, FavoritesState>(
      'emits [FavoritesError] when AddToFavorites fails',
      build: () => favoritesBloc,
      act: (bloc) => bloc.add(AddToFavorites('1')),
      setUp: () => when(
        mockFavoritesRepository.addToFavorites('1'),
      ).thenThrow(Exception('Failed to add to favorites')),
      expect: () => [FavoritesError('Exception: Failed to add to favorites')],
    );

    blocTest<FavoritesBloc, FavoritesState>(
      'emits [FavoriteToggled] when RemoveFromFavorites is added and succeeds',
      build: () => favoritesBloc,
      act: (bloc) => bloc.add(RemoveFromFavorites('1')),
      setUp: () => when(
        mockFavoritesRepository.removeFromFavorites('1'),
      ).thenAnswer((_) async => {}),
      expect: () => [FavoriteToggled(false)],
    );

    blocTest<FavoritesBloc, FavoritesState>(
      'emits [FavoritesError] when RemoveFromFavorites fails',
      build: () => favoritesBloc,
      act: (bloc) => bloc.add(RemoveFromFavorites('1')),
      setUp: () => when(
        mockFavoritesRepository.removeFromFavorites('1'),
      ).thenThrow(Exception('Failed to remove from favorites')),
      expect: () => [
        FavoritesError('Exception: Failed to remove from favorites'),
      ],
    );

    blocTest<FavoritesBloc, FavoritesState>(
      'emits [FavoriteToggled] when ToggleFavorite is added and succeeds',
      build: () => favoritesBloc,
      act: (bloc) => bloc.add(ToggleFavorite('1')),
      setUp: () {
        when(
          mockFavoritesRepository.toggleFavorite('1'),
        ).thenAnswer((_) async => {});
        when(
          mockFavoritesRepository.isFavorite('1'),
        ).thenAnswer((_) async => true);
      },
      expect: () => [FavoriteToggled(true)],
    );

    blocTest<FavoritesBloc, FavoritesState>(
      'emits [FavoritesError] when ToggleFavorite fails',
      build: () => favoritesBloc,
      act: (bloc) => bloc.add(ToggleFavorite('1')),
      setUp: () => when(
        mockFavoritesRepository.toggleFavorite('1'),
      ).thenThrow(Exception('Failed to toggle favorite')),
      expect: () => [FavoritesError('Exception: Failed to toggle favorite')],
    );

    blocTest<FavoritesBloc, FavoritesState>(
      'emits [FavoriteStatusChecked] when CheckIsFavorite is added and succeeds',
      build: () => favoritesBloc,
      act: (bloc) => bloc.add(CheckIsFavorite('1')),
      setUp: () => when(
        mockFavoritesRepository.isFavorite('1'),
      ).thenAnswer((_) async => true),
      expect: () => [FavoriteStatusChecked(true)],
    );

    blocTest<FavoritesBloc, FavoritesState>(
      'emits [FavoritesError] when CheckIsFavorite fails',
      build: () => favoritesBloc,
      act: (bloc) => bloc.add(CheckIsFavorite('1')),
      setUp: () => when(
        mockFavoritesRepository.isFavorite('1'),
      ).thenThrow(Exception('Failed to check favorite status')),
      expect: () => [
        FavoritesError('Exception: Failed to check favorite status'),
      ],
    );
  });
}
