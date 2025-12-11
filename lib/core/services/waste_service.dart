import 'api_service.dart';
import 'auth_service.dart';

class WasteService {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  Future<Map<String, dynamic>> submitWasteRequest({
    required double latitude,
    required double longitude,
    required String wasteType,
    required String description,
    String? imageUrl,
  }) async {
    final token = await _authService.getToken();
    if (token == null) throw ApiException('Not authenticated');

    return await _apiService.post('/waste/request', {
      'latitude': latitude,
      'longitude': longitude,
      'waste_type': wasteType,
      'description': description,
      'image_url': imageUrl,
    }, token: token);
  }

  Future<List<dynamic>> getMyComplaints({String? status}) async {
    final token = await _authService.getToken();
    if (token == null) throw ApiException('Not authenticated');

    final endpoint = status != null 
        ? '/waste/complaints?status=$status' 
        : '/waste/complaints';
    
    final response = await _apiService.get(endpoint, token: token);
    return response['complaints'] ?? [];
  }

  Future<Map<String, dynamic>> getComplaintDetails(String complaintId) async {
    final token = await _authService.getToken();
    if (token == null) throw ApiException('Not authenticated');

    return await _apiService.get('/waste/complaints/$complaintId', token: token);
  }

  Future<List<dynamic>> getNearbyBins({
    required double latitude,
    required double longitude,
    double radius = 5.0,
  }) async {
    final token = await _authService.getToken();
    
    final response = await _apiService.get(
      '/waste/bins/nearby?lat=$latitude&lng=$longitude&radius=$radius',
      token: token,
    );
    
    return response['bins'] ?? [];
  }

  Future<Map<String, dynamic>> trackWasteVehicle(String complaintId) async {
    final token = await _authService.getToken();
    if (token == null) throw ApiException('Not authenticated');

    return await _apiService.get('/waste/track/$complaintId', token: token);
  }

  Future<String> uploadImage(String filePath) async {
    final token = await _authService.getToken();
    if (token == null) throw ApiException('Not authenticated');

    final response = await _apiService.uploadImage('/waste/upload-image', filePath, token: token);
    return response['image_url'];
  }

  Future<List<dynamic>> getWasteCategories() async {
    final response = await _apiService.get('/waste/categories');
    return response['categories'] ?? [];
  }

  Future<Map<String, dynamic>> cancelComplaint(String complaintId) async {
    final token = await _authService.getToken();
    if (token == null) throw ApiException('Not authenticated');

    return await _apiService.post('/waste/complaints/$complaintId/cancel', {}, token: token);
  }

  Future<Map<String, dynamic>> rateService(String complaintId, int rating, String? feedback) async {
    final token = await _authService.getToken();
    if (token == null) throw ApiException('Not authenticated');

    return await _apiService.post('/waste/complaints/$complaintId/rate', {
      'rating': rating,
      'feedback': feedback,
    }, token: token);
  }

  void dispose() {
    _apiService.dispose();
    _authService.dispose();
  }
}
