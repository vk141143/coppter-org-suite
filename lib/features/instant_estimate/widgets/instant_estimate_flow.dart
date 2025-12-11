import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import '../models/estimate_data.dart';
import '../services/estimate_calculator.dart';
import '../../user/screens/track_complaint_screen.dart';
import '../../raise_complaint/widgets/submit_transition_animation.dart';
import '../../raise_complaint/screens/driver_selection_screen.dart';

class InstantEstimateFlow {
  static void show(BuildContext context) {
    if (kIsWeb) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const _EstimateDialog(),
      );
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => const _EstimateBottomSheet(),
      );
    }
  }
}

class _EstimateDialog extends StatefulWidget {
  const _EstimateDialog();

  @override
  State<_EstimateDialog> createState() => _EstimateDialogState();
}

class _EstimateDialogState extends State<_EstimateDialog> {
  final _formKey = GlobalKey<FormState>();
  late final EstimateData _data;
  
  @override
  void initState() {
    super.initState();
    _data = EstimateData(accessDifficulty: []);
  }
  final _postcodeController = TextEditingController(text: 'SW1A 1AA');
  final _distanceController = TextEditingController();
  bool _isCalculating = false;
  EstimateResult? _result;
  List<XFile> _images = [];
  String _selectedLocation = '';
  int _currentStep = 0; // 0: form, 1: result, 2: image, 3: location

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    if (_currentStep == 3) {
      return _buildLocationDialog(theme);
    }

    if (_currentStep == 2) {
      return _buildImageUploadDialog(theme);
    }

