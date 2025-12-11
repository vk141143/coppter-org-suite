import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class MapService {
  static const String _baseUrl = 'http://13.232.241.195:8000/api';
  
  Future<String> getMapboxToken() async {
    final url = Uri.parse('$_baseUrl/mapbox-token');
    
    if (kDebugMode) print('📡 GET Request: $url');
    
    final response = await http.get(
      url,
      headers: {'Accept': 'application/json'},
    );
    
    if (kDebugMode) print('📥 Response status: ${response.statusCode}');
    if (kDebugMode) print('📥 Response body: ${response.body}');
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      final token = data['mapbox_token'] as String;
      if (kDebugMode) print('✅ Mapbox token retrieved: ${token.substring(0, 20)}...');
      return token;
    } else {
      throw Exception('Failed to fetch Mapbox token');
    }
  }
}
