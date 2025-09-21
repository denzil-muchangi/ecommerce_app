import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:ecommerce_app/bloc/auth/auth_bloc.dart';
import 'package:ecommerce_app/bloc/auth/auth_event.dart';
import 'package:ecommerce_app/bloc/auth/auth_state.dart';
import 'package:ecommerce_app/data/repositories/auth_repository.dart';
import 'package:ecommerce_app/domain/entities/user.dart';

@GenerateMocks([AuthRepository])
import 'auth_bloc_test.mocks.dart';

void main() {
  late AuthBloc authBloc;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    authBloc = AuthBloc(mockAuthRepository);
  });

  tearDown(() {
    authBloc.close();
  });

  const testUser = User(
    id: '1',
    email: 'test@example.com',
    name: 'Test User',
    phone: '1234567890',
  );

  group('AuthBloc', () {
    test('initial state is AuthInitial', () {
      expect(authBloc.state, AuthInitial());
    });

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Authenticated] when LoginRequested is added and succeeds',
      build: () => authBloc,
      act: (bloc) => bloc.add(LoginRequested('test@example.com', 'password')),
      setUp: () => when(
        mockAuthRepository.login('test@example.com', 'password'),
      ).thenAnswer((_) async => testUser),
      expect: () => [AuthLoading(), Authenticated(testUser)],
      verify: (_) => verify(
        mockAuthRepository.login('test@example.com', 'password'),
      ).called(1),
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when LoginRequested fails',
      build: () => authBloc,
      act: (bloc) => bloc.add(LoginRequested('test@example.com', 'password')),
      setUp: () => when(
        mockAuthRepository.login('test@example.com', 'password'),
      ).thenThrow(Exception('Invalid credentials')),
      expect: () => [
        AuthLoading(),
        AuthError('Exception: Invalid credentials'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Authenticated] when RegisterRequested is added and succeeds',
      build: () => authBloc,
      act: (bloc) => bloc.add(
        RegisterRequested('test@example.com', 'password', 'Test User'),
      ),
      setUp: () => when(
        mockAuthRepository.register(
          'test@example.com',
          'password',
          'Test User',
        ),
      ).thenAnswer((_) async => testUser),
      expect: () => [AuthLoading(), Authenticated(testUser)],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when RegisterRequested fails',
      build: () => authBloc,
      act: (bloc) => bloc.add(
        RegisterRequested('test@example.com', 'password', 'Test User'),
      ),
      setUp: () => when(
        mockAuthRepository.register(
          'test@example.com',
          'password',
          'Test User',
        ),
      ).thenThrow(Exception('Registration failed')),
      expect: () => [
        AuthLoading(),
        AuthError('Exception: Registration failed'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Unauthenticated] when LogoutRequested is added and succeeds',
      build: () => authBloc,
      act: (bloc) => bloc.add(LogoutRequested()),
      setUp: () =>
          when(mockAuthRepository.logout()).thenAnswer((_) async => {}),
      expect: () => [AuthLoading(), Unauthenticated()],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when LogoutRequested fails',
      build: () => authBloc,
      act: (bloc) => bloc.add(LogoutRequested()),
      setUp: () => when(
        mockAuthRepository.logout(),
      ).thenThrow(Exception('Logout failed')),
      expect: () => [AuthLoading(), AuthError('Exception: Logout failed')],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Authenticated] when CheckAuthStatus is added and user is authenticated',
      build: () => authBloc,
      act: (bloc) => bloc.add(CheckAuthStatus()),
      setUp: () {
        when(
          mockAuthRepository.isAuthenticated(),
        ).thenAnswer((_) async => true);
        when(
          mockAuthRepository.getCurrentUser(),
        ).thenAnswer((_) async => testUser);
      },
      expect: () => [AuthLoading(), Authenticated(testUser)],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Unauthenticated] when CheckAuthStatus is added and user is not authenticated',
      build: () => authBloc,
      act: (bloc) => bloc.add(CheckAuthStatus()),
      setUp: () => when(
        mockAuthRepository.isAuthenticated(),
      ).thenAnswer((_) async => false),
      expect: () => [AuthLoading(), Unauthenticated()],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Unauthenticated] when CheckAuthStatus is added and user is authenticated but getCurrentUser returns null',
      build: () => authBloc,
      act: (bloc) => bloc.add(CheckAuthStatus()),
      setUp: () {
        when(
          mockAuthRepository.isAuthenticated(),
        ).thenAnswer((_) async => true);
        when(mockAuthRepository.getCurrentUser()).thenAnswer((_) async => null);
      },
      expect: () => [AuthLoading(), Unauthenticated()],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when CheckAuthStatus fails',
      build: () => authBloc,
      act: (bloc) => bloc.add(CheckAuthStatus()),
      setUp: () => when(
        mockAuthRepository.isAuthenticated(),
      ).thenThrow(Exception('Auth check failed')),
      expect: () => [AuthLoading(), AuthError('Exception: Auth check failed')],
    );
  });
}
