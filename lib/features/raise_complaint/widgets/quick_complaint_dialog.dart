import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_constants.dart';
import '../widgets/submit_transition_animation.dart';
import '../../user/screens/track_complaint_screen.dart';

class QuickComplaintDialog extends StatefulWidget {
  final XFile image;

  const QuickComplaintDialog({super.key, required this.image});

  @override
  State<QuickComplaintDialog> createState() => _QuickComplaintDialogState();
}

class _QuickComplaintDialogState extends State<QuickComplaintDialog> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  
  String? _selectedCategory;
  bool _isEstimating = false;
  bool _showPrice = false;
  Map<String, dynamic>? _priceData;
  
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_fadeController);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    _slideController.forward();
    _fadeController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;
    
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: isSmallScreen ? const EdgeInsets.all(16) : const EdgeInsets.all(40),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Container(
            width: isSmallScreen ? size.width : size.width * 0.5,
            constraints: BoxConstraints(
              maxWidth: isSmallScreen ? size.width : 600,
              maxHeight: size.height * 0.85,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(theme),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildImagePreview(theme),
                          const SizedBox(height: 20),
                          _buildCategoryDropdown(theme),
                          const SizedBox(height: 20),
                          _buildDescriptionField(theme),
                          const SizedBox(height: 20),
                          _buildLocationField(theme),
                          const SizedBox(height: 24),
                          if (!_showPrice) _buildEstimateButton(theme),
                          if (_showPrice) _buildPriceCard(theme),
                        ],
                      ),
                    ),
                  ),
                ),
                _buildActionButtons(theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F5132), Color(0xFF198754)],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.camera_alt, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Quick Waste Report',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview(ThemeData theme) {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image, size: 48, color: theme.colorScheme.primary),
            const SizedBox(height: 8),
            Text('Image Selected', style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown(ThemeData theme) {
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      decoration: InputDecoration(
        labelText: 'Waste Category',
        prefixIcon: const Icon(Icons.category_outlined),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
      ),
      items: AppConstants.wasteCategories.map((category) {
        return DropdownMenuItem<String>(
          value: category['name'],
          child: Row(
            children: [
              Text(category['icon'], style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(category['name']),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) => setState(() => _selectedCategory = value),
      validator: (value) => value == null ? 'Select category' : null,
    );
  }

  Widget _buildDescriptionField(ThemeData theme) {
    return TextFormField(
      controller: _descriptionController,
      maxLines: 3,
      decoration: InputDecoration(
        labelText: 'Description',
        hintText: 'Describe the waste...',
        prefixIcon: const Icon(Icons.description_outlined),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
      ),
      validator: (value) => value?.isEmpty ?? true ? 'Enter description' : null,
    );
  }

  Widget _buildLocationField(ThemeData theme) {
    return TextFormField(
      controller: _locationController,
      decoration: InputDecoration(
        labelText: 'Pickup Location',
        hintText: 'Enter address',
        prefixIcon: Icon(Icons.location_on_outlined, color: theme.colorScheme.primary),
        suffixIcon: IconButton(
          icon: Icon(Icons.my_location, color: theme.colorScheme.primary),
          onPressed: () {
            setState(() => _locationController.text = '123 Main Street, City, State 12345');
          },
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
      ),
      validator: (value) => value?.isEmpty ?? true ? 'Enter location' : null,
    );
  }

  Widget _buildEstimateButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: _isEstimating
          ? Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1A73E8), Color(0xFF4285F4)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const SizedBox(
                    width: 30,
                    height: 30,
                    child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'AI is analyzing your waste...',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Calculating best price',
                    style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
                  ),
                ],
              ),
            )
          : ElevatedButton.icon(
              onPressed: _getEstimate,
              icon: const Icon(Icons.auto_awesome, size: 18),
              label: const FittedBox(
                fit: BoxFit.scaleDown,
                child: Text('Get AI Estimate'),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A73E8),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
    );
  }

  Widget _buildPriceCard(ThemeData theme) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 500),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(
            opacity: value,
            child: Container(
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
                      const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 28),
                      const SizedBox(width: 12),
                      Text(
                        'Estimated Price',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 800),
                    tween: Tween(begin: 0.0, end: _priceData!['recommended_price'].toDouble()),
                    builder: (context, value, child) {
                      return Text(
                        '₹${value.toInt()}',
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF4CAF50),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Range: ₹${_priceData!['estimated_price_min']} - ₹${_priceData!['estimated_price_max']}',
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: () => setState(() => _showPrice = false),
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Recalculate'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFFFAF7F2),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                side: const BorderSide(color: Color(0xFF0F5132)),
                foregroundColor: const Color(0xFF0F5132),
              ),
              child: const Text('Cancel', style: TextStyle(fontSize: 14)),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: _showPrice
                ? AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimation.value,
                        child: ElevatedButton(
                          onPressed: _submitComplaint,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F5132),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Submit', style: TextStyle(fontSize: 14)),
                        ),
                      );
                    },
                  )
                : ElevatedButton(
                    onPressed: null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F5132),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      disabledBackgroundColor: const Color(0xFF0F5132).withOpacity(0.5),
                    ),
                    child: const Text('Submit', style: TextStyle(fontSize: 14)),
                  ),
          ),
        ],
      ),
    );
  }

  void _getEstimate() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isEstimating = true);
    
    await Future.delayed(const Duration(seconds: 2));
    
    setState(() {
      _isEstimating = false;
      _showPrice = true;
      _priceData = {
        'recommended_price': 450,
        'estimated_price_min': 350,
        'estimated_price_max': 550,
      };
    });
    
    _pulseController.repeat(reverse: true);
  }

  void _submitComplaint() {
    Navigator.of(context).pop();
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.transparent,
        pageBuilder: (context, animation, secondaryAnimation) {
          return SubmitTransitionAnimation(
            buttonColor: const Color(0xFF0F5132),
            onComplete: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const TrackComplaintScreen(),
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
    _slideController.dispose();
    _fadeController.dispose();
    _pulseController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }
}
