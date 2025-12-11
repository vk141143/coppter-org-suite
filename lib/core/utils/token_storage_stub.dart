// Stub implementation - should never be used
class TokenStorageImpl {
  static Future<void> saveToken(String key, String value) async {
    throw UnsupportedError('Platform not supported');
  }

  static Future<String?> getToken(String key) async {
    throw UnsupportedError('Platform not supported');
  }

  static Future<void> clearToken(String key) async {
    throw UnsupportedError('Platform not supported');
  }
}
