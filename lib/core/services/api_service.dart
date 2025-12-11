import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';

class ApiService {
  final http.Client client = http.Client();
  
  Map<String, String> _getHeaders({String? token}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<dynamic> get(String endpoint, {String? token}) async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl}$endpoint');
      final response = await client.get(
        url,
        headers: _getHeaders(token: token),
      ).timeout(Duration(milliseconds: AppConfig.apiTimeout));

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> body, {String? token}) async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl}$endpoint');
      if (kDebugMode) {
        print('📡 POST Request: $url');
        print('📦 Request Body: ${jsonEncode(body)}');
      }
      final response = await client.post(
        url,
        headers: _getHeaders(token: token),
        body: jsonEncode(body),
      ).timeout(Duration(milliseconds: AppConfig.apiTimeout));

      return _handleResponse(response);
    } catch (e) {
      if (kDebugMode) {
        print('❌ API Error: $e');
      }
      throw _handleError(e);
    }
  }

  Future<dynamic> put(String endpoint, Map<String, dynamic> body, {String? token}) async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl}$endpoint');
      final response = await client.put(
        url,
        headers: _getHeaders(token: token),
        body: jsonEncode(body),
      ).timeout(Duration(milliseconds: AppConfig.apiTimeout));

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<dynamic> patch(String endpoint, Map<String, dynamic> body, {String? token}) async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl}$endpoint');
      final response = await client.patch(
        url,
        headers: _getHeaders(token: token),
        body: jsonEncode(body),
      ).timeout(Duration(milliseconds: AppConfig.apiTimeout));

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<dynamic> delete(String endpoint, {String? token}) async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl}$endpoint');
      final response = await client.delete(
        url,
        headers: _getHeaders(token: token),
      ).timeout(Duration(milliseconds: AppConfig.apiTimeout));

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<dynamic> postMultipart(String endpoint, Map<String, dynamic> data, {String? token}) async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl}$endpoint');
      if (kDebugMode) {
        print('📡 POST Multipart Request: $url');
      }
      final request = http.MultipartRequest('POST', url);
      
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      
      data.forEach((key, value) {
        if (value != null && value.toString().isNotEmpty) {
          request.fields[key] = value.toString();
        }
      });
      
      if (kDebugMode) {
        print('📦 Form Fields: ${request.fields}');
      }
      
      final streamedResponse = await request.send().timeout(
        Duration(milliseconds: AppConfig.apiTimeout),
      );
      final response = await http.Response.fromStream(streamedResponse);
      
      if (kDebugMode) {
        print('✅ Response Status: ${response.statusCode}');
        print('📥 Response Body: ${response.body}');
      }
      
      return _handleResponse(response);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Multipart Error: $e');
      }
      throw _handleError(e);
    }
  }

  Future<dynamic> uploadImage(String endpoint, String filePath, {String? token}) async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl}$endpoint');
      final request = http.MultipartRequest('POST', url);
      
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      
      request.files.add(await http.MultipartFile.fromPath('file', filePath));
      
      final streamedResponse = await request.send().timeout(
        Duration(milliseconds: AppConfig.apiTimeout),
      );
      final response = await http.Response.fromStream(streamedResponse);
      
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      throw ApiException('Unauthorized. Please login again.');
    } else if (response.statusCode == 404) {
      throw ApiException('Resource not found.');
    } else if (response.statusCode >= 500) {
      throw ApiException('Server error. Please try again later.');
    } else {
      try {
        final error = jsonDecode(response.body);
        if (kDebugMode) {
          print('❌ API Error Response: ${response.body}');
        }
        final message = error['message'] ?? error['detail'] ?? 'An error occurred';
        final validationErrors = error['validation_errors'];
        if (validationErrors != null) {
          throw ApiException('$message\nValidation: $validationErrors');
        }
        throw ApiException(message);
      } catch (e) {
        if (e is ApiException) rethrow;
        throw ApiException('Error: ${response.body}');
      }
    }
  }

  String _handleError(dynamic error) {
    if (error is ApiException) {
      return error.message;
    }
    return 'Network error. Please check your connection.';
  }

  void dispose() {
    client.close();
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  
  @override
  String toString() => message;
}
