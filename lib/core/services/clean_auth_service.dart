import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../utils/secure_storage.dart';
import '../config/app_config.dart';

class CleanAuthService {
  static String get _baseUrl => AppConfig.technicianBaseUrl;

  /// Login - Send OTP
  Future<Map<String, dynamic>> login(String phone, String userType) async {
    String endpoint;
    
    switch (userType.toLowerCase()) {
      case 'admin':
        endpoint = '/auth/login/admin';
        break;
      case 'driver':
        endpoint = '/auth/login/driver';
        break;
      case 'customer':
        endpoint = '/auth/login/customer';
        break;
      default:
        throw Exception('Invalid user type');
    }
    
    final url = Uri.parse('$_baseUrl$endpoint');
    
    if (kDebugMode) print('📡 POST $url');
    if (kDebugMode) print('📦 Body: {"phone_number": "$phone"}');
    
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: jsonEncode({'phone_number': phone}),
    );
    
    if (kDebugMode) print('📥 Status: ${response.statusCode}');
    if (kDebugMode) print('📥 Body: ${response.body}');
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? error['error']?['error_message'] ?? 'Login failed');
    }
  }

  /// Verify OTP and save token + user data
  Future<Map<String, dynamic>> verifyOTP(String phone, String otp, String userType) async {
    String endpoint;
    
    switch (userType.toLowerCase()) {
      case 'admin':
        endpoint = '/auth/verify-login/admin';
        break;
      case 'driver':
        endpoint = '/auth/verify-login/driver';
        break;
      case 'customer':
        endpoint = '/auth/verify-login/customer';
        break;
      default:
        throw Exception('Invalid user type');
    }
    
    final url = Uri.parse('$_baseUrl$endpoint');
    
    if (kDebugMode) print('📡 POST $url');
    if (kDebugMode) print('📦 Body: {"phone_number": "$phone", "otp": "$otp"}');
    
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: jsonEncode({'phone_number': phone, 'otp': otp}),
    );
    
    if (kDebugMode) print('📥 Status: ${response.statusCode}');
    if (kDebugMode) print('📥 Body: ${response.body}');
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final result = jsonDecode(response.body);
      
      // Extract data from response
      final data = result['data'] ?? {};
      final token = data['auth_token'] ?? '';
      
      if (token.isEmpty) {
        throw Exception('No token received from server');
      }
      
      // CRITICAL: Clear all old data first
      await SecureStorage.clearAll();
      if (kDebugMode) print('🧹 Cleared old session data');
      
      // Save new token
      await SecureStorage.saveToken(token);
      
      // Save new user data
      await SecureStorage.saveUserData(data);
      
      if (kDebugMode) print('✅ Login successful: role=${data['user_role']}');
      
      return result;
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? error['error']?['error_message'] ?? 'OTP verification failed');
    }
  }

  /// Logout - Clear all data
  Future<void> logout() async {
    await SecureStorage.clearAll();
    if (kDebugMode) print('👋 Logged out successfully');
  }

  /// Check if authenticated
  Future<bool> isAuthenticated() async {
    return await SecureStorage.isAuthenticated();
  }

  /// Get current user role
  Future<String?> getUserRole() async {
    return await SecureStorage.getUserRole();
  }

  /// Get current token
  Future<String?> getToken() async {
    return await SecureStorage.getToken();
  }
}
