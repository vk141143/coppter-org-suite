import 'package:flutter/material.dart';
import '../services/admin_service.dart';

class AdminProvider extends ChangeNotifier {
  final AdminService _adminService = AdminService();
  
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _stats;
  List<dynamic> _complaints = [];
  List<dynamic> _drivers = [];
  List<dynamic> _users = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get stats => _stats;
  List<dynamic> get complaints => _complaints;
  List<dynamic> get drivers => _drivers;
  List<dynamic> get users => _users;

  Future<void> loadDashboardStats() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _stats = await _adminService.getDashboardStats();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadComplaints({String? status, String? category}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _complaints = await _adminService.getAllComplaints(status: status, category: category);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> assignDriver(String complaintId, String driverId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _adminService.assignDriver(complaintId, driverId);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> loadDrivers({String? status}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _drivers = await _adminService.getAllDrivers(status: status);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> approveDriver(String driverId) async {
    try {
      await _adminService.approveDriver(driverId);
      await loadDrivers();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> loadUsers({String? searchQuery}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _users = await _adminService.getAllUsers(searchQuery: searchQuery);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _adminService.dispose();
    super.dispose();
  }
}
