import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';

class ChatService {
  static String get _baseUrl => AppConfig.technicianBaseUrl;

  Future<void> sendMessage({
    required int rideId,
    required int senderId,
    required String message,
  }) async {
    final url = Uri.parse('$_baseUrl/chat/send');
    
    if (kDebugMode) {
      print('📡 POST Request: $url');
    }
    
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: jsonEncode({
        'ride_id': rideId,
        'sender_id': senderId,
        'message': message,
      }),
    );
    
    if (kDebugMode) {
      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');
    }
    
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to send message');
    }
  }

  Future<List<Map<String, dynamic>>> getChatHistory(int rideId, {int limit = 50}) async {
    final url = Uri.parse('$_baseUrl/chat/ride/$rideId/history?limit=$limit');
    
    if (kDebugMode) {
      print('📡 GET Request: $url');
    }
    
    final response = await http.get(
      url,
      headers: {'Accept': 'application/json'},
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
    } else {
      throw Exception('Failed to get chat history');
    }
  }

  Future<Map<String, dynamic>> getChatStats(int rideId) async {
    final url = Uri.parse('$_baseUrl/chat/ride/$rideId/stats');
    
    if (kDebugMode) {
      print('📡 GET Request: $url');
    }
    
    final response = await http.get(
      url,
      headers: {'Accept': 'application/json'},
    );
    
    if (kDebugMode) {
      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');
    }
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get chat stats');
    }
  }

  void dispose() {}
}
