import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/driver_service.dart';
import 'otp_screen.dart';
import 'web/driver_registration_web.dart';

class DriverRegistrationScreen extends StatefulWidget {
  const DriverRegistrationScreen({super.key});

  @override
  State<DriverRegistrationScreen> createState() => _DriverRegistrationScreenState();
}

class _DriverRegistrationScreenState extends State<DriverRegistrationScreen> {
  final _pageController = PageController();
  int _currentStep = 0;
  bool _isLoading = false;

  // Step 1: Personal Details
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _dobController = TextEditingController();
  final _addressController = TextEditingController();
  String? _gender;

  // Step 2: Identity Verification
  String? _idType;
  final _idNumberController = TextEditingController();
  final _aadharNumberController = TextEditingController();
  final _panNumberController = TextEditingController();
  XFile? _idPhoto;
  XFile? _selfiePhoto;
  XFile? _aadharDocument;
  XFile? _panDocument;

  // Step 3: Professional Details
  final _experienceController = TextEditingController();
  final _licenseNumberController = TextEditingController();
  final _licenseCategoryController = TextEditingController();
  final _licenseExpiryController = TextEditingController();
  final _previousCompanyController = TextEditingController();
  final _serviceAreaController = TextEditingController();

  // Step 4: Vehicle Details
  String? _vehicleType;
  final _vehiclePlateController = TextEditingController();
  final _vehicleModelController = TextEditingController();
  final _vehicleCapacityController = TextEditingController();
  // UK Documents (replace Indian)
  XFile? _v5cDocument;  // Replaces RC Book
  XFile? _motCertificate;  // Replaces Pollution Certificate

  // Step 5: Service Area
  final _pinCodesController = TextEditingController();
  String? _preferredShift;

  // Step 6: Bank Details
  final _accountNumberController = TextEditingController();
  final _ifscController = TextEditingController();
  final _accountHolderController = TextEditingController();
  final _upiController = TextEditingController();

  // Step 7: Documents
  XFile? _driverPhoto;
  XFile? _licenseFrontPhoto;
  XFile? _licenseBackPhoto;
  XFile? _insurancePhoto;
  XFile? _vehiclePhoto;
  
  // Step 8: UK Compliance Documents (NEW)
  XFile? _rightToWorkDoc;
  XFile? _wasteCarrierLicense;
  XFile? _dbsCertificate;
  XFile? _healthSafetyCert;
  XFile? _proofOfAddress;

