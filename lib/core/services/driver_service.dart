import 'api_service.dart';
import 'auth_service.dart';

class DriverService {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  Future<List<dynamic>> getAssignedJobs() async {
    final token = await _authService.getToken();
    if (token == null) throw ApiException('Not authenticated');

    final response = await _apiService.get('/driver/jobs', token: token);
    return response['jobs'] ?? [];
  }

  Future<Map<String, dynamic>> acceptJob(String jobId) async {
    final token = await _authService.getToken();
    if (token == null) throw ApiException('Not authenticated');

    return await _apiService.post('/driver/jobs/$jobId/accept', {}, token: token);
  }

  Future<Map<String, dynamic>> rejectJob(String jobId, String reason) async {
    final token = await _authService.getToken();
    if (token == null) throw ApiException('Not authenticated');

    return await _apiService.post('/driver/jobs/$jobId/reject', {
      'reason': reason,
    }, token: token);
  }

  Future<Map<String, dynamic>> startJob(String jobId) async {
    final token = await _authService.getToken();
    if (token == null) throw ApiException('Not authenticated');

    return await _apiService.post('/driver/jobs/$jobId/start', {}, token: token);
  }

  Future<Map<String, dynamic>> completeJob(String jobId, String? proofImageUrl) async {
    final token = await _authService.getToken();
    if (token == null) throw ApiException('Not authenticated');

    return await _apiService.post('/driver/jobs/$jobId/complete', {
      'proof_image_url': proofImageUrl,
    }, token: token);
  }

  Future<Map<String, dynamic>> updateLocation(double latitude, double longitude) async {
    final token = await _authService.getToken();
    if (token == null) throw ApiException('Not authenticated');

    return await _apiService.post('/driver/location', {
      'latitude': latitude,
      'longitude': longitude,
    }, token: token);
  }

  Future<Map<String, dynamic>> toggleOnlineStatus(bool isOnline) async {
    final token = await _authService.getToken();
    if (token == null) throw ApiException('Not authenticated');

    return await _apiService.post('/driver/status', {
      'is_online': isOnline,
    }, token: token);
  }

  Future<Map<String, dynamic>> getEarnings({String? period}) async {
    final token = await _authService.getToken();
    if (token == null) throw ApiException('Not authenticated');

    final endpoint = period != null 
        ? '/driver/earnings?period=$period' 
        : '/driver/earnings';
    
    return await _apiService.get(endpoint, token: token);
  }

  Future<List<dynamic>> getJobHistory() async {
    final token = await _authService.getToken();
    if (token == null) throw ApiException('Not authenticated');

    final response = await _apiService.get('/driver/jobs/history', token: token);
    return response['jobs'] ?? [];
  }

  void dispose() {
    _apiService.dispose();
    _authService.dispose();
  }
}
