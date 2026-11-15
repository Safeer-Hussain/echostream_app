import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  static const String _prefKey = 'app_theme_mode';
  final SharedPreferences _prefs;

  ThemeCubit(this._prefs) : super(_loadInitialTheme(_prefs));

  static ThemeMode _loadInitialTheme(SharedPreferences prefs) {
    final saved = prefs.getString(_prefKey);
    if (saved == 'light') {
      return ThemeMode.light;
    }
    return ThemeMode.dark;
  }

  void toggleTheme() {
    final nextMode = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    _prefs.setString(_prefKey, nextMode == ThemeMode.light ? 'light' : 'dark');
    emit(nextMode);
  }

  void setTheme(ThemeMode mode) {
    _prefs.setString(_prefKey, mode == ThemeMode.light ? 'light' : 'dark');
    emit(mode);
  }
}
