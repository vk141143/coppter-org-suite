import '../models/estimate_data.dart';

class EstimateCalculator {
  static Future<EstimateResult> calculate(EstimateData data) async {
    await Future.delayed(const Duration(seconds: 2));

    final quantityFactor = _getQuantityFactor(data.quantity);
    final categoryMultiplier = _getCategoryMultiplier(data.category);
    final distanceCharge = (data.disposalDistance ?? 0) * 2.5;
    final vehicleCost = _getVehicleCost(data.vehicleType);
    final labourDifficulty = data.accessDifficulty.length * 15.0;
    final regionalSurcharge = data.regionSurcharge ? 25.0 : 0.0;
    final disposalFees = data.environmentalFees ? 30.0 : 0.0;

    final basePrice = quantityFactor * categoryMultiplier;
    final totalPrice = basePrice + distanceCharge + vehicleCost + labourDifficulty + regionalSurcharge + disposalFees;

    return EstimateResult(
      recommendedPrice: totalPrice,
      minPrice: totalPrice * 0.85,
      maxPrice: totalPrice * 1.15,
      breakdown: {
        'Quantity factor': quantityFactor * categoryMultiplier,
        'Distance charge': distanceCharge,
        'Vehicle cost': vehicleCost,
        'Labour difficulty': labourDifficulty,
        'Regional surcharge': regionalSurcharge,
        'Disposal fees': disposalFees,
      },
    );
  }

  static double _getQuantityFactor(String? quantity) {
    switch (quantity) {
      case 'Small Bag (1-2 bags)': return 50;
      case 'Medium Load (3-5 bags)': return 100;
      case 'Large Load (6+ bags)': return 150;
      case 'Van Load': return 250;
      case 'Truck Load': return 400;
      default: return 50;
    }
  }

  static double _getCategoryMultiplier(String? category) {
    switch (category) {
      case 'Household': return 1.0;
      case 'Garden': return 0.9;
      case 'C&D': return 1.3;
      case 'Furniture': return 1.2;
      case 'E-waste': return 1.5;
      case 'Metal': return 1.1;
      case 'Hazardous': return 2.0;
      case 'Mixed Waste': return 1.1;
      default: return 1.0;
    }
  }

  static double _getVehicleCost(String? vehicle) {
    switch (vehicle) {
      case 'Large Van': return 50;
      case 'Truck': return 100;
      default: return 50;
    }
  }
}
