import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:localservicemarket/core/error/failures.dart';
import 'package:localservicemarket/domain/enums/user_role.dart';
import 'package:localservicemarket/domain/repositories/auth_repository.dart';
import 'package:localservicemarket/presentation/auth/bloc/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._authRepository) : super(const AuthState());

  final AuthRepository _authRepository;

  Future<void> checkSession() async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final user = await _authRepository.getCurrentUser();
      if (user == null) {
        emit(const AuthState(status: AuthStatus.unauthenticated));
      } else {
        emit(AuthState(status: AuthStatus.authenticated, user: user));
      }
    } catch (e) {
      emit(AuthState(status: AuthStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> login(String email, String password) async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));
    try {
      final user = await _authRepository.login(email: email, password: password);
      emit(AuthState(status: AuthStatus.authenticated, user: user));
    } on AuthFailure catch (e) {
      emit(AuthState(status: AuthStatus.failure, errorMessage: e.message));
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required UserRole role,
    String? bio,
  }) async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));
    try {
      final user = await _authRepository.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
        role: role,
        bio: bio,
      );
      emit(AuthState(status: AuthStatus.authenticated, user: user));
    } on AuthFailure catch (e) {
      emit(AuthState(status: AuthStatus.failure, errorMessage: e.message));
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }
}
