import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

class AppConfig {
  // Backend API URLs - Update these for your deployment
  static const String _customerApiUrl = 'http://13.233.195.173:8000/api';
  static const String _technicianApiUrl = 'http://3.110.63.139:8001/api';
  
  /// Customer backend API (port 8000)
  static String get customerBaseUrl {
    if (kDebugMode) print('🌐 Customer API: $_customerApiUrl');
    return _customerApiUrl;
  }
  
  /// Technician/Admin backend API (port 8001)
  static String get technicianBaseUrl {
    if (kDebugMode) print('🌐 Technician API: $_technicianApiUrl');
    return _technicianApiUrl;
  }
  
  /// Default base URL (technician backend for backward compatibility)
  static String get baseUrl => _technicianApiUrl;
  
  /// Driver API (same as technician)
  static String get driverBaseUrl => _technicianApiUrl;
  
  /// Admin API (same as technician)
  static String get adminBaseUrl => _technicianApiUrl;
  
  static String get mapboxToken => dotenv.env['MAPBOX_ACCESS_TOKEN'] ?? 'sk.eyJ1IjoidmsxNDEiLCJhIjoiY21peWMwaThhMGMyaDNnc2NvZjZmM24ybSJ9.yM06tCnvvKFPBcodenv2Mw';
  static String get googleMapsApiKey => dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
  static int get apiTimeout => int.tryParse(dotenv.env['API_TIMEOUT'] ?? '30000') ?? 30000;
}

