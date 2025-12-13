import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// Conditional import for web
import 'token_storage_stub.dart'
    if (dart.library.html) 'token_storage_web.dart'
    if (dart.library.io) 'token_storage_mobile.dart';

class TokenStorage {
  static const String _customerTokenKey = 'customer_token';
  static const String _adminTokenKey = 'admin_token';
  static const String _driverTokenKey = 'driver_token';
  static const String _customerRoleKey = 'customer_role';
  static const String _adminRoleKey = 'admin_role';
  static const String _driverRoleKey = 'driver_role';

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

  static Future<void> saveToken(String token, {String? role}) async {
    if (kDebugMode) print('💾 Saving token: ${token.substring(0, token.length > 20 ? 20 : token.length)}...');
    
    // Extract role from JWT if not provided
    final tokenRole = role ?? decodeJWT(token)?['role'];
    
    if (tokenRole == 'customer') {
      // Clear admin/driver tokens and roles
      await TokenStorageImpl.clearToken(_adminTokenKey);
      await TokenStorageImpl.clearToken(_driverTokenKey);
      await TokenStorageImpl.clearToken(_adminRoleKey);
      await TokenStorageImpl.clearToken(_driverRoleKey);
      
      // Save customer token and role
      await TokenStorageImpl.saveToken(_customerTokenKey, token);
      await TokenStorageImpl.saveToken(_customerRoleKey, 'customer');
      if (kDebugMode) print('✅ Saved CUSTOMER token + role');
    } else if (tokenRole == 'admin') {
      // Clear customer/driver tokens and roles
      await TokenStorageImpl.clearToken(_customerTokenKey);
      await TokenStorageImpl.clearToken(_driverTokenKey);
      await TokenStorageImpl.clearToken(_customerRoleKey);
      await TokenStorageImpl.clearToken(_driverRoleKey);
      
      // Save admin token and role
      await TokenStorageImpl.saveToken(_adminTokenKey, token);
      await TokenStorageImpl.saveToken(_adminRoleKey, 'admin');
      if (kDebugMode) print('✅ Saved ADMIN token + role');
    } else if (tokenRole == 'driver') {
      // Clear customer/admin tokens and roles
      await TokenStorageImpl.clearToken(_customerTokenKey);
      await TokenStorageImpl.clearToken(_adminTokenKey);
      await TokenStorageImpl.clearToken(_customerRoleKey);
      await TokenStorageImpl.clearToken(_adminRoleKey);
      
      // Save driver token and role
      await TokenStorageImpl.saveToken(_driverTokenKey, token);
      await TokenStorageImpl.saveToken(_driverRoleKey, 'driver');
      if (kDebugMode) print('✅ Saved DRIVER token + role');
    } else {
      if (kDebugMode) print('⚠️ Unknown role: $tokenRole');
    }
  }

  static Future<String?> getToken({String? forRole}) async {
    String? token;
    String? detectedRole;
    
    if (forRole == 'customer') {
      token = await TokenStorageImpl.getToken(_customerTokenKey);
      detectedRole = 'customer';
    } else if (forRole == 'admin') {
      token = await TokenStorageImpl.getToken(_adminTokenKey);
      detectedRole = 'admin';
    } else if (forRole == 'driver') {
      token = await TokenStorageImpl.getToken(_driverTokenKey);
      detectedRole = 'driver';
    } else {
      // Auto-detect: check which token exists
      final adminToken = await TokenStorageImpl.getToken(_adminTokenKey);
      if (adminToken != null && adminToken.isNotEmpty) {
        token = adminToken;
        detectedRole = 'admin';
      } else {
        final customerToken = await TokenStorageImpl.getToken(_customerTokenKey);
        if (customerToken != null && customerToken.isNotEmpty) {
          token = customerToken;
          detectedRole = 'customer';
        } else {
          final driverToken = await TokenStorageImpl.getToken(_driverTokenKey);
          if (driverToken != null && driverToken.isNotEmpty) {
            token = driverToken;
            detectedRole = 'driver';
          }
        }
      }
    }
    
    if (kDebugMode && token != null && token.isNotEmpty) {
      print('🔑 Token retrieved for role: $detectedRole (${token.length} chars)');
    }
    return token;
  }

  static Future<void> clearToken({String? role}) async {
    if (kDebugMode) print('🗑️ Clearing token for role: $role');
    if (role == 'customer' || role == null) {
      await TokenStorageImpl.clearToken(_customerTokenKey);
      await TokenStorageImpl.clearToken(_customerRoleKey);
    }
    if (role == 'admin' || role == null) {
      await TokenStorageImpl.clearToken(_adminTokenKey);
      await TokenStorageImpl.clearToken(_adminRoleKey);
    }
    if (role == 'driver' || role == null) {
      await TokenStorageImpl.clearToken(_driverTokenKey);
      await TokenStorageImpl.clearToken(_driverRoleKey);
    }
  }

  static Future<void> saveUserRole(String role) async {
    // Role is now saved with token, this method is deprecated
    if (kDebugMode) print('⚠️ saveUserRole is deprecated, role saved with token');
  }

  static Future<String?> getUserRole() async {
    // Auto-detect role from existing tokens
    final adminToken = await TokenStorageImpl.getToken(_adminTokenKey);
    if (adminToken != null && adminToken.isNotEmpty) {
      return 'admin';
    }
    
    final customerToken = await TokenStorageImpl.getToken(_customerTokenKey);
    if (customerToken != null && customerToken.isNotEmpty) {
      return 'customer';
    }
    
    final driverToken = await TokenStorageImpl.getToken(_driverTokenKey);
    if (driverToken != null && driverToken.isNotEmpty) {
      return 'driver';
    }
    
    return null;
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

  /// Get role with fallback: try JWT first, then auto-detect from tokens
  static Future<String?> getRoleWithFallback() async {
    // Try JWT token first (most reliable)
    final jwtRole = await getRoleFromToken();
    if (jwtRole != null && jwtRole.isNotEmpty) {
      return jwtRole;
    }
    
    // Fallback to auto-detect from existing tokens
    return await getUserRole();
  }
  
  /// Validate token matches expected role
  static Future<bool> validateTokenRole(String expectedRole) async {
    final token = await getToken(forRole: expectedRole);
    if (token == null) {
      if (kDebugMode) print('❌ No token found for role: $expectedRole');
      return false;
    }
    
    final payload = decodeJWT(token);
    final actualRole = payload?['role'];
    
    if (actualRole != expectedRole) {
      if (kDebugMode) print('❌ Token role mismatch: expected $expectedRole, got $actualRole');
      return false;
    }
    
    if (kDebugMode) print('✅ Token validated for role: $expectedRole');
    return true;
  }
}
