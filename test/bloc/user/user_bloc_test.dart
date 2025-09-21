import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:ecommerce_app/bloc/user/user_bloc.dart';
import 'package:ecommerce_app/bloc/user/user_event.dart';
import 'package:ecommerce_app/bloc/user/user_state.dart';
import 'package:ecommerce_app/data/repositories/user_repository.dart';
import 'package:ecommerce_app/domain/entities/user.dart';
import 'package:ecommerce_app/domain/entities/address.dart';

@GenerateMocks([UserRepository])
import 'user_bloc_test.mocks.dart';

void main() {
  late UserBloc userBloc;
  late MockUserRepository mockUserRepository;

  setUp(() {
    mockUserRepository = MockUserRepository();
    userBloc = UserBloc(mockUserRepository);
  });

  tearDown(() {
    userBloc.close();
  });

  const testUser = User(
    id: '1',
    email: 'test@example.com',
    name: 'Test User',
    phone: '1234567890',
  );

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

  group('UserBloc', () {
    test('initial state is UserInitial', () {
      expect(userBloc.state, UserInitial());
    });

    blocTest<UserBloc, UserState>(
      'emits [UserLoading, UserProfileLoaded] when LoadUserProfile is added and succeeds',
      build: () => userBloc,
      act: (bloc) => bloc.add(LoadUserProfile('1')),
      setUp: () => when(
        mockUserRepository.getUserProfile('1'),
      ).thenAnswer((_) async => testUser),
      expect: () => [UserLoading(), UserProfileLoaded(testUser)],
    );

    blocTest<UserBloc, UserState>(
      'emits [UserLoading, UserError] when LoadUserProfile fails',
      build: () => userBloc,
      act: (bloc) => bloc.add(LoadUserProfile('1')),
      setUp: () => when(
        mockUserRepository.getUserProfile('1'),
      ).thenThrow(Exception('User not found')),
      expect: () => [UserLoading(), UserError('Exception: User not found')],
    );

    blocTest<UserBloc, UserState>(
      'emits [UserLoading, UserProfileUpdated] when UpdateUserProfile is added and succeeds',
      build: () => userBloc,
      act: (bloc) => bloc.add(
        UpdateUserProfile(
          userId: '1',
          name: 'Updated Name',
          email: 'updated@example.com',
          phone: '0987654321',
        ),
      ),
      setUp: () => when(
        mockUserRepository.updateUserProfile(
          '1',
          'Updated Name',
          'updated@example.com',
          '0987654321',
        ),
      ).thenAnswer((_) async => testUser),
      expect: () => [UserLoading(), UserProfileUpdated(testUser)],
    );

    blocTest<UserBloc, UserState>(
      'emits [UserLoading, UserError] when UpdateUserProfile fails',
      build: () => userBloc,
      act: (bloc) => bloc.add(
        UpdateUserProfile(
          userId: '1',
          name: 'Updated Name',
          email: 'updated@example.com',
        ),
      ),
      setUp: () => when(
        mockUserRepository.updateUserProfile(
          '1',
          'Updated Name',
          'updated@example.com',
          null,
        ),
      ).thenThrow(Exception('Update failed')),
      expect: () => [UserLoading(), UserError('Exception: Update failed')],
    );

    blocTest<UserBloc, UserState>(
      'emits [UserLoading, UserAddressesLoaded] when LoadUserAddresses is added and succeeds',
      build: () => userBloc,
      act: (bloc) => bloc.add(LoadUserAddresses('1')),
      setUp: () => when(
        mockUserRepository.getUserAddresses('1'),
      ).thenAnswer((_) async => [testAddress]),
      expect: () => [
        UserLoading(),
        UserAddressesLoaded([testAddress]),
      ],
    );

    blocTest<UserBloc, UserState>(
      'emits [UserLoading, UserError] when LoadUserAddresses fails',
      build: () => userBloc,
      act: (bloc) => bloc.add(LoadUserAddresses('1')),
      setUp: () => when(
        mockUserRepository.getUserAddresses('1'),
      ).thenThrow(Exception('Failed to load addresses')),
      expect: () => [
        UserLoading(),
        UserError('Exception: Failed to load addresses'),
      ],
    );

    blocTest<UserBloc, UserState>(
      'emits [UserLoading, UserAddressAdded] when AddUserAddress is added and succeeds',
      build: () => userBloc,
      act: (bloc) => bloc.add(AddUserAddress('1', testAddress)),
      setUp: () => when(
        mockUserRepository.addUserAddress('1', testAddress),
      ).thenAnswer((_) async => testAddress),
      expect: () => [UserLoading(), UserAddressAdded(testAddress)],
    );

    blocTest<UserBloc, UserState>(
      'emits [UserLoading, UserError] when AddUserAddress fails',
      build: () => userBloc,
      act: (bloc) => bloc.add(AddUserAddress('1', testAddress)),
      setUp: () => when(
        mockUserRepository.addUserAddress('1', testAddress),
      ).thenThrow(Exception('Failed to add address')),
      expect: () => [
        UserLoading(),
        UserError('Exception: Failed to add address'),
      ],
    );

    blocTest<UserBloc, UserState>(
      'emits [UserLoading, UserAddressUpdated] when UpdateUserAddress is added and succeeds',
      build: () => userBloc,
      act: (bloc) => bloc.add(UpdateUserAddress('1', testAddress)),
      setUp: () => when(
        mockUserRepository.updateUserAddress('1', testAddress),
      ).thenAnswer((_) async => testAddress),
      expect: () => [UserLoading(), UserAddressUpdated(testAddress)],
    );

    blocTest<UserBloc, UserState>(
      'emits [UserLoading, UserError] when UpdateUserAddress fails',
      build: () => userBloc,
      act: (bloc) => bloc.add(UpdateUserAddress('1', testAddress)),
      setUp: () => when(
        mockUserRepository.updateUserAddress('1', testAddress),
      ).thenThrow(Exception('Failed to update address')),
      expect: () => [
        UserLoading(),
        UserError('Exception: Failed to update address'),
      ],
    );

    blocTest<UserBloc, UserState>(
      'emits [UserLoading, UserAddressDeleted] when DeleteUserAddress is added and succeeds',
      build: () => userBloc,
      act: (bloc) => bloc.add(DeleteUserAddress('1', 'addr1')),
      setUp: () => when(
        mockUserRepository.deleteUserAddress('1', 'addr1'),
      ).thenAnswer((_) async => {}),
      expect: () => [UserLoading(), UserAddressDeleted('addr1')],
    );

    blocTest<UserBloc, UserState>(
      'emits [UserLoading, UserError] when DeleteUserAddress fails',
      build: () => userBloc,
      act: (bloc) => bloc.add(DeleteUserAddress('1', 'addr1')),
      setUp: () => when(
        mockUserRepository.deleteUserAddress('1', 'addr1'),
      ).thenThrow(Exception('Failed to delete address')),
      expect: () => [
        UserLoading(),
        UserError('Exception: Failed to delete address'),
      ],
    );

    blocTest<UserBloc, UserState>(
      'emits [UserLoading, UserAddressesLoaded] when SetDefaultAddress is added and succeeds',
      build: () => userBloc,
      act: (bloc) => bloc.add(SetDefaultAddress('1', 'addr1')),
      setUp: () {
        when(
          mockUserRepository.setDefaultAddress('1', 'addr1'),
        ).thenAnswer((_) async => {});
        when(
          mockUserRepository.getUserAddresses('1'),
        ).thenAnswer((_) async => [testAddress]);
      },
      expect: () => [
        UserLoading(),
        UserAddressesLoaded([testAddress]),
      ],
    );

    blocTest<UserBloc, UserState>(
      'emits [UserLoading, UserError] when SetDefaultAddress fails',
      build: () => userBloc,
      act: (bloc) => bloc.add(SetDefaultAddress('1', 'addr1')),
      setUp: () => when(
        mockUserRepository.setDefaultAddress('1', 'addr1'),
      ).thenThrow(Exception('Failed to set default address')),
      expect: () => [
        UserLoading(),
        UserError('Exception: Failed to set default address'),
      ],
    );
  });
}
