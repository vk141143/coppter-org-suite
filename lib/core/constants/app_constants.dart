class AppConstants {
  static const String appName = 'LiftAway';
  static const String tagline = 'Fast. Simple. Reliable Waste Removal.';
  
  // Brand Colors
  static const int primaryColor = 0xFF0F5132; // Deep Forest Green
  static const int secondaryColor = 0xFFD1E7DD; // Sage Green
  static const int accentColor = 0xFFFAF7F2; // Soft Beige
  static const int textColor = 0xFF1F1F1F; // Dark Charcoal
  static const int alertColor = 0xFFFF6F00; // Orange
  
  // Waste Categories
  static const List<Map<String, dynamic>> wasteCategories = [
    {'name': 'Household', 'icon': '🏠', 'color': 0xFF0F5132},
    {'name': 'Recyclables', 'icon': '♻️', 'color': 0xFF198754},
    {'name': 'Garden', 'icon': '🌱', 'color': 0xFF28A745},
    {'name': 'C&D', 'icon': '🏗️', 'color': 0xFF6C757D},
    {'name': 'E-Waste', 'icon': '📱', 'color': 0xFFFF6F00},
    {'name': 'Furniture', 'icon': '🪑', 'color': 0xFF8B4513},
    {'name': 'Hazardous', 'icon': '⚠️', 'color': 0xFFDC3545},
    {'name': 'Metal', 'icon': '🔩', 'color': 0xFF495057},
    {'name': 'Appliances', 'icon': '📺', 'color': 0xFF17A2B8},
    {'name': 'Mixed Waste', 'icon': '🗑️', 'color': 0xFF6C757D},
  ];

  // Complaint Status
  static const List<String> complaintStatus = [
    'Pending',
    'Assigned',
    'In-Progress',
    'Completed'
  ];

  // Onboarding Data
  static const List<Map<String, String>> onboardingData = [
    {
      'title': 'Easy Waste Collection',
      'description': 'Schedule your waste pickup with just a few taps',
      'image': 'assets/images/onboarding1.png'
    },
    {
      'title': 'Track Your Requests',
      'description': 'Real-time tracking of your waste collection requests',
      'image': 'assets/images/onboarding2.png'
    },
    {
      'title': 'Eco-Friendly Solution',
      'description': 'Contributing to a cleaner and greener environment',
      'image': 'assets/images/onboarding3.png'
    },
  ];
}