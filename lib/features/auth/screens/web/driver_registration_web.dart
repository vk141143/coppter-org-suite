import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../otp_screen.dart';
import 'login_right_panel.dart';
import '../../../../core/services/auth_service.dart';

class DriverRegistrationWeb extends StatefulWidget {
  const DriverRegistrationWeb({super.key});

  @override
  State<DriverRegistrationWeb> createState() => _DriverRegistrationWebState();
}

class _DriverRegistrationWebState extends State<DriverRegistrationWeb> {
  final _pageController = PageController();
  int _currentStep = 0;
  bool _isLoading = false;

  // Controllers for all 8 steps
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _dobController = TextEditingController();
  final _addressController = TextEditingController();
  String? _gender;
  
  String? _idType;
  final _idNumberController = TextEditingController();
  XFile? _idPhoto;
  XFile? _selfiePhoto;
  
  final _experienceController = TextEditingController();
  final _licenseNumberController = TextEditingController();
  final _licenseCategoryController = TextEditingController();
  final _licenseExpiryController = TextEditingController();
  final _previousCompanyController = TextEditingController();
  final _serviceAreaController = TextEditingController();
  
  String? _vehicleType;
  final _vehiclePlateController = TextEditingController();
  final _vehicleModelController = TextEditingController();
  final _vehicleCapacityController = TextEditingController();
  XFile? _rcPhoto;
  XFile? _pollutionCertPhoto;
  
  final _pinCodesController = TextEditingController();
  String? _preferredShift;
  
  final _accountNumberController = TextEditingController();
  final _ifscController = TextEditingController();
  final _accountHolderController = TextEditingController();
  final _upiController = TextEditingController();
  
  XFile? _driverPhoto;
  XFile? _licenseFrontPhoto;
  XFile? _licenseBackPhoto;
  XFile? _insurancePhoto;
  XFile? _vehiclePhoto;
  
