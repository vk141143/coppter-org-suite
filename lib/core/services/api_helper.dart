import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/token_storage.dart';

class ApiHelper {
  static const String _customerBaseUrl = 'http://13.233.195.173:8000/api';
  static const String _adminBaseUrl = 'http://3.110.63.139:8001/api';
  static const String _driverBaseUrl = 'http://3.110.63.139:8001/api';

  /// Auto-detect and get the correct token based on endpoint
  static Future<String?> _getTokenForEndpoint(String endpoint) async {
    // Determine role from endpoint
    String? role;
    if (endpoint.contains('/customer/') || endpoint.contains('/auth/login/customer') || endpoint.contains('/auth/register/customer')) {
      role = 'customer';
    } else if (endpoint.contains('/admin/') || endpoint.contains('/auth/login/admin') || endpoint.contains('/auth/register/admin')) {
      role = 'admin';
    } else if (endpoint.contains('/driver/') || endpoint.contains('/auth/login/driver') || endpoint.contains('/auth/register/driver')) {
      role = 'driver';
    }
    
    if (role != null) {
      final token = await TokenStorage.getToken(forRole: role);
      if (kDebugMode) print('🔍 Auto-detected role: $role for endpoint: $endpoint');
      return token;
    }
    
    // Fallback: get any available token
    return await TokenStorage.getToken();
  }

  /// Validate token matches endpoint role
  static Future<void> _validateToken(String endpoint, String token) async {
    final payload = TokenStorage.decodeJWT(token);
    final tokenRole = payload?['role'];
    
    if (endpoint.contains('/customer/') && tokenRole != 'customer') {
      throw Exception('Invalid token: Customer endpoint requires customer token, but got $tokenRole token');
    }
    if (endpoint.contains('/admin/') && tokenRole != 'admin') {
      throw Exception('Invalid token: Admin endpoint requires admin token, but got $tokenRole token');
    }
    if (endpoint.contains('/driver/') && tokenRole != 'driver') {
      throw Exception('Invalid token: Driver endpoint requires driver token, but got $tokenRole token');
    }
  }

  /// GET request with auto token detection
  static Future<http.Response> get(String endpoint, {Map<String, String>? headers}) async {
    final token = await _getTokenForEndpoint(endpoint);
    
    final requestHeaders = {
      'Accept': 'application/json',
      ...?headers,
    };
    
    if (token != null && token.isNotEmpty) {
      await _validateToken(endpoint, token);
      requestHeaders['Authorization'] = 'Bearer $token';
    }
    
    final url = Uri.parse(_getBaseUrl(endpoint) + endpoint);
    if (kDebugMode) print('📡 GET: $url');
    
    return await http.get(url, headers: requestHeaders);
  }

  /// POST request with auto token detection
  static Future<http.Response> post(String endpoint, {Map<String, dynamic>? body, Map<String, String>? headers}) async {
    final token = await _getTokenForEndpoint(endpoint);
    
    final requestHeaders = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      ...?headers,
    };
    
    if (token != null && token.isNotEmpty) {
      await _validateToken(endpoint, token);
      requestHeaders['Authorization'] = 'Bearer $token';
    }
    
    final url = Uri.parse(_getBaseUrl(endpoint) + endpoint);
    if (kDebugMode) {
      print('📡 POST: $url');
      print('📦 Body: ${jsonEncode(body)}');
      if (token != null) print('🔑 Token role: ${TokenStorage.decodeJWT(token)?['role']}');
    }
    
    return await http.post(
      url,
      headers: requestHeaders,
      body: body != null ? jsonEncode(body) : null,
    );
  }

  /// PATCH request with auto token detection
  static Future<http.Response> patch(String endpoint, {Map<String, dynamic>? body, Map<String, String>? headers}) async {
    final token = await _getTokenForEndpoint(endpoint);
    
    final requestHeaders = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      ...?headers,
    };
    
    if (token != null && token.isNotEmpty) {
      await _validateToken(endpoint, token);
      requestHeaders['Authorization'] = 'Bearer $token';
    }
    
    final url = Uri.parse(_getBaseUrl(endpoint) + endpoint);
    if (kDebugMode) print('📡 PATCH: $url');
    
    return await http.patch(
      url,
      headers: requestHeaders,
      body: body != null ? jsonEncode(body) : null,
    );
  }

  /// DELETE request with auto token detection
  static Future<http.Response> delete(String endpoint, {Map<String, String>? headers}) async {
    final token = await _getTokenForEndpoint(endpoint);
    
    final requestHeaders = {
      'Accept': 'application/json',
      ...?headers,
    };
    
    if (token != null && token.isNotEmpty) {
      await _validateToken(endpoint, token);
      requestHeaders['Authorization'] = 'Bearer $token';
    }
    
    final url = Uri.parse(_getBaseUrl(endpoint) + endpoint);
    if (kDebugMode) print('📡 DELETE: $url');
    
    return await http.delete(url, headers: requestHeaders);
  }

  /// Get base URL based on endpoint
  static String _getBaseUrl(String endpoint) {
    if (endpoint.contains('/customer/') || endpoint.contains('/auth/login/customer') || endpoint.contains('/auth/register/customer')) {
      return _customerBaseUrl;
    } else if (endpoint.contains('/admin/') || endpoint.contains('/auth/login/admin') || endpoint.contains('/auth/register/admin')) {
      return _adminBaseUrl;
    } else if (endpoint.contains('/driver/') || endpoint.contains('/auth/login/driver') || endpoint.contains('/auth/register/driver')) {
      return _driverBaseUrl;
    }
    return _customerBaseUrl; // Default
  }

  /// Check if user has valid token for specific role
  static Future<bool> hasValidToken(String role) async {
    final token = await TokenStorage.getToken(forRole: role);
    if (token == null || token.isEmpty) return false;
    
    final payload = TokenStorage.decodeJWT(token);
    return payload?['role'] == role;
  }

  /// Get current user role from token
  static Future<String?> getCurrentRole() async {
    return await TokenStorage.getUserRole();
  }
}
