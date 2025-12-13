import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';
import '../utils/token_storage.dart';
import 'dart:html' as html show window;

class CustomerApiService {
  static const String _tokenKey = 'customer_token';
  static const String _refreshTokenKey = 'customer_refresh_token';

  Future<String?> _getToken() async {
    try {
      // Try SharedPreferences first
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString(_tokenKey);
      
      // If not found and on web, try localStorage
      if (token == null && kIsWeb) {
        token = html.window.localStorage[_tokenKey];
        if (token != null && token.isNotEmpty) {
          // Sync back to SharedPreferences
          await prefs.setString(_tokenKey, token);
          if (kDebugMode) print('🔄 Token synced from localStorage to SharedPreferences');
        }
      }
      
      if (kDebugMode) {
        if (token != null) {
          print('✅ Token found: ${token.substring(0, 20)}...');
        } else {
          print('❌ NO TOKEN FOUND');
        }
      }
      
      return token;
    } catch (e) {
      if (kDebugMode) print('❌ Error getting token: $e');
      return null;
    }
  }

  Future<void> _saveToken(String token) async {
    try {
      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      
      // Also save to localStorage for web
      if (kIsWeb) {
        html.window.localStorage[_tokenKey] = token;
        if (kDebugMode) print('💾 Token saved to localStorage');
      }
      
      if (kDebugMode) print('💾 Token saved to SharedPreferences');
    } catch (e) {
      if (kDebugMode) print('❌ Error saving token: $e');
    }
  }

