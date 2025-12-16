import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  ThemeMode _themeMode = ThemeMode.light;
  bool _isDarkMode = false;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(_themeKey) ?? false;
    _themeMode = _isDarkMode ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    _themeMode = _isDarkMode ? ThemeMode.dark : ThemeMode.light;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, _isDarkMode);
    
    notifyListeners();
  }

  Future<void> setThemeMode(bool isDark) async {
    _isDarkMode = isDark;
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDark);
    
    notifyListeners();
  }
}
