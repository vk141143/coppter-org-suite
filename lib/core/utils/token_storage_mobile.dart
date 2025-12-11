import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class TokenStorageImpl {
  static Future<void> saveToken(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
    if (kDebugMode) print('📱 Mobile: Token saved to SharedPreferences');
  }

  static Future<String?> getToken(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(key);
    if (kDebugMode) print('📱 Mobile: Token retrieved from SharedPreferences');
    return token;
  }

  static Future<void> clearToken(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
    if (kDebugMode) print('📱 Mobile: Token cleared from SharedPreferences');
  }
}
