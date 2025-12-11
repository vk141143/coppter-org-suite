import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MobilePricingEstimator extends StatefulWidget {
  final String category;
  final String location;
  final Function(Map<String, dynamic>) onPriceAccepted;

  const MobilePricingEstimator({
    super.key,
    required this.category,
    required this.location,
    required this.onPriceAccepted,
  });

  @override
  State<MobilePricingEstimator> createState() => _MobilePricingEstimatorState();
}

class _MobilePricingEstimatorState extends State<MobilePricingEstimator> {
  final _quantityController = TextEditingController();
  final _cityController = TextEditingController();
  final _zoneController = TextEditingController();
  final _distanceController = TextEditingController(text: '3');
  
  String _urgency = 'Standard';
  String _vehicleSize = 'Auto';
  String _floorInfo = 'Ground Floor';
  bool _isLoading = false;
  Map<String, dynamic>? _priceEstimate;

  void _generateMockEstimate(Map<String, dynamic> payload) {
    // Base prices by category
    final basePrices = {
      'Household Waste': 150.0,
      'Recyclables': 100.0,
      'Garden Waste': 120.0,
      'E-Waste': 200.0,
      'Construction Debris': 300.0,
      'Hazardous Waste': 400.0,
      'Bulk Items': 250.0,
      'Medical Waste': 350.0,
    };

    double basePrice = basePrices[payload['category']] ?? 150.0;
    double distance = payload['distance_km'] ?? 3.0;
    
    // Calculate multipliers
    double urgencyMultiplier = payload['urgency'] == 'Emergency' ? 1.5 : (payload['urgency'] == 'Fast' ? 1.3 : 1.0);
    double vehicleMultiplier = payload['vehicle_size'] == 'Mini Truck' ? 1.4 : 1.0;
    double floorMultiplier = 1.0;
    
    if (payload['floor_info'].contains('3+')) {
      floorMultiplier = 1.3;
    } else if (payload['floor_info'].contains('2nd')) {
      floorMultiplier = 1.2;
    } else if (payload['floor_info'].contains('1st')) {
      floorMultiplier = 1.1;
    }

    double distanceCost = distance * 15;
    double laborCost = basePrice * 0.3;
    double disposalCost = basePrice * 0.4;
    double urgencyCost = basePrice * (urgencyMultiplier - 1);
    double vehicleCost = basePrice * (vehicleMultiplier - 1);
    double floorCost = basePrice * (floorMultiplier - 1);

    double totalBase = basePrice + distanceCost + laborCost + disposalCost + urgencyCost + vehicleCost + floorCost;
    
    setState(() {
      _priceEstimate = {
        'estimated_price_min': (totalBase * 0.85).round(),
        'recommended_price': totalBase.round(),
        'estimated_price_max': (totalBase * 1.15).round(),
        'breakdown': {
          'base_fee': basePrice.round(),
          'distance_charge': distanceCost.round(),
          'labor_cost': laborCost.round(),
          'disposal_fee': disposalCost.round(),
          if (urgencyCost > 0) 'urgency_charge': urgencyCost.round(),
          if (vehicleCost > 0) 'vehicle_charge': vehicleCost.round(),
          if (floorCost > 0) 'floor_charge': floorCost.round(),
        },
        'assumptions': [
          'Prices are estimates and may vary based on actual conditions',
          'Distance calculated from pickup to disposal site',
          'Labor cost includes loading and unloading',
          'Final price will be confirmed by the driver',
        ],
      };
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _cityController.text = widget.location;
  }

  Future<void> _estimatePrice() async {
    setState(() {
      _isLoading = true;
      _priceEstimate = null;
    });

    final payload = {
      'category': widget.category,
      'quantity': _quantityController.text.isEmpty ? 'Not specified' : _quantityController.text,
      'location': widget.location,
      'distance_km': double.tryParse(_distanceController.text) ?? 3.0,
      'urgency': _urgency,
      'floor_info': _floorInfo,
      'city': _cityController.text.isEmpty ? 'Not specified' : _cityController.text,
      'zone': _zoneController.text.isEmpty ? 'Not specified' : _zoneController.text,
      'vehicle_size': _vehicleSize,
    };

    // Use mock estimation directly
    _generateMockEstimate(payload);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Price Estimator'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1A73E8), Color(0xFF4285F4)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome, color: Colors.white, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'AI-Powered Pricing',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Category: ${widget.category}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            _buildTextField('Quantity (optional)', _quantityController, 'e.g., 2 bags, 50kg'),
            const SizedBox(height: 16),
            _buildTextField('Distance (km)', _distanceController, '3'),
            const SizedBox(height: 16),
            _buildTextField('City', _cityController, 'e.g., Mumbai'),
            const SizedBox(height: 16),
            _buildTextField('Zone', _zoneController, 'e.g., South Mumbai'),
            const SizedBox(height: 16),
            
            _buildDropdown('Urgency', _urgency, ['Standard', 'Fast', 'Emergency'], (val) {
              setState(() => _urgency = val!);
            }),
            const SizedBox(height: 16),
            
            _buildDropdown('Vehicle Size', _vehicleSize, ['Auto', 'Mini Truck'], (val) {
              setState(() => _vehicleSize = val!);
            }),
            const SizedBox(height: 16),
            
            _buildDropdown('Floor/Stairs', _floorInfo, ['Ground Floor', '1st Floor', '2nd Floor', '3+ Floors', 'Elevator Available'], (val) {
              setState(() => _floorInfo = val!);
            }),
            const SizedBox(height: 24),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _estimatePrice,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.calculate),
                label: Text(_isLoading ? 'Calculating...' : 'Estimate Price'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            
            if (_priceEstimate != null) ...[ 
              const SizedBox(height: 24),
              _buildPriceResult(theme),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: const SizedBox(),
            items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceResult(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Estimated Price',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildPriceCard('Min', '£${_priceEstimate!['estimated_price_min']}', Colors.orange),
          const SizedBox(height: 12),
          _buildPriceCard('Recommended', '£${_priceEstimate!['recommended_price']}', Colors.green),
          const SizedBox(height: 12),
          _buildPriceCard('Max', '£${_priceEstimate!['estimated_price_max']}', Colors.blue),
          
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 16),
          
          Text(
            'Breakdown',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          
          ...(_priceEstimate!['breakdown'] as Map<String, dynamic>).entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    entry.key.replaceAll('_', ' ').toUpperCase(),
                    style: const TextStyle(fontSize: 13),
                  ),
                  Text(
                    '£${entry.value}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          
          if (_priceEstimate!['assumptions'] != null) ...[ 
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              'Assumptions',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            ...(_priceEstimate!['assumptions'] as List).map((assumption) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• '),
                    Expanded(child: Text(assumption, style: const TextStyle(fontSize: 12))),
                  ],
                ),
              );
            }).toList(),
          ],
          
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.onPriceAccepted(_priceEstimate!);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Accept & Continue'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceCard(String label, String price, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            price,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _cityController.dispose();
    _zoneController.dispose();
    _distanceController.dispose();
    super.dispose();
  }
}
