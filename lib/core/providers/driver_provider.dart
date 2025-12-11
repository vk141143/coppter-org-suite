import 'package:flutter/material.dart';
import '../services/driver_service.dart';

class DriverProvider extends ChangeNotifier {
  final DriverService _driverService = DriverService();
  
  bool _isLoading = false;
  String? _error;
  List<dynamic> _jobs = [];
  Map<String, dynamic>? _earnings;
  bool _isOnline = false;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<dynamic> get jobs => _jobs;
  Map<String, dynamic>? get earnings => _earnings;
  bool get isOnline => _isOnline;

  Future<void> loadJobs() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _jobs = await _driverService.getAssignedJobs();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> acceptJob(String jobId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _driverService.acceptJob(jobId);
      await loadJobs();
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

  Future<bool> completeJob(String jobId, String? proofImageUrl) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _driverService.completeJob(jobId, proofImageUrl);
      await loadJobs();
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

  Future<void> toggleOnlineStatus() async {
    try {
      _isOnline = !_isOnline;
      await _driverService.toggleOnlineStatus(_isOnline);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isOnline = !_isOnline;
      notifyListeners();
    }
  }

  Future<void> loadEarnings({String? period}) async {
    try {
      _earnings = await _driverService.getEarnings(period: period);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _driverService.dispose();
    super.dispose();
  }
}
