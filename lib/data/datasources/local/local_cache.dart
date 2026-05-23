import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class LocalCache {
  LocalCache(this._prefs);

  final SharedPreferences _prefs;

  static const _storeKey = 'lsm_store_v1';
  static const _sessionKey = 'lsm_session_user_id';
  static const _tokenKey = 'lsm_auth_token';

  Map<String, dynamic>? readStore() {
    final raw = _prefs.getString(_storeKey);
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<void> writeStore(Map<String, dynamic> store) async {
    await _prefs.setString(_storeKey, jsonEncode(store));
  }

  String? getSessionUserId() => _prefs.getString(_sessionKey);

  Future<void> setSessionUserId(String? userId) async {
    if (userId == null) {
      await _prefs.remove(_sessionKey);
    } else {
      await _prefs.setString(_sessionKey, userId);
    }
  }

  String? getAuthToken() => _prefs.getString(_tokenKey);

  Future<void> setAuthToken(String? token) async {
    if (token == null || token.isEmpty) {
      await _prefs.remove(_tokenKey);
    } else {
      await _prefs.setString(_tokenKey, token);
    }
  }
}
