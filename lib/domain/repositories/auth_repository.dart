import 'package:localservicemarket/domain/entities/user.dart';
import 'package:localservicemarket/domain/enums/user_role.dart';

abstract class AuthRepository {
  Future<User?> getCurrentUser();
  Future<User> login({required String email, required String password});
  Future<User> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required UserRole role,
    String? bio,
  });
  Future<void> logout();
}
