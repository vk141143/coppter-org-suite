import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../utils/token_storage.dart';
import 'mock_auth_service.dart';

class AuthService {
  static const String _customerBaseUrl = 'http://13.233.195.173:8000/api';
  static const String _driverBaseUrl = 'http://3.110.63.139:8001/api';
  static const String _adminBaseUrl = 'http://3.110.63.139:8001/api';
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
      endpoint = '/auth/login/driver';  // Correct working endpoint
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
    
    // Handle 404 errors for different user types
    if (response.statusCode == 404) {
      if (userType.toLowerCase() == 'admin') {
        if (kDebugMode) print('⚠️ Admin login endpoint not found');
        
        // Use mock for development
        if (MockAuthService.isMockEnabled) {
          if (kDebugMode) print('🎭 Falling back to mock authentication');
          return await MockAuthService.mockAdminLogin(phone);
        }
        
        throw Exception('Admin authentication not configured. Please contact administrator.');
      } else if (userType.toLowerCase() == 'driver') {
        if (kDebugMode) print('⚠️ Driver login endpoint not found, trying alternatives...');
        
        throw Exception('Driver login endpoint not found. Please contact support.');
      }
    }
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      if (kDebugMode) print('✅ Login response: $data');
      
      // For driver/admin, just confirm OTP was sent - DON'T save tokens yet
      if (userType.toLowerCase() == 'driver' || userType.toLowerCase() == 'admin') {
        return {'success': true, 'message': 'OTP sent successfully', 'data': data};
      }
      
      // Only save tokens for customer (direct login)
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

