import 'package:flutter/foundation.dart';
import 'secure_storage_stub.dart'
    if (dart.library.html) 'secure_storage_web.dart'
    if (dart.library.io) 'secure_storage_mobile.dart';

/// Unified secure storage for tokens and user data
class SecureStorage {
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _userRoleKey = 'user_role';
  static const String _userFullNameKey = 'user_full_name';
  static const String _userPhoneKey = 'user_phone';
  static const String _userEmailKey = 'user_email';
  static const String _userIsActiveKey = 'user_is_active';
  static const String _userIsApprovedKey = 'user_is_approved';

  /// Save authentication token
  static Future<void> saveToken(String token) async {
    if (kDebugMode) print('💾 Saving token...');
    await SecureStorageImpl.write(_tokenKey, token);
    if (kDebugMode) print('✅ Token saved successfully');
  }

  /// Get authentication token
  static Future<String?> getToken() async {
    final token = await SecureStorageImpl.read(_tokenKey);
    if (kDebugMode) {
      if (token != null && token.isNotEmpty) {
        print('🔑 Token retrieved (${token.length} chars)');
      } else {
        print('❌ No token found');
      }
    }
    return token;
  }

  /// Save complete user data from backend response
  static Future<void> saveUserData(Map<String, dynamic> data) async {
    if (kDebugMode) print('💾 Saving user data...');
    
    await SecureStorageImpl.write(_userIdKey, data['user_id']?.toString() ?? '');
    await SecureStorageImpl.write(_userRoleKey, data['user_role']?.toString() ?? '');
    await SecureStorageImpl.write(_userFullNameKey, data['user_full_name']?.toString() ?? '');
    await SecureStorageImpl.write(_userPhoneKey, data['user_phone']?.toString() ?? '');
    await SecureStorageImpl.write(_userEmailKey, data['user_email']?.toString() ?? '');
    await SecureStorageImpl.write(_userIsActiveKey, data['user_is_active']?.toString() ?? 'false');
    await SecureStorageImpl.write(_userIsApprovedKey, data['user_is_approved']?.toString() ?? 'false');
    
    if (kDebugMode) print('✅ User data saved: role=${data['user_role']}');
  }

  /// Get user role
  static Future<String?> getUserRole() async {
    return await SecureStorageImpl.read(_userRoleKey);
  }

  /// Get all user data
  static Future<Map<String, String?>> getUserData() async {
    return {
      'user_id': await SecureStorageImpl.read(_userIdKey),
      'user_role': await SecureStorageImpl.read(_userRoleKey),
      'user_full_name': await SecureStorageImpl.read(_userFullNameKey),
      'user_phone': await SecureStorageImpl.read(_userPhoneKey),
      'user_email': await SecureStorageImpl.read(_userEmailKey),
      'user_is_active': await SecureStorageImpl.read(_userIsActiveKey),
      'user_is_approved': await SecureStorageImpl.read(_userIsApprovedKey),
    };
  }

  /// Clear all stored data (logout)
  static Future<void> clearAll() async {
    if (kDebugMode) print('🗑️ Clearing all stored data...');
    
    await SecureStorageImpl.delete(_tokenKey);
    await SecureStorageImpl.delete(_userIdKey);
    await SecureStorageImpl.delete(_userRoleKey);
    await SecureStorageImpl.delete(_userFullNameKey);
    await SecureStorageImpl.delete(_userPhoneKey);
    await SecureStorageImpl.delete(_userEmailKey);
    await SecureStorageImpl.delete(_userIsActiveKey);
    await SecureStorageImpl.delete(_userIsApprovedKey);
    
    if (kDebugMode) print('✅ All data cleared');
  }

  /// Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
