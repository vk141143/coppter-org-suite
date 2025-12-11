// Translation service using free MyMemory API
// No API key required, no billing
import 'dart:convert';
import 'package:http/http.dart' as http;

class TranslateService {
  static const String _baseUrl = 'https://api.mymemory.translated.net/get';
  
  // Cache to avoid repeated API calls for same text
  static final Map<String, Map<String, String>> _cache = {};

  /// Translates text from English to target language
  /// Returns original text if translation fails
  static Future<String> translate(String text, String targetLang) async {
    // Return original if target is English
    if (targetLang == 'en' || text.trim().isEmpty) return text;

    // Check cache first
    final cacheKey = '$text|$targetLang';
    if (_cache.containsKey(text) && _cache[text]!.containsKey(targetLang)) {
      return _cache[text]![targetLang]!;
    }

    try {
      final url = Uri.parse('$_baseUrl?q=${Uri.encodeComponent(text)}&langpair=en|$targetLang');
      final response = await http.get(url).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final translated = data['responseData']['translatedText'] as String;
        
        // Cache the result
        _cache[text] ??= {};
        _cache[text]![targetLang] = translated;
        
        return translated;
      }
    } catch (e) {
      // Return original text on error
      return text;
    }
    
    return text;
  }

  /// Clear translation cache
  static void clearCache() {
    _cache.clear();
  }
}
