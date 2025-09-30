import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppTheme { dark, light, system }

class ThemeProvider extends ChangeNotifier {
  AppTheme _currentTheme = AppTheme.dark;
  late SharedPreferences _prefs;

  AppTheme get currentTheme => _currentTheme;

  // Define color schemes
  static const Color darkPrimary = Color(0xFF111618);
  static const Color darkSecondary = Color(0xFF1C2327);
  static const Color darkAccent = Color(0xFF13A4EC);
  static const Color darkBorder = Color(0xFF283339);

  static const Color lightPrimary = Color(0xFFFFFFFF);
  static const Color lightSecondary = Color(0xFFF5F5F5);
  static const Color lightAccent = Color(0xFF13A4EC);
  static const Color lightBorder = Color(0xFFE0E0E0);

  ThemeData get themeData {
    switch (_currentTheme) {
      case AppTheme.light:
        return _lightTheme;
      case AppTheme.dark:
        return _darkTheme;
      case AppTheme.system:
        return _darkTheme; // Default to dark for now
    }
  }

  ThemeData get _darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: darkAccent,
    scaffoldBackgroundColor: darkPrimary,
    appBarTheme: const AppBarTheme(
      backgroundColor: darkSecondary,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: darkSecondary,
      selectedItemColor: darkAccent,
      unselectedItemColor: Colors.grey,
    ),
    cardTheme: CardThemeData(
      color: darkSecondary,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: darkBorder, width: 1),
      ),
    ),
    colorScheme: const ColorScheme.dark(
      primary: darkAccent,
      secondary: darkAccent,
      surface: darkSecondary,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.white,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white),
      bodySmall: TextStyle(color: Colors.grey),
    ),
    iconTheme: const IconThemeData(color: Colors.white),
    dividerColor: darkBorder,
    fontFamily: 'Roboto',
  );

  ThemeData get _lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: lightAccent,
    scaffoldBackgroundColor: lightPrimary,
    appBarTheme: const AppBarTheme(
      backgroundColor: lightSecondary,
      foregroundColor: Colors.black,
      elevation: 0,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: lightSecondary,
      selectedItemColor: lightAccent,
      unselectedItemColor: Colors.grey,
    ),
    cardTheme: CardThemeData(
      color: lightSecondary,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: lightBorder, width: 1),
      ),
    ),
    colorScheme: const ColorScheme.light(
      primary: lightAccent,
      secondary: lightAccent,
      surface: lightSecondary,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.black,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black),
      bodyMedium: TextStyle(color: Colors.black),
      bodySmall: TextStyle(color: Colors.grey),
    ),
    iconTheme: const IconThemeData(color: Colors.black),
    dividerColor: lightBorder,
    fontFamily: 'Roboto',
  );

  Future<void> initializeTheme() async {
    _prefs = await SharedPreferences.getInstance();
    final themeIndex = _prefs.getInt('theme_index') ?? 0;
    _currentTheme = AppTheme.values[themeIndex];
    notifyListeners();
  }

  Future<void> setTheme(AppTheme theme) async {
    _currentTheme = theme;
    await _prefs.setInt('theme_index', theme.index);
    notifyListeners();
  }

  String getThemeName(AppTheme theme) {
    switch (theme) {
      case AppTheme.light:
        return 'Light';
      case AppTheme.dark:
        return 'Dark';
      case AppTheme.system:
        return 'System';
    }
  }

  IconData getThemeIcon(AppTheme theme) {
    switch (theme) {
      case AppTheme.light:
        return Icons.light_mode;
      case AppTheme.dark:
        return Icons.dark_mode;
      case AppTheme.system:
        return Icons.auto_mode;
    }
  }
}
