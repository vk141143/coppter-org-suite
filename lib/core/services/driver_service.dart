import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'api_service.dart';
import 'auth_service.dart';

class DriverService {
  static const String _baseUrl = 'http://3.110.63.139:8001/api';
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  Future<List<dynamic>> getAssignedJobs() async {
    final token = await _authService.getToken();
    if (token == null) throw ApiException('Not authenticated');

    final response = await _apiService.get('/driver/jobs', token: token);
    return response['jobs'] ?? [];
  }

  Future<Map<String, dynamic>> acceptJob(String jobId) async {
    final token = await _authService.getToken();
    if (token == null) throw ApiException('Not authenticated');

    return await _apiService.post('/driver/jobs/$jobId/accept', {}, token: token);
  }

  Future<Map<String, dynamic>> rejectJob(String jobId, String reason) async {
    final token = await _authService.getToken();
    if (token == null) throw ApiException('Not authenticated');

    return await _apiService.post('/driver/jobs/$jobId/reject', {
      'reason': reason,
    }, token: token);
  }

  Future<Map<String, dynamic>> startJob(String jobId) async {
    final token = await _authService.getToken();
    if (token == null) throw ApiException('Not authenticated');

    return await _apiService.post('/driver/jobs/$jobId/start', {}, token: token);
  }

  Future<Map<String, dynamic>> completeJob(String jobId, String? proofImageUrl) async {
    final token = await _authService.getToken();
    if (token == null) throw ApiException('Not authenticated');

    return await _apiService.post('/driver/jobs/$jobId/complete', {
      'proof_image_url': proofImageUrl,
    }, token: token);
  }

  Future<Map<String, dynamic>> updateLocation(double latitude, double longitude) async {
    final token = await _authService.getToken();
    if (token == null) throw ApiException('Not authenticated');

    return await _apiService.post('/driver/location', {
      'latitude': latitude,
      'longitude': longitude,
    }, token: token);
  }

  Future<Map<String, dynamic>> toggleOnlineStatus(bool isOnline) async {
    final token = await _authService.getToken();
    if (token == null) throw ApiException('Not authenticated');

    return await _apiService.post('/driver/status', {
      'is_online': isOnline,
    }, token: token);
  }

  Future<Map<String, dynamic>> getEarnings({String? period}) async {
    final token = await _authService.getToken();
    if (token == null) throw ApiException('Not authenticated');

    final endpoint = period != null 
        ? '/driver/earnings?period=$period' 
        : '/driver/earnings';
    
    return await _apiService.get(endpoint, token: token);
  }

  Future<List<dynamic>> getJobHistory() async {
    final token = await _authService.getToken();
    if (token == null) throw ApiException('Not authenticated');

    final response = await _apiService.get('/driver/jobs/history', token: token);
    return response['jobs'] ?? [];
  }

  Future<List<Map<String, dynamic>>> getAvailableIssues() async {
    final token = await _authService.getToken(forRole: 'driver');
    if (token == null) throw ApiException('Not authenticated');

    final url = Uri.parse('$_baseUrl/driver/issue');
    if (kDebugMode) print('📡 GET: $url');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (kDebugMode) print('📥 Status: ${response.statusCode}');
    if (kDebugMode) print('📥 Body: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw ApiException('Failed to fetch issues');
    }
  }

