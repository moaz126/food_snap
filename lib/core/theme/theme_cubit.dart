import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  static const String _themeKey = 'app_theme';
  final SharedPreferences _prefs;

  ThemeCubit(this._prefs) : super(_loadTheme(_prefs));

  static ThemeMode _loadTheme(SharedPreferences prefs) {
    final saved = prefs.getString(_themeKey);

    // No preference saved yet — follow system
    if (saved == null) return ThemeMode.system;

    // User manually set — respect their choice
    return saved == 'dark' ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> toggle(BuildContext context) async {
    // Get current effective brightness
    // (handles ThemeMode.system case)
    final brightness = MediaQuery.of(context).platformBrightness;

    final isCurrentlyDark = state == ThemeMode.dark ||
        (state == ThemeMode.system && brightness == Brightness.dark);

    final newMode = isCurrentlyDark ? ThemeMode.light : ThemeMode.dark;

    await _prefs.setString(
      _themeKey,
      newMode == ThemeMode.dark ? 'dark' : 'light',
    );

    emit(newMode);
  }

  bool get isDark => state == ThemeMode.dark;
}