  bool _acceptTerms = false;
  bool _acceptSafety = false;
  bool _acceptPolicy = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Row(
        children: [
          Expanded(flex: 55, child: LoginRightPanel()),
          Expanded(
            flex: 45,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: isDark ? [Color(0xFF0F1419), Color(0xFF1E1E1E)] : [Color(0xFFF5F7FA), Colors.white],
                ),
              ),
              child: Column(
                children: [
                  _buildProgressBar(isDark),
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildStep1(isDark),
                        _buildStep2(isDark),
                        _buildStep3(isDark),
                        _buildStep4(isDark),
                        _buildStep5(isDark),
                        _buildStep6(isDark),
                        _buildStep7(isDark),
                        _buildStep8(isDark),
                      ],
                    ),
                  ),
                  _buildNavButtons(isDark),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: List.generate(8, (index) {
          final isCompleted = index < _currentStep;
          final isCurrent = index == _currentStep;
          return Expanded(
            child: Container(
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: isCompleted || isCurrent ? const Color(0xFF1B5E20) : (isDark ? Colors.white12 : Colors.black12),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStep1(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Personal Details', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: isDark ? Colors.white : const Color(0xFF212121))),
          const SizedBox(height: 24),
          _buildTextField(_nameController, 'Full Name *', Icons.person_outline, isDark),
          const SizedBox(height: 16),
          _buildTextField(_phoneController, 'Phone Number *', Icons.phone_outlined, isDark, isPhone: true),
          const SizedBox(height: 16),
          _buildTextField(_emailController, 'Email Address *', Icons.email_outlined, isDark, isEmail: true),
          const SizedBox(height: 16),
          _buildTextField(_dobController, 'Date of Birth *', Icons.calendar_today_outlined, isDark, readOnly: true, onTap: () async {
            final date = await showDatePicker(context: context, initialDate: DateTime(1990), firstDate: DateTime(1950), lastDate: DateTime.now());
            if (date != null) _dobController.text = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
          }),
          const SizedBox(height: 16),
          _buildDropdown('Gender', _gender, ['Male', 'Female', 'Other'], (v) => setState(() => _gender = v), isDark),
          const SizedBox(height: 16),
          _buildTextField(_addressController, 'Full Address *', Icons.location_on_outlined, isDark, maxLines: 3),
        ],
      ),
    );
  }

  Widget _buildStep2(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Identity Verification', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: isDark ? Colors.white : const Color(0xFF212121))),
          const SizedBox(height: 24),
          _buildDropdown('Government ID Type *', _idType, ['Aadhar', 'Driving License', 'Voter ID', 'Passport'], (v) => setState(() => _idType = v), isDark),
          const SizedBox(height: 16),
          _buildTextField(_idNumberController, 'ID Number *', Icons.numbers, isDark),
          const SizedBox(height: 24),
          _buildPhotoUpload('ID Photo', _idPhoto, (f) => setState(() => _idPhoto = f), isDark),
          const SizedBox(height: 16),
          _buildPhotoUpload('Selfie Photo', _selfiePhoto, (f) => setState(() => _selfiePhoto = f), isDark),
        ],
      ),
    );
  }

  Widget _buildStep3(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Professional Details', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: isDark ? Colors.white : const Color(0xFF212121))),
          const SizedBox(height: 24),
          _buildTextField(_experienceController, 'Years of Experience *', Icons.work_outline, isDark, isNumber: true),
          const SizedBox(height: 16),
          _buildTextField(_licenseNumberController, 'License Number *', Icons.credit_card, isDark),
          const SizedBox(height: 16),
          _buildTextField(_licenseCategoryController, 'License Category *', Icons.category_outlined, isDark),
          const SizedBox(height: 16),
          _buildTextField(_licenseExpiryController, 'License Expiry Date *', Icons.calendar_today_outlined, isDark, readOnly: true, onTap: () async {
            final date = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2050));
            if (date != null) _licenseExpiryController.text = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
          }),
          const SizedBox(height: 16),
          _buildTextField(_previousCompanyController, 'Previous Company (Optional)', Icons.business_outlined, isDark),
          const SizedBox(height: 16),
          _buildTextField(_serviceAreaController, 'Service Area *', Icons.map_outlined, isDark),
        ],
      ),
    );
  }

  Widget _buildStep4(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Vehicle Details', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: isDark ? Colors.white : const Color(0xFF212121))),
          const SizedBox(height: 24),
          _buildDropdown('Vehicle Type *', _vehicleType, ['Truck', 'Van', 'Auto', 'E-cart'], (v) => setState(() => _vehicleType = v), isDark),
          const SizedBox(height: 16),
          _buildTextField(_vehiclePlateController, 'Vehicle Number Plate *', Icons.pin_outlined, isDark),
          const SizedBox(height: 16),
          _buildTextField(_vehicleModelController, 'Vehicle Model *', Icons.directions_car_outlined, isDark),
          const SizedBox(height: 16),
          _buildTextField(_vehicleCapacityController, 'Vehicle Capacity (kg) *', Icons.scale_outlined, isDark, isNumber: true),
          const SizedBox(height: 24),
          _buildPhotoUpload('RC Book Photo *', _rcPhoto, (f) => setState(() => _rcPhoto = f), isDark),
          const SizedBox(height: 16),
          _buildPhotoUpload('Pollution Certificate Photo *', _pollutionCertPhoto, (f) => setState(() => _pollutionCertPhoto = f), isDark),
        ],
      ),
    );
  }

  Widget _buildStep5(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Service Area', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: isDark ? Colors.white : const Color(0xFF212121))),
          const SizedBox(height: 24),
          _buildTextField(_pinCodesController, 'PIN Codes (comma separated) *', Icons.location_on_outlined, isDark),
          const SizedBox(height: 16),
          _buildDropdown('Preferred Shift *', _preferredShift, ['Morning', 'Evening', 'Full Day', 'Custom'], (v) => setState(() => _preferredShift = v), isDark),
        ],
      ),
    );
  }

  Widget _buildStep6(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Bank Details', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: isDark ? Colors.white : const Color(0xFF212121))),
          const SizedBox(height: 8),
          Text('Optional - For payments', style: TextStyle(fontSize: 14, color: isDark ? Colors.white60 : const Color(0xFF64748B))),
          const SizedBox(height: 24),
          _buildTextField(_accountNumberController, 'Account Number', Icons.account_balance_outlined, isDark, isNumber: true),
          const SizedBox(height: 16),
          _buildTextField(_ifscController, 'Sort Code', Icons.code_outlined, isDark),
          const SizedBox(height: 16),
          _buildTextField(_accountHolderController, 'Account Holder Name', Icons.person_outline, isDark),
          const SizedBox(height: 16),
          _buildTextField(_upiController, 'UPI ID', Icons.payment_outlined, isDark),
        ],
      ),
    );
  }

  Widget _buildStep7(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Documents Upload', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: isDark ? Colors.white : const Color(0xFF212121))),
          const SizedBox(height: 24),
          _buildPhotoUpload('Driver Photo *', _driverPhoto, (f) => setState(() => _driverPhoto = f), isDark),
          const SizedBox(height: 16),
          _buildPhotoUpload('License Front *', _licenseFrontPhoto, (f) => setState(() => _licenseFrontPhoto = f), isDark),
          const SizedBox(height: 16),
          _buildPhotoUpload('License Back *', _licenseBackPhoto, (f) => setState(() => _licenseBackPhoto = f), isDark),
          const SizedBox(height: 16),
          _buildPhotoUpload('Vehicle Photo *', _vehiclePhoto, (f) => setState(() => _vehiclePhoto = f), isDark),
        ],
      ),
    );
  }

  Widget _buildStep8(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Agreement & Safety', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: isDark ? Colors.white : const Color(0xFF212121))),
          const SizedBox(height: 24),
          CheckboxListTile(
            value: _acceptTerms,
            onChanged: (v) => setState(() => _acceptTerms = v ?? false),
            title: const Text('I accept Terms & Conditions'),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            activeColor: const Color(0xFF1B5E20),
          ),
          CheckboxListTile(
            value: _acceptSafety,
            onChanged: (v) => setState(() => _acceptSafety = v ?? false),
            title: const Text('I accept Safety Guidelines'),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            activeColor: const Color(0xFF1B5E20),
          ),
          CheckboxListTile(
            value: _acceptPolicy,
            onChanged: (v) => setState(() => _acceptPolicy = v ?? false),
            title: const Text('I accept Waste Handling Policy'),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            activeColor: const Color(0xFF1B5E20),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, bool isDark, {bool isEmail = false, bool isPhone = false, bool isNumber = false, int maxLines = 1, bool readOnly = false, VoidCallback? onTap}) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      maxLines: maxLines,
      keyboardType: isEmail ? TextInputType.emailAddress : (isPhone || isNumber ? TextInputType.number : TextInputType.text),
      onTap: onTap,
      style: TextStyle(color: isDark ? Colors.white : const Color(0xFF212121)),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Container(margin: const EdgeInsets.all(12), padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFF76FF03).withOpacity(0.2), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: const Color(0xFF1B5E20), size: 20)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        filled: true,
        fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.5),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF1B5E20), width: 2)),
      ),
    );
  }

  Widget _buildDropdown(String label, String? value, List<String> items, Function(String?) onChanged, bool isDark) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        filled: true,
        fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.5),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF1B5E20), width: 2)),
      ),
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildPhotoUpload(String label, XFile? file, Function(XFile?) onPicked, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF212121))),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final picker = ImagePicker();
            final image = await picker.pickImage(source: ImageSource.gallery);
            onPicked(image);
          },
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF76FF03).withOpacity(0.5), width: 2),
              borderRadius: BorderRadius.circular(12),
              color: const Color(0xFF76FF03).withOpacity(0.05),
            ),
            child: Center(
              child: file == null
                  ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.cloud_upload_outlined, size: 32, color: Color(0xFF1B5E20)), const SizedBox(height: 8), Text('Tap to upload', style: TextStyle(fontSize: 12, color: Color(0xFF1B5E20)))])
                  : Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.check_circle, color: Colors.green), const SizedBox(width: 8), Text('Uploaded')]),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavButtons(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() => _currentStep--);
                  _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                },
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), side: const BorderSide(color: Color(0xFF1B5E20), width: 2)),
                child: const Text('Back', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1B5E20))),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleNext,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1B5E20), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0),
              child: _isLoading ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Text(_currentStep == 7 ? 'Submit' : 'Next', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  void _handleNext() async {
    if (_currentStep < 7) {
      setState(() => _currentStep++);
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      if (!_acceptTerms || !_acceptSafety || !_acceptPolicy) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please accept all agreements')));
        return;
      }
      
      // Validate required files
      final missingFiles = <String>[];
      if (_driverPhoto == null) missingFiles.add('Driver Photo');
      if (_licenseFrontPhoto == null) missingFiles.add('License Front');
      if (_licenseBackPhoto == null) missingFiles.add('License Back');
      if (_idPhoto == null) missingFiles.add('ID Photo');
      if (_selfiePhoto == null) missingFiles.add('Selfie Photo');
      if (_vehiclePhoto == null) missingFiles.add('Vehicle Photo');
      if (_rcPhoto == null) missingFiles.add('RC Book Photo');
      if (_pollutionCertPhoto == null) missingFiles.add('Pollution Certificate');
      
      if (missingFiles.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please upload: ${missingFiles.join(", ")}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
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
          'govt_id_type': _idType?.toLowerCase() ?? 'addhar',
          'govt_id_number': _idNumberController.text.trim(),
          'years_of_experience': int.tryParse(_experienceController.text.trim()) ?? 0,
          'license_number': _licenseNumberController.text.trim(),
          'license_category': _licenseCategoryController.text.trim(),
          'license_expiry_date': _licenseExpiryController.text.trim(),
          'previous_company': _previousCompanyController.text.trim(),
          'vehicle_type': _vehicleType ?? 'Truck',
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
        
        print('📋 Driver Data: $driverData');
        print('📸 Files to upload:');
        print('  - driver_photo: ${_driverPhoto?.name ?? "MISSING"}');
        print('  - license_front: ${_licenseFrontPhoto?.name ?? "MISSING"}');
        print('  - license_back: ${_licenseBackPhoto?.name ?? "MISSING"}');
        print('  - govt_id_photo: ${_idPhoto?.name ?? "MISSING"}');
        print('  - selfie_photo: ${_selfiePhoto?.name ?? "MISSING"}');
        print('  - vehicle_photo: ${_vehiclePhoto?.name ?? "MISSING"}');
        print('  - rc_book_photo: ${_rcPhoto?.name ?? "MISSING"}');
        print('  - pollution_certificate_photo: ${_pollutionCertPhoto?.name ?? "MISSING"}');
        
        final authService = AuthService();
        final response = await authService.registerDriver(
          driverData,
          driverPhoto: _driverPhoto,
          licenseFront: _licenseFrontPhoto,
          licenseBack: _licenseBackPhoto,
          vehiclePhoto: _vehiclePhoto,
          idPhoto: _idPhoto,
          selfiePhoto: _selfiePhoto,
          v5cDocument: _rcPhoto,
          motCertificate: _pollutionCertPhoto,
        );
        
        print('✅ SUCCESS: Driver registration response: $response');
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registration successful!'), backgroundColor: Colors.green),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => OTPScreen(
                phoneNumber: _phoneController.text,
                userType: 'Driver',
              ),
            ),
          );
        }
      } catch (e) {
        print('❌ REGISTRATION FAILED: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
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
