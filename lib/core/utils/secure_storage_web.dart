import 'dart:html' as html;
import 'package:flutter/foundation.dart';

class SecureStorageImpl {
  static Future<void> write(String key, String value) async {
    html.window.localStorage[key] = value;
    if (kDebugMode) print('🌐 Web: Saved $key to localStorage');
  }

  static Future<String?> read(String key) async {
    final value = html.window.localStorage[key];
    if (kDebugMode && value != null) print('🌐 Web: Read $key from localStorage');
    return value;
  }

  static Future<void> delete(String key) async {
    html.window.localStorage.remove(key);
    if (kDebugMode) print('🌐 Web: Deleted $key from localStorage');
  }
}
