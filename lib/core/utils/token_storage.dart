import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// Conditional import for web
import 'token_storage_stub.dart'
    if (dart.library.html) 'token_storage_web.dart'
    if (dart.library.io) 'token_storage_mobile.dart';

class TokenStorage {
  static const String _tokenKey = 'auth_token';
  static const String _userRoleKey = 'user_role';

  /// Decode JWT token payload (without verification - server verifies)
  static Map<String, dynamic>? decodeJWT(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        if (kDebugMode) print('❌ Invalid JWT format');
        return null;
      }
      
      // Decode payload (second part)
      final payload = parts[1];
      // Add padding if needed
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      
      return json.decode(decoded) as Map<String, dynamic>;
    } catch (e) {
      if (kDebugMode) print('❌ JWT decode error: $e');
      return null;
    }
  }

  static Future<void> saveToken(String token) async {
    if (kDebugMode) print('💾 Saving token: ${token.substring(0, token.length > 20 ? 20 : token.length)}...');
    await TokenStorageImpl.saveToken(_tokenKey, token);
    
    // Verify it was saved
    final saved = await getToken();
    if (kDebugMode) {
      if (saved != null && saved.isNotEmpty) {
        print('✅ TOKEN SAVED SUCCESSFULLY (${saved.length} chars)');
      } else {
        print('❌ TOKEN SAVE FAILED');
      }
    }
  }

  static Future<String?> getToken() async {
    final token = await TokenStorageImpl.getToken(_tokenKey);
    if (kDebugMode) {
      if (token != null && token.isNotEmpty) {
        print('🔑 Token retrieved: ${token.substring(0, token.length > 20 ? 20 : token.length)}... (${token.length} chars)');
      } else {
        print('❌ NO TOKEN FOUND - USER NOT LOGGED IN');
      }
    }
    return token;
  }

  static Future<void> clearToken() async {
    if (kDebugMode) print('🗑️ Clearing token');
    await TokenStorageImpl.clearToken(_tokenKey);
  }

  static Future<void> saveUserRole(String role) async {
    if (kDebugMode) print('💾 Saving user role: $role');
    await TokenStorageImpl.saveToken(_userRoleKey, role);
  }

  static Future<String?> getUserRole() async {
    return await TokenStorageImpl.getToken(_userRoleKey);
  }

  /// Extract role from JWT token payload
  static Future<String?> getRoleFromToken() async {
    final token = await getToken();
    if (token == null || token.isEmpty) {
      if (kDebugMode) print('❌ No token found for role extraction');
      return null;
    }
    
    final payload = TokenStorage.decodeJWT(token);
    if (payload == null) {
      if (kDebugMode) print('❌ Failed to decode JWT token');
      return null;
    }
    
    final role = payload['role'] as String?;
    if (kDebugMode) print('🔍 Extracted role from JWT: $role');
    return role;
  }

  /// Get role with fallback: try JWT first, then stored role
  static Future<String?> getRoleWithFallback() async {
    // Try JWT token first (most reliable)
    final jwtRole = await getRoleFromToken();
    if (jwtRole != null && jwtRole.isNotEmpty) {
      return jwtRole;
    }
    
    // Fallback to stored role
    final storedRole = await getUserRole();
    if (kDebugMode) print('⚠️ Using fallback stored role: $storedRole');
    return storedRole;
  }
}
