class EstimateData {
  String? quantity;
  String? category;
  String? weightType;
  String? vehicleType;
  String? postcode;
  double? disposalDistance;
  List<String> accessDifficulty;
  String? urgency;
  bool regionSurcharge;
  bool environmentalFees;

  EstimateData({
    this.quantity,
    this.category,
    this.weightType,
    this.vehicleType,
    this.postcode,
    this.disposalDistance,
    this.accessDifficulty = const [],
    this.urgency,
    this.regionSurcharge = false,
    this.environmentalFees = false,
  });

  Map<String, dynamic> toJson() => {
    'quantity': quantity,
    'category': category,
    'weight_type': weightType,
    'vehicle_type': vehicleType,
    'distance_disposal': disposalDistance,
    'access_difficulty': accessDifficulty,
    'urgency': urgency,
    'postcode': postcode,
    'region_surcharge': regionSurcharge,
    'environmental_fees': environmentalFees,
  };
}

class EstimateResult {
  final double recommendedPrice;
  final double minPrice;
  final double maxPrice;
  final Map<String, double> breakdown;

  EstimateResult({
    required this.recommendedPrice,
    required this.minPrice,
    required this.maxPrice,
    required this.breakdown,
  });
}
