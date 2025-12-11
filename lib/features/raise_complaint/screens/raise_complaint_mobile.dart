import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_card.dart';
import '../widgets/mobile_pricing_estimator.dart';
import '../widgets/submit_transition_animation.dart';
import '../screens/driver_selection_screen.dart';
import '../../user/screens/track_complaint_screen.dart';
import '../../../core/services/issue_service.dart';

class RaiseComplaintMobile extends StatefulWidget {
  final XFile? image;
  
  const RaiseComplaintMobile({super.key, this.image});

  @override
  State<RaiseComplaintMobile> createState() => _RaiseComplaintMobileState();
}

class _RaiseComplaintMobileState extends State<RaiseComplaintMobile> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  
  String? _selectedCategory;
  List<XFile> _selectedImages = [];
  bool _isLoading = false;
  Map<String, dynamic>? _acceptedPrice;
  final IssueService _issueService = IssueService();
  
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    if (widget.image != null) {
      _selectedImages.add(widget.image!);
    }
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Raise Service'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary.withOpacity(0.05),
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCategorySelection(theme),
                const SizedBox(height: 24),
                _buildImageUpload(theme),
                const SizedBox(height: 24),
                _buildDescription(theme),
                const SizedBox(height: 24),
                _buildLocationPicker(theme),
                const SizedBox(height: 24),
                if (_selectedCategory != null && _locationController.text.isNotEmpty)
                  _buildPricingButton(theme),
                if (_acceptedPrice != null) ...[
                  const SizedBox(height: 24),
                  _buildAcceptedPriceCard(theme),
                ],
                const SizedBox(height: 32),
                AnimatedBuilder(
                  animation: _scaleAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: CustomButton(
                        text: 'Submit Complaint',
                        isLoading: _isLoading,
                        onPressed: _handleSubmit,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySelection(ThemeData theme) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Waste Category', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            decoration: const InputDecoration(
              hintText: 'Select waste category',
              prefixIcon: Icon(Icons.category_outlined),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            ),
            isExpanded: true,
            items: AppConstants.wasteCategories.map((category) {
              return DropdownMenuItem<String>(
                value: category['name'],
                child: Row(
                  children: [
                    Text(category['icon'], style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Flexible(child: Text(category['name'], overflow: TextOverflow.ellipsis)),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) => setState(() => _selectedCategory = value),
            validator: (value) => value == null || value.isEmpty ? 'Please select a waste category' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildImageUpload(ThemeData theme) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Upload Images', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Add photos to help us understand the issue better', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6))),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 12, mainAxisSpacing: 12),
            itemCount: _selectedImages.length + 1,
            itemBuilder: (context, index) {
              if (index == _selectedImages.length) return _buildAddImageButton(theme);
              return _buildImageItem(theme, index);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAddImageButton(ThemeData theme) {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.primary.withOpacity(0.3), width: 2),
          borderRadius: BorderRadius.circular(12),
          color: theme.colorScheme.primary.withOpacity(0.05),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate_outlined, color: theme.colorScheme.primary, size: 32),
            const SizedBox(height: 4),
            Text('Add Photo', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildImageItem(ThemeData theme, int index) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: theme.colorScheme.surfaceVariant),
          child: const Center(child: Icon(Icons.image, size: 40)),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => setState(() => _selectedImages.removeAt(index)),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescription(ThemeData theme) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Description', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descriptionController,
            maxLines: 4,
            decoration: const InputDecoration(hintText: 'Describe the waste collection issue...', border: OutlineInputBorder()),
            validator: (value) => value?.isEmpty ?? true ? 'Please provide a description' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildLocationPicker(ThemeData theme) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Pickup Location', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _locationController,
                  decoration: InputDecoration(
                    hintText: 'Enter your address',
                    prefixIcon: Icon(Icons.location_on_outlined, color: theme.colorScheme.primary),
                  ),
                  validator: (value) => value?.isEmpty ?? true ? 'Please enter pickup location' : null,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                height: 56,
                width: 56,
                decoration: BoxDecoration(color: theme.colorScheme.primary, borderRadius: BorderRadius.circular(12)),
                child: IconButton(
                  onPressed: _locationController.text.isEmpty ? _getCurrentLocation : _clearLocation,
                  icon: Icon(_locationController.text.isEmpty ? Icons.my_location : Icons.arrow_forward, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _pickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => _selectedImages.add(image));
  }

  void _getCurrentLocation() {
    setState(() => _locationController.text = '123 Main Street, City, State 12345');
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Current location detected')));
  }

  void _clearLocation() => setState(() => _locationController.clear());

  void _showPricingScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MobilePricingEstimator(
          category: _selectedCategory!,
          location: _locationController.text,
          onPriceAccepted: (price) {
            setState(() {
              _acceptedPrice = price;
            });
          },
        ),
      ),
    );
  }

  Widget _buildPricingButton(ThemeData theme) {
    return CustomCard(
      child: InkWell(
        onTap: _showPricingScreen,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1A73E8), Color(0xFF4285F4)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.auto_awesome, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Get AI Price Estimate',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Let AI calculate fair pricing',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAcceptedPriceCard(ThemeData theme) {
    return CustomCard(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF4CAF50).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF4CAF50).withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Price Accepted',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _showPricingScreen,
                  style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(40, 36)),
                  child: const Text('Edit'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '£${_acceptedPrice!['recommended_price']}',
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w700,
                color: Color(0xFF4CAF50),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Range: £${_acceptedPrice!['estimated_price_min']} - £${_acceptedPrice!['estimated_price_max']}',
              style: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
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

  @override
  void dispose() {
    _descriptionController.dispose();
    _locationController.dispose();
    _animationController.dispose();
    _issueService.dispose();
    super.dispose();
  }
}
