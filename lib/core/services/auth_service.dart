import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../utils/token_storage.dart';
import 'mock_auth_service.dart';

class AuthService {
  static const String _customerBaseUrl = 'http://13.232.241.195:8000/api';
  static const String _driverBaseUrl = 'http://13.232.241.195:8001/api';
  static const String _adminBaseUrl = 'http://13.232.241.195:8001/api';
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';

  Future<Map<String, dynamic>> login(String phone, String userType, {String? password}) async {
    String baseUrl;
    String endpoint;
    Map<String, dynamic> body;
    
    if (userType.toLowerCase() == 'admin') {
      baseUrl = _adminBaseUrl;
      endpoint = '/auth/login/admin';
      body = {'phone_number': phone};
    } else if (userType.toLowerCase() == 'driver') {
      baseUrl = _driverBaseUrl;
      endpoint = '/auth/login/driver';
      body = {'phone_number': phone};
    } else {
      baseUrl = _customerBaseUrl;
      endpoint = '/auth/login/customer/';
      body = {'phone_number': phone};
    }
    
    final url = Uri.parse('$baseUrl$endpoint');
    
    if (kDebugMode) print('📡 POST Request: $url');
    if (kDebugMode) print('📦 Body: $body');
    
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: jsonEncode(body),
    );
    
    if (kDebugMode) print('📥 Response status: ${response.statusCode}');
    if (kDebugMode) print('📥 Response body: ${response.body}');
    
    if (response.statusCode == 404 && userType.toLowerCase() == 'admin') {
      if (kDebugMode) print('⚠️ Admin login endpoint not found');
      
      // Use mock for development
      if (MockAuthService.isMockEnabled) {
        if (kDebugMode) print('🎭 Falling back to mock authentication');
        return await MockAuthService.mockAdminLogin(phone);
      }
      
      throw Exception('Admin authentication not configured. Please contact administrator.');
    }
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      if (kDebugMode) print('✅ Login response: $data');
      
      if (data['token'] != null) {
        await _saveToken(data['token']);
      }
      if (data['access_token'] != null) {
        await _saveToken(data['access_token']);
      }
      if (data['user'] != null && data['user']['id'] != null) {
        await _saveUserId(data['user']['id'].toString());
      }
      