    if (_currentStep == 1) {
      return _buildResultDialog(theme);
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: EdgeInsets.symmetric(
        horizontal: size.width * 0.05,
        vertical: size.height * 0.05,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 700,
          maxHeight: size.height * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(theme),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildQuantityDropdown(theme),
                      const SizedBox(height: 12),
                      _buildCategoryDropdown(theme),
                      const SizedBox(height: 12),
                      _buildWeightTypeDropdown(theme),
                      const SizedBox(height: 12),
                      _buildPostcodeField(theme),
                      const SizedBox(height: 12),
                      _buildAccessDifficulty(theme),
                      const SizedBox(height: 12),
                      _buildVehicleType(theme),
                      const SizedBox(height: 12),
                      _buildUrgency(theme),
                      const SizedBox(height: 12),
                      _buildSurcharges(theme),
                    ],
                  ),
                ),
              ),
            ),
            _buildActions(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF0F5132), Color(0xFF198754)]),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Row(
        children: [
          const Icon(Icons.calculate, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          const Expanded(
            child: Text('Get Instant Estimate', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityDropdown(ThemeData theme) {
    return DropdownButtonFormField<String>(
      value: _data.quantity,
      decoration: InputDecoration(
        labelText: 'Quantity / Volume',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: const [
        DropdownMenuItem(value: 'Small Bag (1-2 bags)', child: Text('Small Bag (1-2 bags)')),
        DropdownMenuItem(value: 'Medium Load (3-5 bags)', child: Text('Medium Load (3-5 bags)')),
        DropdownMenuItem(value: 'Large Load (6+ bags)', child: Text('Large Load (6+ bags)')),
        DropdownMenuItem(value: 'Van Load', child: Text('Van Load')),
        DropdownMenuItem(value: 'Truck Load', child: Text('Truck Load')),
      ],
      onChanged: (v) => setState(() => _data.quantity = v),
      validator: (v) => v == null ? 'Required' : null,
    );
  }

  Widget _buildCategoryDropdown(ThemeData theme) {
    return DropdownButtonFormField<String>(
      value: _data.category,
      decoration: InputDecoration(
        labelText: 'Waste Category',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: const [
        DropdownMenuItem(value: 'Household', child: Text('Household')),
        DropdownMenuItem(value: 'Garden', child: Text('Garden')),
        DropdownMenuItem(value: 'C&D', child: Text('C&D')),
        DropdownMenuItem(value: 'Furniture', child: Text('Furniture')),
        DropdownMenuItem(value: 'E-waste', child: Text('E-waste')),
        DropdownMenuItem(value: 'Metal', child: Text('Metal')),
        DropdownMenuItem(value: 'Hazardous', child: Text('Hazardous')),
        DropdownMenuItem(value: 'Mixed Waste', child: Text('Mixed Waste')),
      ],
      onChanged: (v) {
        setState(() {
          _data.category = v;
          _data.environmentalFees = v == 'Hazardous' || v == 'E-waste';
        });
      },
      validator: (v) => v == null ? 'Required' : null,
    );
  }

  Widget _buildWeightTypeDropdown(ThemeData theme) {
    return DropdownButtonFormField<String>(
      value: _data.weightType,
      decoration: InputDecoration(
        labelText: 'Weight / Type',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: const [
        DropdownMenuItem(value: 'Dry Waste', child: Text('Dry Waste')),
        DropdownMenuItem(value: 'Wet Waste', child: Text('Wet Waste')),
        DropdownMenuItem(value: 'Mixed Waste', child: Text('Mixed Waste')),
      ],
      onChanged: (v) => setState(() => _data.weightType = v),
      validator: (v) => v == null ? 'Required' : null,
    );
  }

  Widget _buildPostcodeField(ThemeData theme) {
    return TextFormField(
      controller: _postcodeController,
      decoration: InputDecoration(
        labelText: 'Customer Location (Postcode)',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        suffixIcon: IconButton(
          icon: const Icon(Icons.my_location),
          onPressed: () => _postcodeController.text = 'SW1A 1AA',
        ),
      ),
      onChanged: (v) {
        _data.postcode = v;
        _data.regionSurcharge = v.toUpperCase().startsWith('SW') || v.toUpperCase().startsWith('W');
      },
      validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
    );
  }

  Widget _buildDistanceField(ThemeData theme) {
    return TextFormField(
      controller: _distanceController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: 'Disposal Centre Distance (KM)',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onChanged: (v) => _data.disposalDistance = double.tryParse(v),
      validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
    );
  }

  Widget _buildAccessDifficulty(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Access Difficulty', style: theme.textTheme.titleSmall),
        const SizedBox(height: 4),
        CheckboxListTile(
          title: const Text('Ground floor / Curbside'),
          value: _data.accessDifficulty.contains('Ground floor'),
          onChanged: (v) {
            setState(() {
              if (v!) {
                _data.accessDifficulty = [..._data.accessDifficulty, 'Ground floor'];
              } else {
                _data.accessDifficulty = _data.accessDifficulty.where((e) => e != 'Ground floor').toList();
              }
            });
          },
        ),
        CheckboxListTile(
          title: const Text('Stairs'),
          value: _data.accessDifficulty.contains('Stairs'),
          onChanged: (v) {
            setState(() {
              if (v!) {
                _data.accessDifficulty = [..._data.accessDifficulty, 'Stairs'];
              } else {
                _data.accessDifficulty = _data.accessDifficulty.where((e) => e != 'Stairs').toList();
              }
            });
          },
        ),
        CheckboxListTile(
          title: const Text('Narrow entrance'),
          value: _data.accessDifficulty.contains('Narrow entrance'),
          onChanged: (v) {
            setState(() {
              if (v!) {
                _data.accessDifficulty = [..._data.accessDifficulty, 'Narrow entrance'];
              } else {
                _data.accessDifficulty = _data.accessDifficulty.where((e) => e != 'Narrow entrance').toList();
              }
            });
          },
        ),
        CheckboxListTile(
          title: const Text('Requires dismantling'),
          value: _data.accessDifficulty.contains('Requires dismantling'),
          onChanged: (v) {
            setState(() {
              if (v!) {
                _data.accessDifficulty = [..._data.accessDifficulty, 'Requires dismantling'];
              } else {
                _data.accessDifficulty = _data.accessDifficulty.where((e) => e != 'Requires dismantling').toList();
              }
            });
          },
        ),
      ],
    );
  }

  Widget _buildVehicleType(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Vehicle Type Needed', style: theme.textTheme.titleSmall),
        const SizedBox(height: 4),
        RadioListTile<String>(
          title: const Text('Large Van'),
          value: 'Large Van',
          groupValue: _data.vehicleType,
          onChanged: (v) => setState(() => _data.vehicleType = v),
        ),
        RadioListTile<String>(
          title: const Text('Truck'),
          value: 'Truck',
          groupValue: _data.vehicleType,
          onChanged: (v) => setState(() => _data.vehicleType = v),
        ),
      ],
    );
  }

  Widget _buildUrgency(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Urgency / Time Preference', style: theme.textTheme.titleSmall),
        const SizedBox(height: 4),
        RadioListTile<String>(
          title: const Text('Immediate pickup'),
          value: 'Immediate',
          groupValue: _data.urgency,
          onChanged: (v) => setState(() => _data.urgency = v),
        ),
        RadioListTile<String>(
          title: const Text('Same-day'),
          value: 'Same-day',
          groupValue: _data.urgency,
          onChanged: (v) => setState(() => _data.urgency = v),
        ),
        RadioListTile<String>(
          title: const Text('Tomorrow'),
          value: 'Tomorrow',
          groupValue: _data.urgency,
          onChanged: (v) => setState(() => _data.urgency = v),
        ),
        RadioListTile<String>(
          title: const Text('Schedule a date/time'),
          value: 'Scheduled',
          groupValue: _data.urgency,
          onChanged: (v) => setState(() => _data.urgency = v),
        ),
      ],
    );
  }

  Widget _buildSurcharges(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Additional Charges', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Flexible(
                child: Text('Regional Surcharge: ${_data.regionSurcharge ? "Yes" : "No"}', overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.eco_outlined, size: 16, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Flexible(
                child: Text('Environmental Fees: ${_data.environmentalFees ? "Yes" : "No"}', overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActions(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: theme.colorScheme.outline.withOpacity(0.2))),
      ),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 48,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: const Text('Cancel'),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _isCalculating ? null : _calculate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F5132),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isCalculating
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : FittedBox(
                        fit: BoxFit.scaleDown,
                        child: const Text('Get Instant Estimate'),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultDialog(ThemeData theme) {
    final size = MediaQuery.of(context).size;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: EdgeInsets.symmetric(
        horizontal: size.width * 0.05,
        vertical: size.height * 0.05,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 500,
          maxHeight: size.height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Icon(Icons.check_circle, color: Color(0xFF0F5132), size: 48),
                    const SizedBox(height: 12),
                    const Text('AI Estimate Result', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Text('£${_result!.recommendedPrice.toStringAsFixed(2)}', style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Color(0xFF0F5132))),
                    const SizedBox(height: 8),
                    Text('Range: £${_result!.minPrice.toStringAsFixed(0)} - £${_result!.maxPrice.toStringAsFixed(0)}', style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6))),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _result!.breakdown.entries.map((e) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(child: Text(e.key, style: const TextStyle(fontSize: 13))),
                              Text('£${e.value.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                        )).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: theme.colorScheme.outline.withOpacity(0.2))),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: const Text('Cancel'),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _showPhotoUpload,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F5132),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: const Text('Accept & Continue'),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageUploadDialog(ThemeData theme) {
    final size = MediaQuery.of(context).size;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: EdgeInsets.symmetric(
        horizontal: size.width * 0.05,
        vertical: size.height * 0.05,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 450,
          maxHeight: size.height * 0.85,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.upload_file, color: Color(0xFF0F5132), size: 48),
              const SizedBox(height: 16),
              const Text('Upload Photos', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              InkWell(
                onTap: _pickImages,
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFF0F5132), width: 2, style: BorderStyle.solid),
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(0xFF0F5132).withOpacity(0.05),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cloud_upload, size: 48, color: const Color(0xFF0F5132)),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            _images.isEmpty ? 'Click to upload images' : '${_images.length} image(s) selected',
                            style: TextStyle(color: const Color(0xFF0F5132), fontWeight: FontWeight.w600),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Supports: JPG, PNG (Max 6 images)',
                            style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () => setState(() => _currentStep = 1),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: const Text('Back'),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _images.isEmpty ? null : () => setState(() => _currentStep = 3),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F5132),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: const Text('Next: Location'),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationDialog(ThemeData theme) {
    final size = MediaQuery.of(context).size;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: EdgeInsets.symmetric(
        horizontal: size.width * 0.05,
        vertical: size.height * 0.05,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 450,
          maxHeight: size.height * 0.85,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.location_on, color: Color(0xFF0F5132), size: 48),
              const SizedBox(height: 16),
              const Text('Select Location', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _postcodeController.text,
                decoration: InputDecoration(
                  labelText: 'Pickup Location',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  suffixIcon: const Icon(Icons.my_location),
                ),
                onChanged: (v) => _selectedLocation = v,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () => setState(() => _currentStep = 2),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: const Text('Back'),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _submitComplaint,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F5132),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: const Text('Submit Complaint'),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _calculate() async {
    if (!_formKey.currentState!.validate()) return;
    if (_data.vehicleType == null || _data.urgency == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all required fields')),
        );
      }
      return;
    }

    setState(() => _isCalculating = true);
    _data.disposalDistance = 5.0;
    final result = await EstimateCalculator.calculate(_data);
    if (mounted) {
      setState(() {
        _isCalculating = false;
        _result = result;
        _currentStep = 1;
      });
    }
  }

  void _showPhotoUpload() {
    setState(() {
      _currentStep = 2;
      _images = [];
    });
  }

  void _pickImages() async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage(imageQuality: 85);
    if (images.isNotEmpty && images.length <= 6) {
      setState(() => _images = images);
    }
  }

  void _submitComplaint() {
    final location = _selectedLocation.isEmpty ? _postcodeController.text : _selectedLocation;
    Navigator.pop(context);
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.transparent,
        pageBuilder: (context, animation, secondaryAnimation) {
          return SubmitTransitionAnimation(
            buttonColor: const Color(0xFF0F5132),
            onComplete: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => DriverSelectionScreen(
                    price: _result!.recommendedPrice,
                    location: location,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _postcodeController.dispose();
    _distanceController.dispose();
    super.dispose();
  }
}

class _EstimateBottomSheet extends StatelessWidget {
  const _EstimateBottomSheet();

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: const _EstimateDialog(),
      ),
    );
  }
}
