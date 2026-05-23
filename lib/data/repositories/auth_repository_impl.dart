import 'package:localservicemarket/core/error/exceptions.dart';
import 'package:localservicemarket/core/error/failures.dart';
import 'package:localservicemarket/data/datasources/remote/api_data_source.dart';
import 'package:localservicemarket/data/models/user_model.dart';
import 'package:localservicemarket/domain/entities/user.dart';
import 'package:localservicemarket/domain/enums/user_role.dart';
import 'package:localservicemarket/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._api);

  final ApiDataSource _api;

  @override
  Future<User?> getCurrentUser() async {
    try {
      await _api.ensureInitialized();
      final json = await _api.currentUser();
      if (json == null) return null;
      return UserModel.fromJson(json);
    } catch (e) {
      throw AuthFailure(e.toString());
    }
  }

  @override
  Future<User> login({required String email, required String password}) async {
    try {
      final json = await _api.login(email, password);
      if (json == null) throw const AuthFailure('Login failed');
      return UserModel.fromJson(json);
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    } on NetworkException catch (e) {
      throw AuthFailure(e.message);
    } catch (e) {
      if (e is AuthFailure) rethrow;
      throw AuthFailure(
        e is Exception ? e.toString().replaceFirst('Exception: ', '') : 'Login failed',
      );
    }
  }

  @override
  Future<User> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required UserRole role,
    String? bio,
    List<String> categoryIds = const [],
  }) async {
    try {
      final json = await _api.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
        role: role,
        bio: bio,
        categoryIds: categoryIds,
      );
      return UserModel.fromJson(json);
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    } on NetworkException catch (e) {
      throw AuthFailure(e.message);
    } catch (e) {
      if (e is AuthFailure) rethrow;
      throw AuthFailure(
        e is Exception ? e.toString().replaceFirst('Exception: ', '') : 'Registration failed',
      );
    }
  }

  @override
  Future<void> logout() => _api.logout();
}
