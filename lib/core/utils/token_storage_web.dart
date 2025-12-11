import 'dart:html' as html;
import 'package:flutter/foundation.dart';

class TokenStorageImpl {
  static Future<void> saveToken(String key, String value) async {
    html.window.localStorage[key] = value;
    if (kDebugMode) print('🌐 Web: Token saved to localStorage');
  }

  static Future<String?> getToken(String key) async {
    final token = html.window.localStorage[key];
    if (kDebugMode) print('🌐 Web: Token retrieved from localStorage');
    return token;
  }

  static Future<void> clearToken(String key) async {
    html.window.localStorage.remove(key);
    if (kDebugMode) print('🌐 Web: Token cleared from localStorage');
  }
}
