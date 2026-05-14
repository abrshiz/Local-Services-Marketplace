import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService {
  static const String _tokenKey = 'jwt_token';
  static const String _userKey = 'user_data';

  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  String? _token;
  UserModel? _user;

  String? get token => _token;
  UserModel? get user => _user;
  bool get isAuthenticated => _token != null;

  /// Initialize the service by loading stored credentials
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
    
    final userData = prefs.getString(_userKey);
    if (userData != null) {
      _user = UserModel.fromJson(jsonDecode(userData));
    }
  }

  /// Save token and user data after successful login
  Future<void> setAuth(String token, UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    _token = token;
    _user = user;
    
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  /// Clear all auth data (Logout)
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    _token = null;
    _user = null;
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  /// Mock login method - replace with real API call later
  Future<bool> login(String email, String password) async {
    // This is where you'll use Dio to call your backend
    // Example: 
    // final response = await dio.post('/auth/login', data: {'email': email, 'password': password});
    // final token = response.data['token'];
    
    // For now, let's mock a successful login
    if (email == 'user@example.com' && password == 'password123') {
      final mockUser = UserModel(
        id: '1',
        email: email,
        name: 'John Doe',
        role: 'customer',
      );
      await setAuth('mock_jwt_token_12345', mockUser);
      return true;
    }
    return false;
  }
}