  Future<void> _saveRefreshToken(String refreshToken) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_refreshTokenKey, refreshToken);
      
      if (kIsWeb) {
        html.window.localStorage[_refreshTokenKey] = refreshToken;
      }
      
      if (kDebugMode) print('💾 Refresh token saved');
    } catch (e) {
      if (kDebugMode) print('❌ Error saving refresh token: $e');
    }
  }

  Future<void> _removeToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_refreshTokenKey);
      
      if (kIsWeb) {
        html.window.localStorage.remove(_tokenKey);
        html.window.localStorage.remove(_refreshTokenKey);
        if (kDebugMode) print('🗑️ Token removed from localStorage');
      }
      
      if (kDebugMode) print('🗑️ Token removed from SharedPreferences');
    } catch (e) {
      if (kDebugMode) print('❌ Error removing token: $e');
    }
  }

  Future<void> _saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Save ID as string (UUID)
    final id = userData['id']?.toString() ?? '';
    if (id.isNotEmpty) {
      await prefs.setString('customer_id', id);
      await prefs.setString('user_id', id);
      if (kIsWeb) html.window.localStorage['customer_id'] = id;
    }
    
    // Save name
    final name = userData['full_name'] ?? userData['name'] ?? '';
    if (name.isNotEmpty) {
      await prefs.setString('customer_name', name);
      await prefs.setString('user_full_name', name);
      if (kIsWeb) html.window.localStorage['user_full_name'] = name;
    }
    
    // Save email
    if (userData['email'] != null) {
      await prefs.setString('customer_email', userData['email']);
      await prefs.setString('user_email', userData['email']);
      if (kIsWeb) html.window.localStorage['user_email'] = userData['email'];
    }
    
    // Save phone
    final phone = userData['phone_number'] ?? userData['phone'] ?? '';
    if (phone.isNotEmpty) {
      await prefs.setString('customer_phone', phone);
      await prefs.setString('user_phone', phone);
      if (kIsWeb) html.window.localStorage['user_phone'] = phone;
    }
    
    // Save address
    if (userData['address'] != null) {
      await prefs.setString('customer_address', userData['address']);
      if (kIsWeb) html.window.localStorage['customer_address'] = userData['address'];
    }
    
    // Role is now stored with token in TokenStorage, not here
    
    // Save status
    final isActive = userData['is_active'] ?? true;
    await prefs.setBool('user_is_active', isActive);
    if (kIsWeb) html.window.localStorage['user_is_active'] = isActive.toString();
    
    if (kDebugMode) print('💾 User data saved: id=$id, name=$name, email=${userData['email']}, phone=$phone');
  }

  String _extractErrorMessage(dynamic responseBody, int statusCode) {
    try {
      final data = jsonDecode(responseBody);
      if (data is Map) {
        if (data['message'] != null) return data['message'];
        if (data['error'] != null) {
          if (data['error'] is Map && data['error']['error_message'] != null) {
            return data['error']['error_message'];
          }
          return data['error'].toString();
        }
        if (data['detail'] != null) return data['detail'];
      }
    } catch (e) {
      if (kDebugMode) print('Error parsing response: $e');
    }
    
    switch (statusCode) {
      case 400: return 'Invalid input data';
      case 401: return 'Unauthorized. Please login again';
      case 500: return 'Server error. Please try again later';
      default: return 'Something went wrong';
    }
  }

  Future<Map<String, dynamic>> registerCustomer({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String address,
  }) async {
    final url = Uri.parse('${AppConfig.customerBaseUrl}/auth/register/customer/');
    
    if (kDebugMode) print('📡 POST Request: $url');
    
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'full_name': name,
        'email': email,
        'phone_number': phone,
        'password': password,
        'address': address,
      }),
    );
    
    if (kDebugMode) print('📥 Response status: ${response.statusCode}');
    if (kDebugMode) print('📥 Response body: ${response.body}');
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      
      return {
        'success': true,
        'message': data['message'] ?? 'Registration successful',
      };
    } else {
      final errorMsg = _extractErrorMessage(response.body, response.statusCode);
      throw Exception(errorMsg);
    }
  }

  Future<Map<String, dynamic>> requestLoginOtp({
    required String phoneNumber,
  }) async {
    final url = Uri.parse('${AppConfig.customerBaseUrl}/auth/login/customer/');
    
    if (kDebugMode) print('📡 Step 1: Request OTP');
    if (kDebugMode) print('📡 POST Request: $url');
    if (kDebugMode) print('📤 Payload: {"phone_number": "$phoneNumber"}');
    
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'phone_number': phoneNumber,
      }),
    );
    
    if (kDebugMode) print('📥 Response status: ${response.statusCode}');
    if (kDebugMode) print('📥 Response body: ${response.body}');
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      
      return {
        'success': true,
        'message': data['message'] ?? 'OTP sent successfully',
        'phone_number': phoneNumber,
      };
    } else {
      final errorMsg = _extractErrorMessage(response.body, response.statusCode);
      throw Exception(errorMsg);
    }
  }

  Future<Map<String, dynamic>> verifyLoginOtp({
    required String phoneNumber,
    required String otp,
  }) async {
    final url = Uri.parse('${AppConfig.customerBaseUrl}/auth/verify-login-otp/');
    
    final payload = {
      'phone_number': phoneNumber,
      'otp_code': otp,
    };
    
    if (kDebugMode) print('📡 Step 2: Verify OTP and Get Token');
    if (kDebugMode) print('📡 POST Request: $url');
    if (kDebugMode) print('📤 Payload: ${jsonEncode(payload)}');
    
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(payload),
    );
    
    if (kDebugMode) print('📥 Response status: ${response.statusCode}');
    if (kDebugMode) print('📥 Response body: ${response.body}');
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      
      // Handle both 'token' and 'access_token' field names
      String? token = data['token'] ?? data['access_token'];
      String? refreshToken = data['refresh_token'];
      
      if (token != null && token.isNotEmpty) {
        if (kDebugMode) print('🔑 Token received: ${token.substring(0, 20)}...');
        
        // Save using TokenStorage to properly set role
        await TokenStorage.saveToken(token, role: 'customer');
        
        // Also save to local storage for backward compatibility
        await _saveToken(token);
        
        // Verify token was saved
        final savedToken = await TokenStorage.getToken(forRole: 'customer');
        if (savedToken != null && savedToken.isNotEmpty) {
          if (kDebugMode) print('✅ Customer token saved and verified');
        } else {
          if (kDebugMode) print('❌ Token save failed!');
          throw Exception('Failed to save authentication token');
        }
      } else {
        if (kDebugMode) print('❌ No token found in response');
        throw Exception('No authentication token received from server');
      }
      
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await _saveRefreshToken(refreshToken);
      }
      
      // Handle both 'customer' and 'user' field names
      Map<String, dynamic>? userData = data['customer'] ?? data['user'];
      if (userData != null) {
        await _saveUserData(userData);
        if (kDebugMode) print('💾 Customer data saved successfully');
      }
      
      return {
        'success': true,
        'message': data['message'] ?? 'Login successful',
        'token': token,
        'customer': userData,
      };
    } else {
      if (response.statusCode == 401) {
        await _removeToken();
      }
      final errorMsg = _extractErrorMessage(response.body, response.statusCode);
      throw Exception(errorMsg);
    }
  }

  Future<Map<String, dynamic>> getCustomerProfile() async {
    final token = await _getToken();
    
    if (token == null || token.isEmpty) {
      throw Exception('Not authenticated. Please login first');
    }
    
    final url = Uri.parse('${AppConfig.customerBaseUrl}/profile/');
    
    if (kDebugMode) print('📡 GET Request: $url');
    if (kDebugMode) print('🔑 Token: ${token.substring(0, 20)}...');
    
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );
    
    if (kDebugMode) print('📥 Response status: ${response.statusCode}');
    if (kDebugMode) print('📥 Response body: ${response.body}');
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      await _saveUserData(data);
      return data;
    } else {
      if (response.statusCode == 401) {
        await _removeToken();
      }
      final errorMsg = _extractErrorMessage(response.body, response.statusCode);
      throw Exception(errorMsg);
    }
  }

  Future<void> logout() async {
    await _removeToken();
    
    // Clear all customer data
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('customer_id');
    await prefs.remove('customer_name');
    await prefs.remove('customer_email');
    await prefs.remove('customer_phone');
    await prefs.remove('customer_address');
    
    if (kDebugMode) print('👋 Logged out successfully');
  }

  Future<bool> isLoggedIn() async {
    final token = await _getToken();
    final isLoggedIn = token != null && token.isNotEmpty;
    if (kDebugMode) print('🔍 Is logged in: $isLoggedIn');
    return isLoggedIn;
  }

  Future<Map<String, dynamic>> verifyOTP({
    required String phoneNumber,
    required String otp,
  }) async {
    final url = Uri.parse('${AppConfig.customerBaseUrl}/auth/verify-otp/');
    
    final payload = {
      'phone_number': phoneNumber,
      'otp_code': otp,
    };
    
    if (kDebugMode) print('📡 POST Request: $url');
    if (kDebugMode) print('📤 Request body: ${jsonEncode(payload)}');
    
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(payload),
    );
    
    if (kDebugMode) print('📥 Response status: ${response.statusCode}');
    if (kDebugMode) print('📥 Response body: ${response.body}');
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      
      return {
        'success': true,
        'message': data['message'] ?? 'OTP verified successfully',
      };
    } else {
      final errorMsg = _extractErrorMessage(response.body, response.statusCode);
      throw Exception(errorMsg);
    }
  }

  Future<Map<String, dynamic>> verifyOTPAndLogin({
    required String phoneNumber,
    required String otp,
  }) async {
    if (kDebugMode) print('🔐 Registration: Step 1 - Verifying OTP...');
    
    await verifyOTP(phoneNumber: phoneNumber, otp: otp);
    
    if (kDebugMode) print('✅ OTP verified successfully');
    if (kDebugMode) print('🔐 Registration: Step 2 - Logging in to get token...');
    
    final loginResponse = await verifyLoginOtp(phoneNumber: phoneNumber, otp: otp);
    
    if (kDebugMode) print('✅ Login successful, token saved');
    
    return loginResponse;
  }
}
