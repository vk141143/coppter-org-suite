import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TranslationService {
  static final TranslationService _instance = TranslationService._internal();
  factory TranslationService() => _instance;
  TranslationService._internal();

  final Map<String, String> _cache = {};

  Future<String> translateText(String text, String from, String to) async {
    if (from == to) return text;
    
    final cacheKey = '$from-$to-$text';
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    try {
      final result = await _translateWithLibre(text, from, to);
      _cache[cacheKey] = result;
      await _saveCacheToPrefs();
      return result;
    } catch (e) {
      try {
        final result = await _translateWithMyMemory(text, from, to);
        _cache[cacheKey] = result;
        await _saveCacheToPrefs();
        return result;
      } catch (e) {
        return text;
      }
    }
  }

  Future<String> _translateWithLibre(String text, String from, String to) async {
    final response = await http.post(
      Uri.parse('https://libretranslate.com/translate'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'q': text,
        'source': from,
        'target': to,
        'format': 'text',
      }),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['translatedText'] ?? text;
    }
    throw Exception('Translation failed');
  }

  Future<String> _translateWithMyMemory(String text, String from, String to) async {
    final response = await http.get(
      Uri.parse(
        'https://api.mymemory.translated.net/get?q=${Uri.encodeComponent(text)}&langpair=$from|$to',
      ),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['responseData']['translatedText'] ?? text;
    }
    throw Exception('Translation failed');
  }

  Future<void> _saveCacheToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('translation_cache', jsonEncode(_cache));
  }

  Future<void> loadCacheFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final cacheString = prefs.getString('translation_cache');
    if (cacheString != null) {
      final Map<String, dynamic> decoded = jsonDecode(cacheString);
      _cache.addAll(decoded.cast<String, String>());
    }
  }
}