      return data;
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? error['error']?['error_message'] ?? 'Login failed');
    }
  }

  Future<Map<String, dynamic>> verifyOTP(String phone, String otp, String endpoint, {String? userType}) async {
    String baseUrl;
    Map<String, dynamic> body;
    
    if (userType?.toLowerCase() == 'admin') {
      baseUrl = _adminBaseUrl;
      body = {'phone_number': phone, 'otp': otp};
    } else if (userType?.toLowerCase() == 'driver') {
      baseUrl = _driverBaseUrl;
      body = {'phone_number': phone, 'otp': otp};
    } else {
      baseUrl = _customerBaseUrl;
      body = {'phone_number': phone, 'otp_code': otp};
    }
    
    final url = Uri.parse('$baseUrl$endpoint');
    
    if (kDebugMode) print('📡 POST Request: $url');
    if (kDebugMode) print('📦 Body: $body');
    
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: jsonEncode(body),
    );
    
    if (kDebugMode) print('📥 Response status: ${response.statusCode}');
    if (kDebugMode) print('📥 Response body: ${response.body}');
    
    if (response.statusCode == 404 && userType?.toLowerCase() == 'admin') {
      if (kDebugMode) print('⚠️ Admin endpoint not found - Backend needs admin auth implementation');
      
      // Use mock for development
      if (MockAuthService.isMockEnabled) {
        if (kDebugMode) print('🎭 Falling back to mock OTP verification');
        final mockResult = await MockAuthService.mockAdminVerifyOTP(phone, otp);
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_phone', phone);
        
        return mockResult;
      }
      
      throw Exception('Admin authentication not configured on server. Please contact administrator.');
    }
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      String token;
      
      try {
        final jsonData = jsonDecode(response.body);
        
        // Extract token (support multiple field names)
        if (jsonData is Map && jsonData.containsKey('token')) {
          token = jsonData['token'];
        } else if (jsonData is Map && jsonData.containsKey('access_token')) {
          token = jsonData['access_token'];
        } else if (jsonData is String) {
          token = jsonData;
        } else {
          token = response.body.replaceAll('"', '');
        }
        
        // Extract and save role from response
        String? responseRole;
        if (jsonData is Map && jsonData.containsKey('role')) {
          responseRole = jsonData['role'];
          if (kDebugMode) print('📥 Backend returned role: $responseRole');
        }
        
        // Extract role from JWT token for validation
        final jwtPayload = TokenStorage.decodeJWT(token);
        String? jwtRole;
        if (jwtPayload != null && jwtPayload.containsKey('role')) {
          jwtRole = jwtPayload['role'];
          if (kDebugMode) print('🔍 JWT token contains role: $jwtRole');
        }
        
        // Determine correct role (prioritize JWT, then response, then userType)
        final correctRole = jwtRole ?? responseRole ?? userType?.toLowerCase();
        
        if (correctRole != null) {
          await TokenStorage.saveUserRole(correctRole);
          if (kDebugMode) print('💾 Saved role: $correctRole');
          
          // Warn if mismatch between response and JWT
          if (responseRole != null && jwtRole != null && responseRole != jwtRole) {
            if (kDebugMode) print('⚠️ Role mismatch! Response: $responseRole, JWT: $jwtRole');
          }
        } else {
          if (kDebugMode) print('⚠️ No role found in response or JWT');
        }
        
        // Extract and save user data
        if (jsonData is Map && jsonData.containsKey('user')) {
          await _saveUserData(jsonData['user']);
          if (kDebugMode) print('💾 Saved user data from response');
        }
      } catch (e) {
        token = response.body.replaceAll('"', '');
      }
      
      if (kDebugMode) print('💾 Saving token: ${token.substring(0, token.length > 20 ? 20 : token.length)}... (Full length: ${token.length})');
      await _saveToken(token);
      
      // Verify token was saved
      final savedToken = await getToken();
      if (kDebugMode) print('✅ Token saved successfully: ${savedToken != null && savedToken.isNotEmpty}');
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_phone', phone);
      
      final user = await getUserProfile();
      return {'token': token, 'user': user};
    } else {
      final error = jsonDecode(response.body);
      final errorMsg = error['message'] ?? error['error']?['error_message'] ?? 'OTP verification failed';
      if (kDebugMode) print('❌ Error: $errorMsg');
      throw Exception(errorMsg);
    }
  }

  Future<void> resendOTP(String phone, {String? userType}) async {
    String baseUrl;
    String endpoint;
    
    if (userType?.toLowerCase() == 'driver') {
      baseUrl = _driverBaseUrl;
      endpoint = '/auth/resend-otp/driver';
    } else {
      baseUrl = _customerBaseUrl;
      endpoint = '/auth/resend-otp/';
    }
    
    final url = Uri.parse('$baseUrl$endpoint');
    
    if (kDebugMode) print('📡 POST Request: $url');
    if (kDebugMode) print('📦 Body: {"phone_number": "$phone"}');
    
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: jsonEncode({'phone_number': phone}),
    );
    
    if (kDebugMode) print('📥 Response status: ${response.statusCode}');
    if (kDebugMode) print('📥 Response body: ${response.body}');
    
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? error['error']?['error_message'] ?? 'Failed to resend OTP');
    }
  }



  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    final userType = userData['user_type'] ?? 'customer';
    
    if (userType.toLowerCase() == 'driver') {
      return await registerDriver(userData);
    } else {
      return await registerCustomer(
        fullName: userData['full_name'] ?? '',
        email: userData['email'] ?? '',
        phoneNumber: userData['phone_number'] ?? '',
        address: userData['address'] ?? '',
        password: userData['password'] ?? '',
      );
    }
  }

  Future<Map<String, dynamic>> registerCustomer({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String address,
    required String password,
  }) async {
    final url = Uri.parse('$_customerBaseUrl/auth/register/customer/');
    
    if (kDebugMode) print('📡 POST Request: $url');
    
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: jsonEncode({
        'full_name': fullName,
        'email': email,
        'phone_number': phoneNumber,
        'address': address,
        'password': password,
      }),
    );
    
    if (kDebugMode) print('📥 Response status: ${response.statusCode}');
    if (kDebugMode) print('📥 Response body: ${response.body}');
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      if (data['user_id'] != null) await _saveUserId(data['user_id'].toString());
      if (data['user_data'] != null) await _saveUserData(data['user_data']);
      return data;
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? error['error']?['error_message'] ?? 'Registration failed');
    }
  }

  Future<Map<String, dynamic>> registerAdmin({
    required String fullName,
    required String phoneNumber,
    required String email,
    required String password,
    required String address,
  }) async {
    final url = Uri.parse('$_adminBaseUrl/auth/register/admin');
    
    if (kDebugMode) print('📡 POST Request: $url');
    
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: jsonEncode({
        'full_name': fullName,
        'phone_number': phoneNumber,
        'email': email,
        'password': password,
        'address': address,
      }),
    );
    
    if (kDebugMode) print('📥 Response status: ${response.statusCode}');
    if (kDebugMode) print('📥 Response body: ${response.body}');
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      return data;
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? error['error']?['error_message'] ?? 'Admin registration failed');
    }
  }

  Future<Map<String, dynamic>> registerDriver(
    Map<String, dynamic> driverData, {
    XFile? driverPhoto,
    XFile? licenseFront,
    XFile? licenseBack,
    XFile? insurancePhoto,
    XFile? vehiclePhoto,
    XFile? idPhoto,
    XFile? selfiePhoto,
    XFile? rightToWorkDoc,
    XFile? wasteCarrierLicense,
    XFile? proofOfAddress,
    XFile? v5cDocument,
    XFile? motCertificate,
    XFile? dbsCertificate,
    XFile? healthSafetyCert,
  }) async {
    final url = Uri.parse('$_driverBaseUrl/auth/register/driver/upload');
    final request = http.MultipartRequest('POST', url);
    
    if (kDebugMode) print('📡 POST Request: $url');
    
    // Add text fields with proper type handling
    driverData.forEach((key, value) {
      if (value != null) {
        final stringValue = value.toString();
        if (stringValue.isNotEmpty && stringValue != 'null') {
          request.fields[key] = stringValue;
        }
      }
    });
    
    if (kDebugMode) {
      print('📦 Request Fields (${request.fields.length} fields):');
      request.fields.forEach((key, value) {
        print('  $key: $value (${value.runtimeType})');
      });
    }
    
    // Add required file uploads (web-compatible)
    if (driverPhoto != null) {
      final bytes = await driverPhoto.readAsBytes();
      request.files.add(http.MultipartFile.fromBytes('driver_photo', bytes, filename: driverPhoto.name));
      if (kDebugMode) print('✅ Added driver_photo: ${driverPhoto.name}');
    } else {
      if (kDebugMode) print('❌ Missing driver_photo');
    }
    if (licenseFront != null) {
      final bytes = await licenseFront.readAsBytes();
      request.files.add(http.MultipartFile.fromBytes('license_front', bytes, filename: licenseFront.name));
      if (kDebugMode) print('✅ Added license_front: ${licenseFront.name}');
    } else {
      if (kDebugMode) print('❌ Missing license_front');
    }
    if (licenseBack != null) {
      final bytes = await licenseBack.readAsBytes();
      request.files.add(http.MultipartFile.fromBytes('license_back', bytes, filename: licenseBack.name));
      if (kDebugMode) print('✅ Added license_back: ${licenseBack.name}');
    } else {
      if (kDebugMode) print('❌ Missing license_back');
    }
    if (vehiclePhoto != null) {
      final bytes = await vehiclePhoto.readAsBytes();
      request.files.add(http.MultipartFile.fromBytes('vehicle_photo', bytes, filename: vehiclePhoto.name));
      if (kDebugMode) print('✅ Added vehicle_photo: ${vehiclePhoto.name}');
    } else {
      if (kDebugMode) print('❌ Missing vehicle_photo');
    }
    if (idPhoto != null) {
      final bytes = await idPhoto.readAsBytes();
      request.files.add(http.MultipartFile.fromBytes('govt_id_photo', bytes, filename: idPhoto.name));
      if (kDebugMode) print('✅ Added govt_id_photo: ${idPhoto.name}');
    } else {
      if (kDebugMode) print('❌ Missing govt_id_photo');
    }
    if (selfiePhoto != null) {
      final bytes = await selfiePhoto.readAsBytes();
      request.files.add(http.MultipartFile.fromBytes('selfie_photo', bytes, filename: selfiePhoto.name));
      if (kDebugMode) print('✅ Added selfie_photo: ${selfiePhoto.name}');
    } else {
      if (kDebugMode) print('❌ Missing selfie_photo');
    }
    if (v5cDocument != null) {
      final bytes = await v5cDocument.readAsBytes();
      request.files.add(http.MultipartFile.fromBytes('rc_book_photo', bytes, filename: v5cDocument.name));
      if (kDebugMode) print('✅ Added rc_book_photo: ${v5cDocument.name}');
    } else {
      if (kDebugMode) print('❌ Missing rc_book_photo');
    }
    if (motCertificate != null) {
      final bytes = await motCertificate.readAsBytes();
      request.files.add(http.MultipartFile.fromBytes('pollution_certificate_photo', bytes, filename: motCertificate.name));
      if (kDebugMode) print('✅ Added pollution_certificate_photo: ${motCertificate.name}');
    } else {
      if (kDebugMode) print('❌ Missing pollution_certificate_photo');
    }
    
    if (kDebugMode) print('📦 Total files attached: ${request.files.length}');
    
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    
    if (kDebugMode) print('📥 Response status: ${response.statusCode}');
    if (kDebugMode) print('📥 Response body: ${response.body}');
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      if (data['user_id'] != null) await _saveUserId(data['user_id'].toString());
      if (data['user_data'] != null) await _saveUserData(data['user_data']);
      if (data['user'] != null) await _saveUserData(data['user']);
      return data;
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? error['error']?['error_message'] ?? 'Registration failed');
    }
  }

  Future<void> logout() async {
    await _clearToken();
    await _clearUserId();
  }

  Future<Map<String, dynamic>> getUserProfile() async {
    final token = await getToken();
    final prefs = await SharedPreferences.getInstance();
    
    if (token == null || token.isEmpty) {
      return {
        'id': prefs.getString(_userIdKey) ?? '',
        'full_name': prefs.getString('user_full_name') ?? 'User',
        'email': prefs.getString('user_email') ?? 'user@example.com',
        'phone_number': prefs.getString('user_phone') ?? '',
        'role': prefs.getString('user_role') ?? 'customer',
        'is_active': prefs.getBool('user_is_active') ?? true,
        'is_approved': prefs.getBool('user_is_approved') ?? true,
      };
    }
    
    try {
      final url = Uri.parse('$_customerBaseUrl/profile/');
      if (kDebugMode) print('📡 GET Request: $url');
      if (kDebugMode) print('🔑 Token: $token');
      
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
      }
    } catch (e) {
      if (kDebugMode) print('❌ Profile fetch error: $e');
    }
    
    return {
      'id': prefs.getString(_userIdKey) ?? '',
      'full_name': prefs.getString('user_full_name') ?? 'User',
      'email': prefs.getString('user_email') ?? 'user@example.com',
      'phone_number': prefs.getString('user_phone') ?? '',
      'role': prefs.getString('user_role') ?? 'customer',
      'is_active': prefs.getBool('user_is_active') ?? true,
      'is_approved': prefs.getBool('user_is_approved') ?? true,
    };
  }

  Future<Map<String, dynamic>> updateProfile({
    required String fullName,
    required String email,
    required String phoneNumber,
  }) async {
    final token = await getToken();
    
    final data = {
      'full_name': fullName,
      'email': email,
      'phone_number': phoneNumber,
    };
    
    if (token == null || token.isEmpty) {
      await _saveUserData({
        'full_name': fullName,
        'email': email,
        'phone_number': phoneNumber,
        'role': 'customer',
        'is_active': true,
      });
      return {'success': true, 'message': 'Profile updated locally'};
    }
    
    try {
      final url = Uri.parse('$_customerBaseUrl/profile/');
      if (kDebugMode) print('📡 PATCH Request: $url');
      if (kDebugMode) print('🔑 Token: $token');
      
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
        body: jsonEncode(data),
      );
      
      if (kDebugMode) print('📥 Response status: ${response.statusCode}');
      if (kDebugMode) print('📥 Response body: ${response.body}');
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final result = jsonDecode(response.body);
        await _saveUserData(result);
        return result;
      } else {
        throw Exception('Failed to update profile');
      }
    } catch (e) {
      if (kDebugMode) print('❌ Update profile error: $e');
      await _saveUserData({
        'full_name': fullName,
        'email': email,
        'phone_number': phoneNumber,
        'role': 'customer',
        'is_active': true,
      });
      return {'success': true, 'message': 'Profile updated locally'};
    }
  }

  Future<void> forgotPassword(String phone) async {
    final url = Uri.parse('$_customerBaseUrl/auth/forgot-password');
    await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone}),
    );
  }

  Future<void> resetPassword(String phone, String otp, String newPassword) async {
    final url = Uri.parse('$_customerBaseUrl/auth/reset-password');
    await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone, 'otp': otp, 'new_password': newPassword}),
    );
  }

  Future<void> _saveToken(String token) async {
    await TokenStorage.saveToken(token);
  }

  Future<void> _saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, userId);
  }

  Future<void> _saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    if (userData['id'] != null) await prefs.setString(_userIdKey, userData['id'].toString());
    await prefs.setString('user_full_name', userData['full_name'] ?? '');
    await prefs.setString('user_email', userData['email'] ?? '');
    await prefs.setString('user_phone', userData['phone_number'] ?? '');
    await prefs.setString('user_role', userData['role'] ?? 'customer');
    await prefs.setBool('user_is_active', userData['is_active'] ?? true);
    await prefs.setBool('user_is_approved', userData['is_approved'] ?? true);
  }

  Future<String?> getToken() async {
    return await TokenStorage.getToken();
  }

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null;
  }

  Future<void> _clearToken() async {
    await TokenStorage.clearToken();
  }

  Future<void> _clearUserId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
  }

  void dispose() {}
}
