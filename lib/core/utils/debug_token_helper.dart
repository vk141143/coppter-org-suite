import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'token_storage.dart';
import 'dart:html' as html show window;

class DebugTokenHelper {
  static Future<void> printTokenStatus() async {
    if (!kDebugMode) return;
    
    print('\n========== TOKEN STATUS ==========');
    
    final prefs = await SharedPreferences.getInstance();
    
    // Check all token keys in both SharedPreferences and localStorage
    final customerToken = prefs.getString('customer_token') ?? html.window.localStorage['customer_token'];
    final adminToken = prefs.getString('admin_token') ?? html.window.localStorage['admin_token'];
    final driverToken = prefs.getString('driver_token') ?? html.window.localStorage['driver_token'];
    
    print('Customer Token: ${customerToken != null && customerToken.isNotEmpty ? "EXISTS (${customerToken.substring(0, 20)}...)" : "NULL"}');
    print('Admin Token: ${adminToken != null && adminToken.isNotEmpty ? "EXISTS (${adminToken.substring(0, 20)}...)" : "NULL"}');
    print('Driver Token: ${driverToken != null && driverToken.isNotEmpty ? "EXISTS (${driverToken.substring(0, 20)}...)" : "NULL"}');
    
    // Check role
    final role = await TokenStorage.getUserRole();
    print('Detected Role: ${role ?? "NULL"}');
    
    // Check which token would be used
    final activeToken = await TokenStorage.getToken();
    if (activeToken != null && activeToken.isNotEmpty) {
      final payload = TokenStorage.decodeJWT(activeToken);
      print('Active Token Role: ${payload?['role'] ?? "NULL"}');
      print('Token Valid: ${payload != null}');
    } else {
      print('Active Token: NULL');
    }
    
    print('==================================\n');
  }
  
  static Future<void> clearAllTokens() async {
    print('🗑️ Clearing all tokens...');
    
    // Clear TokenStorage
    await TokenStorage.clearToken();
    
    // Clear SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    
    // Clear localStorage
    html.window.localStorage.clear();
    
    print('✅ All tokens cleared');
  }
  
  static Future<bool> hasValidCustomerToken() async {
    final token = await TokenStorage.getToken(forRole: 'customer');
    if (token == null || token.isEmpty) {
      if (kDebugMode) print('❌ No customer token found');
      return false;
    }
    
    final payload = TokenStorage.decodeJWT(token);
    if (payload == null || payload['role'] != 'customer') {
      if (kDebugMode) print('❌ Invalid customer token role: ${payload?['role']}');
      return false;
    }
    
    if (kDebugMode) print('✅ Valid customer token found');
    return true;
  }
}