  // Step 9: Agreements
  bool _acceptTerms = false;
  bool _acceptSafety = false;
  bool _acceptPolicy = false;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width > 900) {
      return const DriverRegistrationWeb();
    }
    
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Registration'),
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
        child: Column(
          children: [
            // Progress Indicator
            _buildProgressIndicator(theme),
            
            // Form Content
            Expanded(
              child: Center(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isWeb = MediaQuery.of(context).size.width > 600;
                    return Container(
                      constraints: BoxConstraints(maxWidth: isWeb ? 600 : double.infinity),
                      child: PageView(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _buildStep1(theme),
                          _buildStep2(theme),
                          _buildStep3(theme),
                          _buildStep4(theme),
                          _buildStep5(theme),
                          _buildStep6(theme),
                          _buildStep7(theme),
                          _buildStep8(theme),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            
            // Navigation Buttons
            _buildNavigationButtons(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: List.generate(8, (index) {
          final isCompleted = index < _currentStep;
          final isCurrent = index == _currentStep;
          return Expanded(
            child: Container(
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: isCompleted || isCurrent
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStep1(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: CustomCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personal Details',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name *',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone Number *',
                prefixIcon: Icon(Icons.phone_outlined),
                helperText: 'Format: +1234567890 or 1234567890',
                hintText: '+1234567890',
              ),
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email Address *',
                prefixIcon: Icon(Icons.email_outlined),
                hintText: 'example@email.com',
              ),
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _dobController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Date of Birth *',
                prefixIcon: Icon(Icons.calendar_today_outlined),
              ),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime(1990),
                  firstDate: DateTime(1950),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  _dobController.text = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                }
              },
            ),
            const SizedBox(height: 16),
            
            DropdownButtonFormField<String>(
              value: _gender,
              decoration: const InputDecoration(
                labelText: 'Gender',
                prefixIcon: Icon(Icons.person_outline),
              ),
              items: ['Male', 'Female', 'Other'].map((g) {
                return DropdownMenuItem(value: g, child: Text(g));
              }).toList(),
              onChanged: (value) => setState(() => _gender = value),
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _addressController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Full Address *',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: CustomCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Identity Verification (KYC)',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            
            DropdownButtonFormField<String>(
              value: _idType,
              decoration: const InputDecoration(
                labelText: 'Government ID Type *',
                prefixIcon: Icon(Icons.badge_outlined),
              ),
              items: ['Aadhar', 'Passport', 'Voter ID'].map((id) {
                return DropdownMenuItem(value: id, child: Text(id));
              }).toList(),
              onChanged: (value) => setState(() => _idType = value),
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _idNumberController,
              decoration: const InputDecoration(
                labelText: 'Government ID Number *',
                prefixIcon: Icon(Icons.numbers),
              ),
            ),
            const SizedBox(height: 16),
            _buildPhotoUpload(theme, 'Government ID Photo *', _idPhoto, (file) => setState(() => _idPhoto = file)),
            const SizedBox(height: 16),
            _buildPhotoUpload(theme, 'Selfie Photo *', _selfiePhoto, (file) => setState(() => _selfiePhoto = file)),
          ],
        ),
      ),
    );
  }

  Widget _buildStep3(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: CustomCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Professional Details',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            
            TextFormField(
              controller: _experienceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Years of Experience *',
                prefixIcon: Icon(Icons.work_outline),
              ),
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _licenseNumberController,
              decoration: const InputDecoration(
                labelText: 'License Number *',
                prefixIcon: Icon(Icons.credit_card),
              ),
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _licenseCategoryController,
              decoration: const InputDecoration(
                labelText: 'License Category *',
                prefixIcon: Icon(Icons.category_outlined),
              ),
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _licenseExpiryController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'License Expiry Date *',
                prefixIcon: Icon(Icons.calendar_today_outlined),
              ),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2050),
                );
                if (date != null) {
                  _licenseExpiryController.text = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                }
              },
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _previousCompanyController,
              decoration: const InputDecoration(
                labelText: 'Previous Company (Optional)',
                prefixIcon: Icon(Icons.business_outlined),
              ),
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _serviceAreaController,
              decoration: const InputDecoration(
                labelText: 'Work Region / Service Area *',
                prefixIcon: Icon(Icons.map_outlined),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep4(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: CustomCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vehicle Details',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            
            DropdownButtonFormField<String>(
              value: _vehicleType,
              decoration: const InputDecoration(
                labelText: 'Vehicle Type *',
                prefixIcon: Icon(Icons.local_shipping_outlined),
              ),
              items: ['Truck', 'Van', 'Auto', 'E-cart'].map((v) {
                return DropdownMenuItem(value: v, child: Text(v));
              }).toList(),
              onChanged: (value) => setState(() => _vehicleType = value),
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _vehiclePlateController,
              decoration: const InputDecoration(
                labelText: 'Vehicle Number Plate *',
                prefixIcon: Icon(Icons.pin_outlined),
              ),
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _vehicleModelController,
              decoration: const InputDecoration(
                labelText: 'Vehicle Model *',
                prefixIcon: Icon(Icons.directions_car_outlined),
              ),
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _vehicleCapacityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Vehicle Capacity (kg/tons) *',
                prefixIcon: Icon(Icons.scale_outlined),
              ),
            ),
            const SizedBox(height: 24),
            
            _buildPhotoUpload(theme, 'RC Book Photo *', _v5cDocument, (file) => setState(() => _v5cDocument = file)),
            const SizedBox(height: 16),
            _buildPhotoUpload(theme, 'Pollution Certificate Photo *', _motCertificate, (file) => setState(() => _motCertificate = file)),
          ],
        ),
      ),
    );
  }

  Widget _buildStep5(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: CustomCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Service Area Details',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            
            TextFormField(
              controller: _pinCodesController,
              decoration: const InputDecoration(
                labelText: 'PIN Codes (comma separated) *',
                prefixIcon: Icon(Icons.location_on_outlined),
                hintText: '123456, 234567, 345678',
              ),
            ),
            const SizedBox(height: 16),
            
            DropdownButtonFormField<String>(
              value: _preferredShift,
              decoration: const InputDecoration(
                labelText: 'Preferred Shift *',
                prefixIcon: Icon(Icons.access_time),
              ),
              items: ['Morning', 'Evening', 'Full Day', 'Custom'].map((s) {
                return DropdownMenuItem(value: s, child: Text(s));
              }).toList(),
              onChanged: (value) => setState(() => _preferredShift = value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep6(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: CustomCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bank / Payment Details',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Optional - For receiving payments',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            
            TextFormField(
              controller: _accountNumberController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Bank Account Number',
                prefixIcon: Icon(Icons.account_balance_outlined),
              ),
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _ifscController,
              decoration: const InputDecoration(
                labelText: 'Sort Code',
                prefixIcon: Icon(Icons.code_outlined),
              ),
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _accountHolderController,
              decoration: const InputDecoration(
                labelText: 'Account Holder Name',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _upiController,
              decoration: const InputDecoration(
                labelText: 'UPI ID',
                prefixIcon: Icon(Icons.payment_outlined),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep7(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: CustomCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Documents Upload',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            
            _buildPhotoUpload(theme, 'Driver Photo *', _driverPhoto, (file) => setState(() => _driverPhoto = file)),
            const SizedBox(height: 16),
            _buildPhotoUpload(theme, 'License Front *', _licenseFrontPhoto, (file) => setState(() => _licenseFrontPhoto = file)),
            const SizedBox(height: 16),
            _buildPhotoUpload(theme, 'License Back *', _licenseBackPhoto, (file) => setState(() => _licenseBackPhoto = file)),
            const SizedBox(height: 16),
            _buildPhotoUpload(theme, 'Vehicle Photo *', _vehiclePhoto, (file) => setState(() => _vehiclePhoto = file)),
          ],
        ),
      ),
    );
  }

  Widget _buildStep8(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: CustomCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Agreement & Safety',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            
            CheckboxListTile(
              value: _acceptTerms,
              onChanged: (value) => setState(() => _acceptTerms = value ?? false),
              title: const Text('I accept Terms & Conditions'),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            
            CheckboxListTile(
              value: _acceptSafety,
              onChanged: (value) => setState(() => _acceptSafety = value ?? false),
              title: const Text('I accept Safety Guidelines'),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            
            CheckboxListTile(
              value: _acceptPolicy,
              onChanged: (value) => setState(() => _acceptPolicy = value ?? false),
              title: const Text('I accept Responsible Waste Handling Policy'),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoUpload(ThemeData theme, String label, XFile? file, Function(XFile?) onPicked) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final picker = ImagePicker();
            final image = await picker.pickImage(source: ImageSource.gallery);
            onPicked(image);
          },
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              border: Border.all(color: theme.colorScheme.outline),
              borderRadius: BorderRadius.circular(12),
              color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
            ),
            child: Center(
              child: file == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cloud_upload_outlined, size: 40, color: theme.colorScheme.primary),
                        const SizedBox(height: 8),
                        Text('Tap to upload', style: theme.textTheme.bodySmall),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green),
                        const SizedBox(width: 8),
                        const Text('File uploaded'),
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationButtons(ThemeData theme) {
    final isWeb = MediaQuery.of(context).size.width > 600;
    return Container(
      padding: const EdgeInsets.all(24),
      child: isWeb
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_currentStep > 0)
                  SizedBox(
                    width: 120,
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() => _currentStep--);
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: const Text('Back'),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 16),
                SizedBox(
                  width: 120,
                  child: CustomButton(
                    text: _currentStep == 7 ? 'Submit' : 'Next',
                    isLoading: _isLoading,
                    onPressed: _handleNext,
                  ),
                ),
              ],
            )
          : Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() => _currentStep--);
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: const Text('Back'),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 16),
                Expanded(
                  child: CustomButton(
                    text: _currentStep == 7 ? 'Submit' : 'Next',
                    isLoading: _isLoading,
                    onPressed: _handleNext,
                  ),
                ),
              ],
            ),
    );
  }

  String? _validatePhone(String phone) {
    final phoneRegex = RegExp(r'^\+?[1-9]\d{1,14}$');
    if (!phoneRegex.hasMatch(phone)) {
      return 'Invalid phone format. Use: +1234567890 or 1234567890';
    }
    return null;
  }

  String? _validateEmail(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(email)) {
      return 'Invalid email format';
    }
    return null;
  }

  void _handleNext() async {
    print('🔵 _handleNext called, currentStep: $_currentStep');
    if (_currentStep < 7) {
      // Validate step 1 before proceeding
      if (_currentStep == 0) {
        final phoneError = _validatePhone(_phoneController.text);
        if (phoneError != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(phoneError), backgroundColor: Colors.red),
          );
          return;
        }
        final emailError = _validateEmail(_emailController.text);
        if (emailError != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(emailError), backgroundColor: Colors.red),
          );
          return;
        }
      }
      
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      if (!_acceptTerms || !_acceptSafety || !_acceptPolicy) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please accept all agreements')),
        );
        return;
      }
      
      setState(() => _isLoading = true);
      
      try {
        final driverData = {
          'full_name': _nameController.text.trim(),
          'phone_number': _phoneController.text.trim(),
          'email': _emailController.text.trim(),
          'dob': _dobController.text.trim(),
          'address': _addressController.text.trim(),
          'govt_id_type': _idType?.toLowerCase() ?? 'aadhar',
          'govt_id_number': _idNumberController.text.trim(),
          'years_of_experience': int.tryParse(_experienceController.text.trim()) ?? 0,
          'license_number': _licenseNumberController.text.trim(),
          'license_category': _licenseCategoryController.text.trim(),
          'license_expiry_date': _licenseExpiryController.text.trim(),
          'vehicle_type': _vehicleType?.toLowerCase() ?? 'truck',
          'vehicle_number': _vehiclePlateController.text.trim(),
          'vehicle_model': _vehicleModelController.text.trim(),
          'vehicle_capacity': _vehicleCapacityController.text.trim(),
          'pincodes': _pinCodesController.text.trim(),
          'preferred_shift': _preferredShift?.toLowerCase() ?? 'morning',
          'account_number': _accountNumberController.text.trim(),
          'sort_code': _ifscController.text.trim(),
          'holder_name': _accountHolderController.text.trim(),
          'upi_id': _upiController.text.trim(),
        };
        
        final driverService = DriverService();
        final response = await driverService.registerDriverWithUpload(
          driverData: driverData,
          driverPhoto: _driverPhoto,
          licenseFront: _licenseFrontPhoto,
          licenseBack: _licenseBackPhoto,
          govtIdPhoto: _idPhoto,
          selfiePhoto: _selfiePhoto,
          vehiclePhoto: _vehiclePhoto,
          rcBookPhoto: _v5cDocument,
          pollutionCertPhoto: _motCertificate,
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Registration successful!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => OTPScreen(
                phoneNumber: _phoneController.text,
                userType: 'Driver',
                isRegistration: true,
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceAll('Exception: ', '')),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }
  


  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    _addressController.dispose();
    _idNumberController.dispose();
    _aadharNumberController.dispose();
    _panNumberController.dispose();
    _experienceController.dispose();
    _licenseNumberController.dispose();
    _licenseCategoryController.dispose();
    _licenseExpiryController.dispose();
    _previousCompanyController.dispose();
    _serviceAreaController.dispose();
    _vehiclePlateController.dispose();
    _vehicleModelController.dispose();
    _vehicleCapacityController.dispose();
    _pinCodesController.dispose();
    _accountNumberController.dispose();
    _ifscController.dispose();
    _accountHolderController.dispose();
    _upiController.dispose();
    super.dispose();
  }
}
