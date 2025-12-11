import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../utils/secure_storage.dart';
import '../config/app_config.dart';

class CleanCategoryService {
  static String get _baseUrl => AppConfig.technicianBaseUrl;

  /// Get categories (admin only)
  Future<List<Map<String, dynamic>>> getCategories() async {
    final token = await SecureStorage.getToken();
    final role = await SecureStorage.getUserRole();
    
    if (token == null || token.isEmpty) {
      throw Exception('Not authenticated. Please login first.');
    }
    
    if (role != 'admin') {
      throw Exception('Admin access required. Current role: $role');
    }
    
    final url = Uri.parse('$_baseUrl/admin/categories/');
    
    if (kDebugMode) print('📡 GET $url');
    if (kDebugMode) print('🔑 Token: ${token.substring(0, 20)}...');
    if (kDebugMode) print('👤 Role: $role');
    
    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    
    if (kDebugMode) print('📥 Status: ${response.statusCode}');
    if (kDebugMode) print('📥 Body: ${response.body}');
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is List) {
        return List<Map<String, dynamic>>.from(data);
      }
      return [];
    } else if (response.statusCode == 403) {
      // Token invalid or wrong role
      await SecureStorage.clearAll();
      throw Exception('Authentication failed. Please login again.');
    } else {
      throw Exception('Failed to load categories');
    }
  }

  /// Create category (admin only)
  Future<Map<String, dynamic>> createCategory({
    required String name,
    required String imageUrl,
  }) async {
    final token = await SecureStorage.getToken();
    
    if (token == null || token.isEmpty) {
      throw Exception('Not authenticated');
    }
    
    final url = Uri.parse('$_baseUrl/admin/categories/');
    
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': name,
        'image_url': imageUrl,
      }),
    );
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 403) {
      await SecureStorage.clearAll();
      throw Exception('Authentication failed. Please login again.');
    } else {
      throw Exception('Failed to create category');
    }
  }

  /// Update category (admin only)
  Future<Map<String, dynamic>> updateCategory({
    required int id,
    required String name,
    required String imageUrl,
    required bool isActive,
  }) async {
    final token = await SecureStorage.getToken();
    
    if (token == null || token.isEmpty) {
      throw Exception('Not authenticated');
    }
    
    final url = Uri.parse('$_baseUrl/admin/categories/$id/');
    
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': name,
        'image_url': imageUrl,
        'is_active': isActive,
      }),
    );
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 403) {
      await SecureStorage.clearAll();
      throw Exception('Authentication failed. Please login again.');
    } else {
      throw Exception('Failed to update category');
    }
  }

  /// Delete category (admin only)
  Future<void> deleteCategory(int id) async {
    final token = await SecureStorage.getToken();
    
    if (token == null || token.isEmpty) {
      throw Exception('Not authenticated');
    }
    
    final url = Uri.parse('$_baseUrl/admin/categories/$id/');
    
    final response = await http.delete(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    
    if (response.statusCode == 403) {
      await SecureStorage.clearAll();
      throw Exception('Authentication failed. Please login again.');
    } else if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to delete category');
    }
  }
}
