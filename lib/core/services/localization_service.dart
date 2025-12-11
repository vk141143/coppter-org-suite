import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalizationService extends ChangeNotifier {
  static final LocalizationService _instance = LocalizationService._internal();
  factory LocalizationService() => _instance;
  LocalizationService._internal();

  Map<String, String> _localizedStrings = {};
  String _currentLanguage = 'en';
  
  static const List<Map<String, String>> supportedLanguages = [
    {'code': 'en', 'name': 'English', 'rtl': 'false'},
    {'code': 'ar', 'name': 'العربية', 'rtl': 'true'},
    {'code': 'fr', 'name': 'Français', 'rtl': 'false'},
    {'code': 'es', 'name': 'Español', 'rtl': 'false'},
    {'code': 'de', 'name': 'Deutsch', 'rtl': 'false'},
    {'code': 'pt', 'name': 'Português', 'rtl': 'false'},
    {'code': 'zh', 'name': '中文', 'rtl': 'false'},
    {'code': 'ja', 'name': '日本語', 'rtl': 'false'},
    {'code': 'ko', 'name': '한국어', 'rtl': 'false'},
    {'code': 'ru', 'name': 'Русский', 'rtl': 'false'},
    {'code': 'hi', 'name': 'हिन्दी', 'rtl': 'false'},
    {'code': 'ta', 'name': 'தமிழ்', 'rtl': 'false'},
    {'code': 'te', 'name': 'తెలుగు', 'rtl': 'false'},
    {'code': 'kn', 'name': 'ಕನ್ನಡ', 'rtl': 'false'},
    {'code': 'ml', 'name': 'മലയാളം', 'rtl': 'false'},
  ];

  String get currentLanguage => _currentLanguage;
  bool get isRTL => supportedLanguages.firstWhere(
    (lang) => lang['code'] == _currentLanguage,
    orElse: () => {'rtl': 'false'},
  )['rtl'] == 'true';

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString('language');
    
    if (savedLanguage != null && _isLanguageSupported(savedLanguage)) {
      await loadLanguage(savedLanguage);
    } else {
      final systemLocale = WidgetsBinding.instance.platformDispatcher.locale.languageCode;
      if (_isLanguageSupported(systemLocale)) {
        await loadLanguage(systemLocale);
      } else {
        await loadLanguage('en');
      }
    }
  }

  bool _isLanguageSupported(String code) {
    return supportedLanguages.any((lang) => lang['code'] == code);
  }

  Future<void> loadLanguage(String languageCode) async {
    try {
      // Language files disabled - using default English
      _localizedStrings = {};
      _currentLanguage = languageCode;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language', languageCode);
      
      notifyListeners();
    } catch (e) {
      // Ignore errors
    }
  }

  String t(String key) {
    return _localizedStrings[key] ?? key;
  }

  String translate(String key) => t(key);
}