  Future<bool> verifyLogin({
    required String phoneNumber,
    required String otp,
    required String userType,
  }) async {
    try {
      String baseUrl;
      String endpoint;
      
      if (userType.toLowerCase() == 'driver') {
        baseUrl = _driverBaseUrl;
        endpoint = '/auth/verify-login/driver';  // Correct working endpoint
      } else if (userType.toLowerCase() == 'admin') {
        baseUrl = _adminBaseUrl;
        endpoint = '/auth/verify-login/admin';
      } else {
        baseUrl = _customerBaseUrl;
        endpoint = '/auth/verify-login/customer';
      }
      
      final url = Uri.parse('$baseUrl$endpoint');
      
      if (kDebugMode) print('📡 POST $url');
      if (kDebugMode) print('📦 Body: {phone_number: $phoneNumber, otp: $otp}');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'phone_number': phoneNumber, 'otp': otp}),
      );
      
      if (kDebugMode) print('📥 Status: ${response.statusCode}');
      if (kDebugMode) print('📥 Body: ${response.body}');
      
      final data = jsonDecode(response.body);
      if (kDebugMode) print('🔍 Parsed data: $data');
      if (kDebugMode) print('🔍 Success field: ${data['success']} (type: ${data['success'].runtimeType})');
      
      // Check for API error response first
      if (response.statusCode != 200 || data['success'] != true) {
        final errorMessage = data['message'] ?? 
                            data['error']?['error_message'] ?? 
                            'OTP verification failed';
        if (kDebugMode) print('❌ API returned error - Status: ${response.statusCode}, Success: ${data['success']}');
        if (kDebugMode) print('❌ Error message: $errorMessage');
        if (kDebugMode) print('❌ THROWING EXCEPTION NOW');
        throw Exception(errorMessage);
      }
      
      if (kDebugMode) print('✅ API returned success=true, proceeding...');
      
      // Verify we have a valid token
      String? token;
      if (data['access_token'] != null) {
        token = data['access_token'];
      } else if (data['token'] != null) {
        token = data['token'];
      }
      
      if (token == null || token.isEmpty) {
        if (kDebugMode) print('❌ No token in response');
        throw Exception('Invalid OTP - no token received');
      }
      
      if (token.length < 10) {
        if (kDebugMode) print('❌ Invalid token length');
        throw Exception('Invalid token received');
      }
      
      await TokenStorage.saveToken(token, role: userType.toLowerCase());
      
      if (data['refresh_token'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('refresh_${userType.toLowerCase()}', data['refresh_token']);
      }
      
      if (data['driver'] != null) {
        await _saveUserData(data['driver']);
      } else if (data['user'] != null) {
        await _saveUserData(data['user']);
      }
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_phone', phoneNumber);
      
      if (kDebugMode) print('✅ OTP verified successfully');
      return true;
    } catch (e) {
      if (kDebugMode) print('❌ verifyLogin exception: $e');
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<Map<String, dynamic>> verifyOTP(String phone, String otp, String endpoint, {String? userType}) async {
    String baseUrl;
    String actualEndpoint;
    Map<String, dynamic> body;
    
    if (userType?.toLowerCase() == 'admin') {
      baseUrl = _adminBaseUrl;
      actualEndpoint = '/auth/verify-login/admin';
      body = {'phone_number': phone, 'otp': otp};
    } else if (userType?.toLowerCase() == 'driver') {
      baseUrl = _driverBaseUrl;
      actualEndpoint = '/auth/verify-login/driver';
      body = {'phone_number': phone, 'otp': otp};
    } else {
      baseUrl = _customerBaseUrl;
      actualEndpoint = endpoint;
      body = {'phone_number': phone, 'otp_code': otp};
    }
    
    final url = Uri.parse('$baseUrl$actualEndpoint');
    
    if (kDebugMode) print('📡 POST $url');
    if (kDebugMode) print('📦 Body: $body');
    
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    
    if (kDebugMode) print('📥 Status: ${response.statusCode}');
    if (kDebugMode) print('📥 Body: ${response.body}');
    
    if (response.statusCode == 404 && userType?.toLowerCase() == 'admin') {
      if (MockAuthService.isMockEnabled) {
        final mockResult = await MockAuthService.mockAdminVerifyOTP(phone, otp);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_phone', phone);
        return mockResult;
      }
      throw Exception('Admin authentication not configured');
    }
    
    if (response.statusCode != 200) {
      throw Exception('OTP verification failed');
    }
    
    final data = jsonDecode(response.body);
    
    if (kDebugMode) {
      print('🔍 Response data: $data');
      print('🔍 success: ${data['success']}');
      print('🔍 access_token: ${data['access_token']}');
    }
    
    if (data['success'] != true) {
      if (kDebugMode) print('❌ Backend returned success=false');
      throw Exception('Invalid OTP');
    }
    
    final token = data['access_token'];
    
    if (token == null || token is! String || token.length < 20) {
      if (kDebugMode) print('❌ No valid access_token in response');
      throw Exception('Invalid OTP');
    }
    
    if (kDebugMode) print('✅ Token: ${token.substring(0, 20)}...');
    
    await TokenStorage.saveToken(token, role: userType?.toLowerCase());
    
    final savedToken = await TokenStorage.getToken(forRole: userType?.toLowerCase());
    if (savedToken != token) {
      if (kDebugMode) print('❌ Token save failed');
      throw Exception('Failed to save token');
    }
    
    if (kDebugMode) print('✅ Token saved');
    
    if (data['refresh_token'] != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('refresh_${userType?.toLowerCase()}', data['refresh_token']);
    }
    
    if (data['driver'] != null) {
      await _saveUserData(data['driver']);
    } else if (data['user'] != null) {
      await _saveUserData(data['user']);
    }
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_phone', phone);
    
    return {'token': token, 'user': data['driver'] ?? data['user']};
  }

  Future<void> resendOTP(String phone, {String? userType}) async {
    String baseUrl;
    String endpoint;
    
    if (userType?.toLowerCase() == 'admin') {
      baseUrl = _adminBaseUrl;
      endpoint = '/auth/resend-otp/admin';
    } else if (userType?.toLowerCase() == 'driver') {
      baseUrl = _driverBaseUrl;
      endpoint = '/auth/resend-otp/driver';  // Correct endpoint for driver
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
    final prefs = await SharedPreferences.getInstance();
    
    // Auto-detect role from existing tokens
    String? role = await TokenStorage.getUserRole();
    role ??= 'customer';
    if (kDebugMode) print('🔍 Active role: $role');
    
    // Get token for specific role
    final token = await getToken(forRole: role);
    
    if (token == null || token.isEmpty) {
      return {
        'id': prefs.getString(_userIdKey) ?? '',
        'full_name': prefs.getString('user_full_name') ?? 'User',
        'email': prefs.getString('user_email') ?? 'user@example.com',
        'phone_number': prefs.getString('user_phone') ?? '',
        'role': role,
        'is_active': prefs.getBool('user_is_active') ?? true,
        'is_approved': prefs.getBool('user_is_approved') ?? true,
      };
    }
    
    try {
      String baseUrl;
      if (role == 'admin') {
        baseUrl = _adminBaseUrl;
      } else if (role == 'driver') {
        baseUrl = _driverBaseUrl;
      } else {
        baseUrl = _customerBaseUrl;
      }
      
      final url = Uri.parse('$baseUrl/profile/');
      if (kDebugMode) print('📡 GET Request: $url');
      if (kDebugMode) print('🔑 Token: $token');
      
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 5));
      
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
      'role': role,
      'is_active': prefs.getBool('user_is_active') ?? true,
      'is_approved': prefs.getBool('user_is_approved') ?? true,
    };
  }

  Future<Map<String, dynamic>> getDriverProfile() async {
    final token = await getToken(forRole: 'driver');
    
    if (token == null || token.isEmpty) {
      throw Exception('Driver not authenticated');
    }
    
    final url = Uri.parse('$_driverBaseUrl/profile/');
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
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? error['error']?['error_message'] ?? 'Failed to fetch driver profile');
    }
  }

  Future<Map<String, dynamic>> updateProfile({
    required String fullName,
    required String email,
    required String phoneNumber,
  }) async {
    final token = await getToken(forRole: 'customer');
    
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

  Future<void> _saveToken(String token, {String? role}) async {
    await TokenStorage.saveToken(token, role: role);
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
    // Role is now stored with token in TokenStorage, not here
    await prefs.setBool('user_is_active', userData['is_active'] ?? true);
    await prefs.setBool('user_is_approved', userData['is_approved'] ?? true);
  }

  Future<String?> getToken({String? forRole}) async {
    return await TokenStorage.getToken(forRole: forRole);
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
