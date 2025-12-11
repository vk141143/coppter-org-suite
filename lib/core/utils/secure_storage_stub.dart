class SecureStorageImpl {
  static Future<void> write(String key, String value) async {
    throw UnsupportedError('Platform not supported');
  }

  static Future<String?> read(String key) async {
    throw UnsupportedError('Platform not supported');
  }

  static Future<void> delete(String key) async {
    throw UnsupportedError('Platform not supported');
  }
}
