import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

class SecureStorageImpl {
  static const _storage = FlutterSecureStorage();

  static Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
    if (kDebugMode) print('📱 Mobile: Saved $key to secure storage');
  }

  static Future<String?> read(String key) async {
    final value = await _storage.read(key: key);
    if (kDebugMode && value != null) print('📱 Mobile: Read $key from secure storage');
    return value;
  }

  static Future<void> delete(String key) async {
    await _storage.delete(key: key);
    if (kDebugMode) print('📱 Mobile: Deleted $key from secure storage');
  }
}
