import 'api_service.dart';
import 'auth_service.dart';

class AdminService {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  Future<Map<String, dynamic>> getDashboardStats() async {
    final token = await _authService.getToken();
    if (token == null) throw ApiException('Not authenticated');

    return await _apiService.get('/admin/dashboard/stats', token: token);
  }

  Future<List<dynamic>> getAllComplaints({String? status, String? category}) async {
    final token = await _authService.getToken();
    if (token == null) throw ApiException('Not authenticated');

    String endpoint = '/admin/complaints?';
    if (status != null) endpoint += 'status=$status&';
    if (category != null) endpoint += 'category=$category&';
    
    final response = await _apiService.get(endpoint, token: token);
    return response['complaints'] ?? [];
  }

  Future<Map<String, dynamic>> assignDriver(String complaintId, String driverId) async {
    final token = await _authService.getToken();
    if (token == null) throw ApiException('Not authenticated');

    return await _apiService.post('/admin/complaints/$complaintId/assign', {
      'driver_id': driverId,
    }, token: token);
  }

  Future<Map<String, dynamic>> updateComplaintStatus(String complaintId, String status) async {
    final token = await _authService.getToken();
    if (token == null) throw ApiException('Not authenticated');

    return await _apiService.put('/admin/complaints/$complaintId/status', {
      'status': status,
    }, token: token);
  }

  Future<List<dynamic>> getAllDrivers({String? status}) async {
    final token = await _authService.getToken();
    if (token == null) throw ApiException('Not authenticated');

    final endpoint = status != null 
        ? '/admin/drivers?status=$status' 
        : '/admin/drivers';
    
    final response = await _apiService.get(endpoint, token: token);
    return response['drivers'] ?? [];
  }

  Future<Map<String, dynamic>> approveDriver(String driverId) async {
    final token = await _authService.getToken();
    if (token == null) throw ApiException('Not authenticated');

    return await _apiService.post('/admin/drivers/$driverId/approve', {}, token: token);
  }

  Future<Map<String, dynamic>> rejectDriver(String driverId, String reason) async {
    final token = await _authService.getToken();
    if (token == null) throw ApiException('Not authenticated');

    return await _apiService.post('/admin/drivers/$driverId/reject', {
      'reason': reason,
    }, token: token);
  }

  Future<List<dynamic>> getAllUsers({String? searchQuery}) async {
    final token = await _authService.getToken();
    if (token == null) throw ApiException('Not authenticated');

    final endpoint = searchQuery != null 
        ? '/admin/users?search=$searchQuery' 
        : '/admin/users';
    
    final response = await _apiService.get(endpoint, token: token);
    return response['users'] ?? [];
  }

  Future<Map<String, dynamic>> updateUserStatus(String userId, String status) async {
    final token = await _authService.getToken();
    if (token == null) throw ApiException('Not authenticated');

    return await _apiService.put('/admin/users/$userId/status', {
      'status': status,
    }, token: token);
  }

  Future<Map<String, dynamic>> getAnalytics({String? period}) async {
    final token = await _authService.getToken();
    if (token == null) throw ApiException('Not authenticated');

    final endpoint = period != null 
        ? '/admin/analytics?period=$period' 
        : '/admin/analytics';
    
    return await _apiService.get(endpoint, token: token);
  }

  void dispose() {
    _apiService.dispose();
    _authService.dispose();
  }
}
