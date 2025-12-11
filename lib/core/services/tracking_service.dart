import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'auth_service.dart';
import '../config/app_config.dart';

class TrackingService {
  final AuthService _authService = AuthService();
  static String get _baseUrl => AppConfig.technicianBaseUrl;
  Timer? _locationTimer;

  Future<void> updateLocation(String riderId, double lat, double lng) async {
    final url = Uri.parse('$_baseUrl/tracking/location/update?rider_id=$riderId&lat=$lat&lng=$lng');
    
    if (kDebugMode) {
      print('📡 POST Request: $url');
    }
    
    final response = await http.post(url, headers: {'Accept': 'application/json'});
    
    if (kDebugMode) {
      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');
    }
    
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to update location');
    }
  }

  void startLocationTracking(String riderId) {
    _locationTimer?.cancel();
    _locationTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      try {
        final position = await Geolocator.getCurrentPosition();
        await updateLocation(riderId, position.latitude, position.longitude);
      } catch (e) {
        if (kDebugMode) print('❌ Location update error: $e');
      }
    });
  }

  void stopLocationTracking() {
    _locationTimer?.cancel();
    _locationTimer = null;
  }

  Future<List<Map<String, dynamic>>> getNearbyRiders(double lat, double lng, {int radiusKm = 5}) async {
    final url = Uri.parse('$_baseUrl/tracking/nearby?lat=$lat&lng=$lng&radius_km=$radiusKm');
    
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
      throw Exception('Failed to get nearby riders');
    }
  }

  Future<Map<String, dynamic>> getRiderStatus(String riderId) async {
    final url = Uri.parse('$_baseUrl/tracking/rider/$riderId/status');
    
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
      throw Exception('Failed to get rider status');
    }
  }

  Future<void> updateRide(String rideId, Map<String, dynamic> data) async {
    final url = Uri.parse('$_baseUrl/tracking/ride/$rideId/update');
    
    if (kDebugMode) {
      print('📡 POST Request: $url');
    }
    
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: jsonEncode(data),
    );
    
    if (kDebugMode) {
      print('📥 Response status: ${response.statusCode}');
    }
    
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to update ride');
    }
  }

  Future<Map<String, dynamic>> getRide(String rideId) async {
    final url = Uri.parse('$_baseUrl/tracking/ride/$rideId');
    
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
      throw Exception('Failed to get ride data');
    }
  }

  Future<Map<String, dynamic>> getTrackingStats() async {
    final url = Uri.parse('$_baseUrl/tracking/stats');
    
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
      throw Exception('Failed to get tracking stats');
    }
  }

  void dispose() {
    stopLocationTracking();
  }
}
