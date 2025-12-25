import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguage {
  english('en', 'English'),
  vietnamese('vi', 'Tiếng Việt');

  final String code;
  final String displayName;
  const AppLanguage(this.code, this.displayName);

  static AppLanguage fromCode(String code) {
    return AppLanguage.values.firstWhere(
      (lang) => lang.code == code,
      orElse: () => AppLanguage.english,
    );
  }
}

class SettingsProvider extends ChangeNotifier {
  static const String _languageKey = 'app_language';
  static const String _darkModeKey = 'dark_mode';
  static const String _soundEffectsKey = 'sound_effects';

  AppLanguage _language = AppLanguage.english;
  bool _darkMode = false;
  bool _soundEffects = true;
  bool _isInitialized = false;

  AppLanguage get language => _language;
  bool get darkMode => _darkMode;
  bool get soundEffects => _soundEffects;
  bool get isInitialized => _isInitialized;
  Locale get locale => Locale(_language.code);

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final languageCode = prefs.getString(_languageKey);
      if (languageCode != null) {
        _language = AppLanguage.fromCode(languageCode);
      }
      
      _darkMode = prefs.getBool(_darkModeKey) ?? false;
      _soundEffects = prefs.getBool(_soundEffectsKey) ?? true;
    } catch (e) {
      print('Error loading settings: $e');
    }
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> setLanguage(AppLanguage language) async {
    if (_language == language) return;
    
    _language = language;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, language.code);
    } catch (e) {
      print('Error saving language setting: $e');
    }
  }

  Future<void> setDarkMode(bool value) async {
    if (_darkMode == value) return;
    
    _darkMode = value;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_darkModeKey, value);
    } catch (e) {
      print('Error saving dark mode setting: $e');
    }
  }

  Future<void> setSoundEffects(bool value) async {
    if (_soundEffects == value) return;
    
    _soundEffects = value;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_soundEffectsKey, value);
    } catch (e) {
      print('Error saving sound effects setting: $e');
    }
  }
}
