import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc(this.authRepository) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<CheckAuthStatus>(_onCheckAuthStatus);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.login(event.email, event.password);
      emit(Authenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.register(
        event.email,
        event.password,
        event.name,
      );
      emit(Authenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await authRepository.logout();
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    // Emit loading state while checking authentication status
    emit(AuthLoading());
    try {
      // Check if user has stored authentication data
      final isAuthenticated = await authRepository.isAuthenticated();
      if (isAuthenticated) {
        // If authenticated, retrieve the current user data
        final user = await authRepository.getCurrentUser();
        if (user != null) {
          // Emit authenticated state with user data
          emit(Authenticated(user));
        } else {
          // If user data is missing despite being authenticated, emit unauthenticated
          emit(Unauthenticated());
        }
      } else {
        // No authentication data found, emit unauthenticated state
        emit(Unauthenticated());
      }
    } catch (e) {
      // Handle any errors during authentication check
      emit(AuthError(e.toString()));
    }
  }
}
