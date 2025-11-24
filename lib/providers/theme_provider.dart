// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class ThemeProvider with ChangeNotifier {
//   static const String _themeModeKey = 'themeMode';
//   ThemeMode _themeMode = ThemeMode.system;

//   ThemeMode get themeMode => _themeMode;

//   ThemeProvider() {
//     _loadThemeMode();
//   }

//   Future<void> _loadThemeMode() async {
//     final prefs = await SharedPreferences.getInstance();
//     final themeString = prefs.getString(_themeModeKey) ?? 'system';
//     _themeMode = _getThemeModeFromString(themeString);
//     notifyListeners();
//   }

//   Future<void> setThemeMode(ThemeMode mode) async {
//     if (_themeMode == mode) return;

//     _themeMode = mode;
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString(_themeModeKey, mode.name);
//     notifyListeners();
//   }

//   ThemeMode _getThemeModeFromString(String themeString) {
//     switch (themeString) {
//       case 'light': return ThemeMode.light;
//       case 'dark': return ThemeMode.dark;
//       default: return ThemeMode.system;
//     }
//   }
// }