  Future<Map<String, dynamic>> registerDriverWithUpload({
    required Map<String, dynamic> driverData,
    required XFile? driverPhoto,
    required XFile? licenseFront,
    required XFile? licenseBack,
    required XFile? govtIdPhoto,
    required XFile? selfiePhoto,
    required XFile? vehiclePhoto,
    required XFile? rcBookPhoto,
    required XFile? pollutionCertPhoto,
  }) async {
    final url = Uri.parse('$_baseUrl/auth/register/driver/upload');
    final request = http.MultipartRequest('POST', url);
    
    if (kDebugMode) print('📡 Multipart POST: $url');
    
    // Add ALL required text fields
    request.fields['full_name'] = driverData['full_name'] ?? '';
    request.fields['phone_number'] = driverData['phone_number'] ?? '';
    request.fields['email'] = driverData['email'] ?? '';
    request.fields['dob'] = driverData['dob'] ?? '';
    request.fields['address'] = driverData['address'] ?? '';
    request.fields['govt_id_type'] = driverData['govt_id_type'] ?? 'aadhar';
    request.fields['govt_id_number'] = driverData['govt_id_number'] ?? '';
    request.fields['years_of_experience'] = driverData['years_of_experience']?.toString() ?? '0';
    request.fields['license_number'] = driverData['license_number'] ?? '';
    request.fields['license_category'] = driverData['license_category'] ?? '';
    request.fields['license_expiry_date'] = driverData['license_expiry_date'] ?? '';
    request.fields['vehicle_type'] = driverData['vehicle_type'] ?? '';
    request.fields['vehicle_number'] = driverData['vehicle_number'] ?? '';
    request.fields['vehicle_model'] = driverData['vehicle_model'] ?? '';
    request.fields['vehicle_capacity'] = driverData['vehicle_capacity'] ?? '';
    request.fields['pincodes'] = driverData['pincodes'] ?? '';
    request.fields['preferred_shift'] = driverData['preferred_shift'] ?? 'morning';
    request.fields['account_number'] = driverData['account_number'] ?? '';
    request.fields['sort_code'] = driverData['sort_code'] ?? '';
    request.fields['holder_name'] = driverData['holder_name'] ?? '';
    request.fields['upi_id'] = driverData['upi_id'] ?? '';
    
    if (kDebugMode) print('📦 Fields: ${request.fields.length}');
    
    // Add ALL required file uploads
    if (driverPhoto != null) {
      request.files.add(http.MultipartFile.fromBytes(
        'driver_photo',
        await driverPhoto.readAsBytes(),
        filename: driverPhoto.name,
      ));
    }
    
    if (licenseFront != null) {
      request.files.add(http.MultipartFile.fromBytes(
        'license_front',
        await licenseFront.readAsBytes(),
        filename: licenseFront.name,
      ));
    }
    
    if (licenseBack != null) {
      request.files.add(http.MultipartFile.fromBytes(
        'license_back',
        await licenseBack.readAsBytes(),
        filename: licenseBack.name,
      ));
    }
    
    if (govtIdPhoto != null) {
      request.files.add(http.MultipartFile.fromBytes(
        'govt_id_photo',
        await govtIdPhoto.readAsBytes(),
        filename: govtIdPhoto.name,
      ));
    }
    
    if (selfiePhoto != null) {
      request.files.add(http.MultipartFile.fromBytes(
        'selfie_photo',
        await selfiePhoto.readAsBytes(),
        filename: selfiePhoto.name,
      ));
    }
    
    if (vehiclePhoto != null) {
      request.files.add(http.MultipartFile.fromBytes(
        'vehicle_photo',
        await vehiclePhoto.readAsBytes(),
        filename: vehiclePhoto.name,
      ));
    }
    
    if (rcBookPhoto != null) {
      request.files.add(http.MultipartFile.fromBytes(
        'rc_book_photo',
        await rcBookPhoto.readAsBytes(),
        filename: rcBookPhoto.name,
      ));
    }
    
    if (pollutionCertPhoto != null) {
      request.files.add(http.MultipartFile.fromBytes(
        'pollution_certificate_photo',
        await pollutionCertPhoto.readAsBytes(),
        filename: pollutionCertPhoto.name,
      ));
    }
    
    if (kDebugMode) print('📦 Files: ${request.files.length}');
    
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    
    if (kDebugMode) print('📥 Status: ${response.statusCode}');
    if (kDebugMode) print('📥 Body: ${response.body}');
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      return {'success': true, 'message': data['message'] ?? 'Success', 'data': data};
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? error['message'] ?? 'Failed');
    }
  }

  Future<Map<String, dynamic>> verifyDriverRegistrationOTP({
    required String phoneNumber,
    required String otp,
  }) async {
    final url = Uri.parse('$_baseUrl/auth/verify-registration/driver');
    
    if (kDebugMode) print('📡 POST: $url');
    
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'phone_number': phoneNumber,
        'otp': otp,
      }),
    );
    
    if (kDebugMode) print('📥 Status: ${response.statusCode}');
    if (kDebugMode) print('📥 Body: ${response.body}');
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      return {'success': true, 'message': data['message'] ?? 'Verified', 'data': data};
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? error['message'] ?? 'Verification failed');
    }
  }

  void dispose() {
    _apiService.dispose();
    _authService.dispose();
  }
}
