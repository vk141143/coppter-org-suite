import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../utils/token_storage.dart';
import 'mock_auth_service.dart';
import 'api_helper.dart';

class CategoryService {

  Future<List<Map<String, dynamic>>> getCategories({bool forceCustomer = false, bool forceAdmin = false}) async {
    final role = await TokenStorage.getRoleWithFallback();
    
    if (kDebugMode) print('🔑 Current role: $role');
    
    // Determine endpoint
    String endpoint;
    if (forceAdmin) {
      endpoint = '/admin/categories/';
    } else if (forceCustomer || role == 'customer') {
      endpoint = '/categories/';
    } else if (role == 'admin') {
      endpoint = '/admin/categories/';
    } else {
      endpoint = '/categories/';
    }
    
    if (kDebugMode) print('📡 Fetching categories from: $endpoint');
    final response = await ApiHelper.get(endpoint);
    
    if (kDebugMode) {
      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');
    }
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      if (data is List) {
        if (kDebugMode) print('✅ Loaded ${data.length} categories');
        return List<Map<String, dynamic>>.from(data);
      }
      return [];
    } else if (response.statusCode == 401 || response.statusCode == 403) {
      if (kDebugMode) print('❌ ${response.statusCode} - Authentication failed for endpoint: $endpoint');
      throw Exception('Authentication failed. Please login again.');
    } else {
      final errorMsg = response.body.isNotEmpty ? response.body : 'Failed to get categories';
      if (kDebugMode) print('❌ Error: $errorMsg');
      throw Exception(errorMsg);
    }
  }

  Future<Map<String, dynamic>> createCategory({
    required String name,
    required String imageUrl,
  }) async {
    final response = await ApiHelper.post(
      '/admin/categories/',
      body: {
        'name': name,
        'image_url': imageUrl,
      },
    );
    
    if (kDebugMode) {
      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');
    }
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 401 || response.statusCode == 403) {
      if (kDebugMode) print('❌ ${response.statusCode} - Authentication failed');
      await TokenStorage.clearToken();
      await TokenStorage.saveUserRole('');
      throw Exception('Authentication failed. Please login again.');
    } else {
      final errorMsg = response.body.isNotEmpty ? response.body : 'Failed to create category';
      throw Exception(errorMsg);
    }
  }

  Future<Map<String, dynamic>> updateCategory({
    required int id,
    required String name,
    required String imageUrl,
    required bool isActive,
  }) async {
    final response = await ApiHelper.patch(
      '/admin/categories/$id/',
      body: {
        'name': name,
        'image_url': imageUrl,
        'is_active': isActive,
      },
    );
    
    if (kDebugMode) {
      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');
    }
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 401 || response.statusCode == 403) {
      if (kDebugMode) print('❌ ${response.statusCode} - Authentication failed');
      await TokenStorage.clearToken();
      await TokenStorage.saveUserRole('');
      throw Exception('Authentication failed. Please login again.');
    } else {
      final errorMsg = response.body.isNotEmpty ? response.body : 'Failed to update category';
      throw Exception(errorMsg);
    }
  }

  Future<void> deleteCategory(int id) async {
    final response = await ApiHelper.delete('/admin/categories/$id/');
    
    if (kDebugMode) {
      print('📥 Response status: ${response.statusCode}');
    }
    
    if (response.statusCode == 401 || response.statusCode == 403) {
      if (kDebugMode) print('❌ ${response.statusCode} - Authentication failed');
      await TokenStorage.clearToken();
      await TokenStorage.saveUserRole('');
      throw Exception('Authentication failed. Please login again.');
    } else if (response.statusCode < 200 || response.statusCode >= 300) {
      final errorMsg = response.body.isNotEmpty ? response.body : 'Failed to delete category';
      throw Exception(errorMsg);
    }
  }

  void dispose() {}
}
