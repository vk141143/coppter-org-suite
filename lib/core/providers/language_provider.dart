// Language provider to manage app-wide language state
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  String _currentLanguage = 'en';
  
  String get currentLanguage => _currentLanguage;

  // Language options with flags and names
  static const Map<String, Map<String, String>> languages = {
    'en': {'name': 'English', 'flag': '🇺🇸'},
    'hi': {'name': 'Hindi', 'flag': '🇮🇳'},
    'te': {'name': 'Telugu', 'flag': '🇮🇳'},
    'ta': {'name': 'Tamil', 'flag': '🇮🇳'},
    'kn': {'name': 'Kannada', 'flag': '🇮🇳'},
    'ml': {'name': 'Malayalam', 'flag': '🇮🇳'},
    'fr': {'name': 'French', 'flag': '🇫🇷'},
    'es': {'name': 'Spanish', 'flag': '🇪🇸'},
  };

  LanguageProvider() {
    _loadLanguage();
  }

  /// Load saved language from SharedPreferences
  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLanguage = prefs.getString('language') ?? 'en';
    notifyListeners();
  }

  /// Change language and save to SharedPreferences
  Future<void> changeLanguage(String langCode) async {
    if (_currentLanguage != langCode && languages.containsKey(langCode)) {
      _currentLanguage = langCode;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language', langCode);
      notifyListeners();
    }
  }

  /// Get language name
  String getLanguageName(String code) {
    return languages[code]?['name'] ?? 'English';
  }

  /// Get language flag
  String getLanguageFlag(String code) {
    return languages[code]?['flag'] ?? '🇺🇸';
  }
}
