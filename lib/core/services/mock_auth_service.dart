import 'package:flutter/foundation.dart';
import '../utils/token_storage.dart';

/// Mock authentication service for development when backend is not ready
/// DO NOT USE IN PRODUCTION
class MockAuthService {
  static const bool _enableMock = false; // Mock disabled - using real backend
  
  static Future<Map<String, dynamic>> mockAdminLogin(String phone) async {
    if (!_enableMock) return {};
    
    if (kDebugMode) print('🎭 MOCK: Admin login for $phone');
    
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));
    
    return {
      'success': true,
      'message': 'Mock OTP sent (use any 6 digits)',
    };
  }
  
  static Future<Map<String, dynamic>> mockAdminVerifyOTP(String phone, String otp) async {
    if (!_enableMock) return {};
    
    if (kDebugMode) print('🎭 MOCK: Verifying OTP for admin');
    
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Generate mock JWT token
    final mockToken = 'mock_admin_token_${DateTime.now().millisecondsSinceEpoch}';
    
    // Save token
    await TokenStorage.saveToken(mockToken);
    await TokenStorage.saveUserRole('admin');
    
    if (kDebugMode) print('🎭 MOCK: Token saved successfully');
    
    // Return unified response structure
    return {
      'success': true,
      'message': 'Login successful',
      'token': mockToken,
      'role': 'admin',
      'user': {
        'id': '1',
        'full_name': 'Admin User',
        'email': 'admin@liftaway.com',
        'phone_number': phone,
        'gender': 'male',
        'address': 'Bangalore',
        'profile_image': null,
        'is_verified': true,
        'is_active': true,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        'admin_level': 'super_admin',
      },
    };
  }
  
  static Future<List<Map<String, dynamic>>> mockGetCategories() async {
    if (!_enableMock) return [];
    
    if (kDebugMode) print('🎭 MOCK: Fetching categories');
    
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    return [
      {
        'id': 1,
        'name': 'Household Waste',
        'image_url': 'https://via.placeholder.com/150',
        'is_active': true,
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'id': 2,
        'name': 'Recyclable Waste',
        'image_url': 'https://via.placeholder.com/150',
        'is_active': true,
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'id': 3,
        'name': 'Garden Waste',
        'image_url': 'https://via.placeholder.com/150',
        'is_active': true,
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'id': 4,
        'name': 'Electronic Waste',
        'image_url': 'https://via.placeholder.com/150',
        'is_active': false,
        'created_at': DateTime.now().toIso8601String(),
      },
    ];
  }
  
  static bool get isMockEnabled => _enableMock;
}
