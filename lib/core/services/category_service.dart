import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../utils/token_storage.dart';
import 'mock_auth_service.dart';
import '../config/app_config.dart';

class CategoryService {
  static String get _baseUrl => AppConfig.technicianBaseUrl;

  Future<List<Map<String, dynamic>>> getCategories() async {
    final token = await TokenStorage.getToken();
    
    // If no token, return mock data immediately
    if (token == null || token.isEmpty) {
      if (kDebugMode) print('⚠️ No token found - using mock data');
      if (MockAuthService.isMockEnabled) {
        return await MockAuthService.mockGetCategories();
      }
      throw Exception('Please login first');
    }
    
    final url = Uri.parse('$_baseUrl/admin/categories/');
    
    if (kDebugMode) {
      print('📡 GET Request: $url');
      print('🔑 Token: ${token.substring(0, token.length > 20 ? 20 : token.length)}... (length: ${token.length})');
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
      final data = jsonDecode(response.body);
      if (data is List) {
        return List<Map<String, dynamic>>.from(data);
      }
      return [];
    } else if (response.statusCode == 403) {
      if (kDebugMode) print('❌ 403 Forbidden - Token invalid or expired');
      
      // Use mock for development
      if (MockAuthService.isMockEnabled && token != null && token.startsWith('mock_')) {
        if (kDebugMode) print('🎭 Using mock categories data');
        return await MockAuthService.mockGetCategories();
      }
      
      await TokenStorage.clearToken();
      throw Exception('Authentication failed. Please login again.');
    } else {
      throw Exception('Failed to get categories');
    }
  }

  Future<Map<String, dynamic>> createCategory({
    required String name,
    required String imageUrl,
  }) async {
    final token = await TokenStorage.getToken();
    final url = Uri.parse('$_baseUrl/admin/categories/');
    
    if (kDebugMode) print('📡 POST Request: $url');
    
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': name,
        'image_url': imageUrl,
      }),
    );
    
    if (kDebugMode) {
      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');
    }
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 403) {
      if (kDebugMode) print('❌ 403 Forbidden - Token invalid or expired');
      await TokenStorage.clearToken();
      throw Exception('Authentication failed. Please login again.');
    } else {
      throw Exception('Failed to create category');
    }
  }

  Future<Map<String, dynamic>> updateCategory({
    required int id,
    required String name,
    required String imageUrl,
    required bool isActive,
  }) async {
    final token = await TokenStorage.getToken();
    final url = Uri.parse('$_baseUrl/admin/categories/$id/');
    
    if (kDebugMode) print('📡 PUT Request: $url');
    
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': name,
        'image_url': imageUrl,
        'is_active': isActive,
      }),
    );
    
    if (kDebugMode) {
      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');
    }
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 403) {
      if (kDebugMode) print('❌ 403 Forbidden - Token invalid or expired');
      await TokenStorage.clearToken();
      throw Exception('Authentication failed. Please login again.');
    } else {
      throw Exception('Failed to update category');
    }
  }

  Future<void> deleteCategory(int id) async {
    final token = await TokenStorage.getToken();
    final url = Uri.parse('$_baseUrl/admin/categories/$id/');
    
    if (kDebugMode) print('📡 DELETE Request: $url');
    
    final response = await http.delete(
      url,
      headers: {
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    
    if (kDebugMode) {
      print('📥 Response status: ${response.statusCode}');
    }
    
    if (response.statusCode == 403) {
      if (kDebugMode) print('❌ 403 Forbidden - Token invalid or expired');
      await TokenStorage.clearToken();
      throw Exception('Authentication failed. Please login again.');
    } else if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to delete category');
    }
  }

  void dispose() {}
}
