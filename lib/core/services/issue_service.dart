import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'auth_service.dart';
import '../config/app_config.dart';

class IssueService {
  final AuthService _authService = AuthService();
  static String get _baseUrl => AppConfig.customerBaseUrl;

  Future<Map<String, dynamic>> createIssue({
    required int categoryId,
    required String description,
    required String pickupLocation,
    required List<String> images,
    required double amount,
  }) async {
    final token = await _authService.getToken();
    final url = Uri.parse('$_baseUrl/customer/issue');
    
    if (kDebugMode) {
      print('📡 POST Request: $url');
      print('🔑 Token: $token');
      print('📦 Body: categoryId=$categoryId, desc=$description, location=$pickupLocation, amount=$amount');
    }
    
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'category_id': categoryId,
        'description': description,
        'pickup_location': pickupLocation,
        'images': images,
        'amount': amount,
      }),
    );
    
    if (kDebugMode) {
      print('📤 Request Headers: Authorization: Bearer ${token?.substring(0, 20)}...');
      print('✅ Response Status: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');
    }
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 401 || response.statusCode == 403) {
      throw Exception('Session expired. Please login again');
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? error['error']?['error_message'] ?? 'Failed to create issue');
    }
  }

  Future<List<Map<String, dynamic>>> getIssues() async {
    final token = await _authService.getToken();
    final url = Uri.parse('$_baseUrl/issues/my-issues');
    
    if (kDebugMode) {
      print('📡 GET Request: $url');
      print('🔑 Token: ${token?.substring(0, 20)}...');
    }
    
    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    
    if (kDebugMode) {
      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');
    }
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else if (response.statusCode == 403) {
      throw Exception('Please login first to view service history');
    } else {
      throw Exception('Failed to load service history');
    }
  }

  void dispose() {}
}
