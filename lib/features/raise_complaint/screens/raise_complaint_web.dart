import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import '../../../shared/widgets/custom_button.dart';
import '../widgets/web_drag_drop_uploader.dart';
import '../widgets/web_category_selector.dart';
import '../widgets/web_summary_panel.dart';
import '../widgets/web_location_map.dart';
import '../widgets/web_pricing_estimator.dart';
import '../widgets/web_assigned_driver_panel.dart';
import '../widgets/web_driver_chat_panel.dart';
import '../widgets/submit_transition_animation.dart';
import 'driver_selection_screen.dart';
import '../../../core/services/issue_service.dart';
import '../../../core/constants/app_constants.dart';

class RaiseComplaintWeb extends StatefulWidget {
  final XFile? image;
  
  const RaiseComplaintWeb({super.key, this.image});

  @override
  State<RaiseComplaintWeb> createState() => _RaiseComplaintWebState();
}

class _RaiseComplaintWebState extends State<RaiseComplaintWeb> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  
  String? _selectedCategory;
  List<XFile> _selectedImages = [];
  bool _isLoading = false;
  bool _autoSaved = false;
  Timer? _autoSaveTimer;
  Map<String, dynamic>? _acceptedPrice;
  bool _showPricingEstimator = false;
  bool _isComplaintSubmitted = false;
  bool _showChatPanel = false;
  double _negotiatedPrice = 0;
  final IssueService _issueService = IssueService();

  @override
  void initState() {
    super.initState();
    if (widget.image != null) {
      _selectedImages.add(widget.image!);
    }
    _startAutoSave();
    _descriptionController.addListener(_onFormChanged);
    _locationController.addListener(_onFormChanged);
  }

  void _startAutoSave() {
    _autoSaveTimer = Timer.periodic(const Duration(seconds: 10), (_) => _autoSaveDraft());
  }

  void _onFormChanged() {
    setState(() => _autoSaved = false);
  }

  void _autoSaveDraft() {
    if (_selectedCategory != null || _descriptionController.text.isNotEmpty || _locationController.text.isNotEmpty) {
      setState(() => _autoSaved = true);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _autoSaved = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Raise Service'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          if (_autoSaved)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green, size: 16),
                      const SizedBox(width: 6),
                      Text('Saved', style: theme.textTheme.bodySmall?.copyWith(color: Colors.green, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
            color: theme.colorScheme.surface,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Form(
                key: _formKey,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Column
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildStepHeader(theme),
                          const SizedBox(height: 24),
                          _buildCategorySection(theme),
                          const SizedBox(height: 24),
                          _buildDescriptionSection(theme),
                          const SizedBox(height: 24),
                          _buildLocationSection(theme),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                    
                    const SizedBox(width: 32),
                    
                    // Right Column
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          _buildImageUploadSection(theme),
                          const SizedBox(height: 24),
                          if (_selectedImages.isNotEmpty)
                            _buildPricingButton(theme),
                          const SizedBox(height: 24),
                          WebSummaryPanel(
                            category: _selectedCategory,
                            imageCount: _selectedImages.length,
                            description: _descriptionController.text,
                            location: _locationController.text,
                          ),
                          if (_acceptedPrice != null) ...[
                            const SizedBox(height: 24),
                            _buildAcceptedPriceCard(theme),
                          ],
                          if (_isComplaintSubmitted) ...[
                            const SizedBox(height: 24),
                            WebAssignedDriverPanel(
                              driverName: 'Mike Johnson',
                              driverPhone: '+1 234 567 8900',
                              vehicleNumber: 'WM-1234',
                              status: 'On the way',
                              eta: '12 min',
                              currentPrice: _acceptedPrice!['recommended_price'].toDouble(),
                              negotiatedPrice: _negotiatedPrice,
                              onCallTap: _handleCall,
                              onChatTap: () => setState(() => _showChatPanel = true),
                              onTrackTap: _handleTrack,
                              onNegotiateTap: _showNegotiateDialog,
                              onCancelTap: _handleCancel,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
              ),
              if (_showChatPanel)
                WebDriverChatPanel(
                  driverName: 'Mike Johnson',
                  currentPrice: _acceptedPrice!['recommended_price'].toDouble(),
                  negotiatedPrice: _negotiatedPrice,
                  onClose: () => setState(() => _showChatPanel = false),
                  onNegotiate: (price) {
                    setState(() {
                      _negotiatedPrice = price;
                      _showChatPanel = false;
                    });
                    _showNegotiationSuccess(price);
                  },
                ),
            ],
          ),
          
          // Floating Submit Button
          if (!_showChatPanel)
            Positioned(
              bottom: 32,
              right: 32,
              child: _buildFloatingSubmitButton(theme),
            ),
        ],
      ),
    );
  }

  Widget _buildStepHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.colorScheme.primary.withOpacity(0.1), theme.colorScheme.primary.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _buildStep(theme, '1', 'Upload Photo', _selectedImages.isNotEmpty),
          _buildStepDivider(theme),
          _buildStep(theme, '2', 'Instant Estimate', _acceptedPrice != null),
          _buildStepDivider(theme),
          _buildStep(theme, '3', 'Confirm Booking', _isComplaintSubmitted),
        ],
      ),
    );
  }

  Widget _buildStep(ThemeData theme, String number, String label, bool isComplete) {
    return Expanded(
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isComplete ? theme.colorScheme.primary : theme.colorScheme.surface,
              shape: BoxShape.circle,
              border: Border.all(color: theme.colorScheme.primary, width: 2),
            ),
            child: Center(
              child: isComplete
                  ? Icon(Icons.check, color: theme.colorScheme.onPrimary, size: 16)
                  : Text(number, style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 8),
          Text(label, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildStepDivider(ThemeData theme) {
    return Container(
      width: 40,
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: theme.colorScheme.outline.withOpacity(0.3),
    );
  }

  Widget _buildCategorySection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Select Waste Category', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          WebCategorySelector(
            selectedCategory: _selectedCategory,
            onCategorySelected: (category) {
              setState(() => _selectedCategory = category);
              _onFormChanged();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Description', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          TextFormField(
            controller: _descriptionController,
            maxLines: 6,
            decoration: InputDecoration(
              hintText: 'Describe the waste collection issue in detail...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
            ),
            validator: (value) => value?.isEmpty ?? true ? 'Please provide a description' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Pickup Location', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          TextFormField(
            controller: _locationController,
            decoration: InputDecoration(
              hintText: 'Enter your address',
              prefixIcon: Icon(Icons.location_on_outlined, color: theme.colorScheme.primary),
              suffixIcon: IconButton(
                icon: Icon(Icons.my_location, color: theme.colorScheme.primary),
                onPressed: _getCurrentLocation,
                tooltip: 'Use current location',
              ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
            ),
            validator: (value) => value?.isEmpty ?? true ? 'Please enter pickup location' : null,
          ),
          const SizedBox(height: 16),
          WebLocationMap(
            location: _locationController.text,
            onLocationTap: () {
              setState(() => _locationController.text = '123 Main Street, City, State 12345');
              _onFormChanged();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildImageUploadSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Upload Images', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          WebDragDropUploader(
            images: _selectedImages,
            onImagesChanged: (images) {
              setState(() => _selectedImages = images);
              _onFormChanged();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPricingButton(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A73E8), Color(0xFF4285F4)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A73E8).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.auto_awesome, color: Colors.white, size: 32),
          const SizedBox(height: 12),
          const Text(
            'Get AI Price Estimate',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Let AI calculate fair pricing',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _showPricingDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF1A73E8),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Estimate Now'),
          ),
        ],
      ),
    );
  }

  Widget _buildAcceptedPriceCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF50).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF4CAF50).withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 24),
              const SizedBox(width: 12),
              Text(
                'Price Accepted',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '£${_acceptedPrice!['recommended_price']}',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: Color(0xFF4CAF50),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Range: £${_acceptedPrice!['estimated_price_min']} - £${_acceptedPrice!['estimated_price_max']}',
            style: TextStyle(
              fontSize: 13,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: _showPricingDialog,
            icon: const Icon(Icons.edit, size: 16),
            label: const Text('Change Price'),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingSubmitButton(ThemeData theme) {
    final isValid = _acceptedPrice != null && _locationController.text.isNotEmpty;
    
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isValid ? theme.colorScheme.primary.withOpacity(0.4) : Colors.black.withOpacity(0.1),
              blurRadius: isValid ? 20 : 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: SizedBox(
          width: 200,
          child: CustomButton(
            text: 'Submit Complaint',
            isLoading: _isLoading,
            onPressed: isValid ? _handleSubmit : () {},
          ),
        ),
      ),
    );
  }

  void _showPricingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 600,
          constraints: const BoxConstraints(maxHeight: 700),
          child: WebPricingEstimator(
            category: _selectedCategory ?? 'General Waste',
            location: _locationController.text.isEmpty ? 'Location not set' : _locationController.text,
            onPriceAccepted: (price) {
              Navigator.of(context).pop();
              setState(() {
                _acceptedPrice = price;
              });
            },
          ),
        ),
      ),
    );
  }

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_acceptedPrice == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please get AI price estimate first')),
      );
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      final categoryIndex = AppConstants.wasteCategories.indexWhere(
        (cat) => cat['name'] == _selectedCategory,
      );
      
      final response = await _issueService.createIssue(
        categoryId: categoryIndex,
        description: _descriptionController.text,
        pickupLocation: _locationController.text,
        images: _selectedImages.map((img) => img.path).toList(),
        amount: _acceptedPrice!['recommended_price'].toDouble(),
      );
      
      if (!mounted) return;
      
      Navigator.of(context).push(
        PageRouteBuilder(
          opaque: false,
          barrierColor: Colors.transparent,
          pageBuilder: (context, animation, secondaryAnimation) {
            return SubmitTransitionAnimation(
              buttonColor: Theme.of(context).colorScheme.primary,
              onComplete: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => DriverSelectionScreen(
                      price: _acceptedPrice!['recommended_price'].toDouble(),
                      location: _locationController.text,
                    ),
                  ),
                );
              },
            );
          },
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleCall() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.phone, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            const Text('Call Driver'),
          ],
        ),
        content: const Text('Calling Mike Johnson at +1 234 567 8900...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _handleTrack() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.location_on, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            const Text('Track Driver'),
          ],
        ),
        content: const Text('Driver is 2.5 km away and will arrive in 12 minutes.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showNegotiateDialog() {
    final priceController = TextEditingController(
      text: _negotiatedPrice > 0 ? _negotiatedPrice.toString() : _acceptedPrice!['recommended_price'].toString(),
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.currency_pound, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            const Text('Negotiate Price'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Current Price: £${_acceptedPrice!['recommended_price']}'),
            const SizedBox(height: 16),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Your Offer',
                prefixText: '£',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final price = double.tryParse(priceController.text) ?? 0;
              if (price > 0) {
                setState(() => _negotiatedPrice = price);
                Navigator.pop(context);
                _showNegotiationSuccess(price);
              }
            },
            child: const Text('Send Offer'),
          ),
        ],
      ),
    );
  }

  void _showNegotiationSuccess(double price) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Negotiation offer of £$price sent to driver'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location services are disabled')),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission denied')),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission permanently denied')),
        );
        return;
      }

      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _locationController.text = '${position.latitude}, ${position.longitude}';
      });
      _onFormChanged();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting location: $e')),
      );
    }
  }

  void _handleCancel() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning, color: Theme.of(context).colorScheme.error),
            const SizedBox(width: 12),
            const Text('Cancel Complaint'),
          ],
        ),
        content: const Text('Are you sure you want to cancel this complaint? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _isComplaintSubmitted = false;
                _negotiatedPrice = 0;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Complaint cancelled successfully'),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    _descriptionController.dispose();
    _locationController.dispose();
    _issueService.dispose();
    super.dispose();
  }
}
