import 'package:flutter/material.dart';
import '../services/waste_service.dart';

class WasteProvider extends ChangeNotifier {
  final WasteService _wasteService = WasteService();
  
  bool _isLoading = false;
  String? _error;
  List<dynamic> _complaints = [];
  List<dynamic> _categories = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<dynamic> get complaints => _complaints;
  List<dynamic> get categories => _categories;

  Future<bool> submitRequest({
    required double latitude,
    required double longitude,
    required String wasteType,
    required String description,
    String? imageUrl,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _wasteService.submitWasteRequest(
        latitude: latitude,
        longitude: longitude,
        wasteType: wasteType,
        description: description,
        imageUrl: imageUrl,
      );
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

  Future<void> loadComplaints({String? status}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _complaints = await _wasteService.getMyComplaints(status: status);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCategories() async {
    try {
      _categories = await _wasteService.getWasteCategories();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<String?> uploadImage(String filePath) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final imageUrl = await _wasteService.uploadImage(filePath);
      _isLoading = false;
      notifyListeners();
      return imageUrl;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _wasteService.dispose();
    super.dispose();
  }
}
