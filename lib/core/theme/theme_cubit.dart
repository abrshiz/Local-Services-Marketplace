import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit(this._prefs) : super(ThemeMode.system) {
    final stored = _prefs.getString(_key);
    if (stored == 'dark') emit(ThemeMode.dark);
    if (stored == 'light') emit(ThemeMode.light);
  }

  static const _key = 'theme_mode';

  final SharedPreferences _prefs;

  Future<void> setDark(bool enabled) async {
    final mode = enabled ? ThemeMode.dark : ThemeMode.light;
    await _prefs.setString(_key, enabled ? 'dark' : 'light');
    emit(mode);
  }

  void toggle() => setDark(state != ThemeMode.dark);
}
