import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:file_picker/file_picker.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../shared/widgets/custom_button.dart';
import 'driver_support_detail_screen.dart';

class DriverSupportScreen extends StatefulWidget {
  const DriverSupportScreen({super.key});

  @override
  State<DriverSupportScreen> createState() => _DriverSupportScreenState();
}

class _DriverSupportScreenState extends State<DriverSupportScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late AnimationController _rotateController;
  final FlutterTts flutterTts = FlutterTts();
  
  int _currentStep = 0;
  String? _selectedCategory;
  String? _selectedIssue;
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final List<String> _imagePaths = [];
  bool _isSpeaking = false;
  bool _showContent = false;
  bool _isSubmitting = false;
  bool _showSuccess = false;

  static final Map<String, List<String>> supportIssues = {
    'Account & Login Issues': [
      'Unable to log in',
      'OTP not received',
      'Forgot password',
      'Account temporarily blocked',
      'ID verification failed',
      'Profile not approved',
      'Wrong phone number linked',
      'Cannot update personal details',
    ],
    'App & Technical Issues': [
      'App is crashing',
      'App is not loading jobs',
      'GPS not working',
      'Map not showing correct route',
      'Buttons not responding',
      'Notification not coming',
      'Timer not working on job requests',
      'Job request popups not appearing',
      'Cannot go online/offline',
      'UI freezing during active job',
    ],
    'Job Request Issues': [
      'Job request disappeared',
      'Timer ended too fast',
      'Wrong job details shown',
      'Job request repeated',
      'Received multiple job requests at once',
      'Payment amount not visible',
      'Customer location missing',
      'Address not loading properly',
    ],
    'Navigation & Location Issues': [
      'Location inaccurate',
      'Cannot start trip/pickup',
      'Map shows wrong direction',
      'Distance not calculated properly',
      'Cannot reach location shown',
      'GPS weak signal warning',
    ],
    'Pickup & Waste Collection Issues': [
      'Waste is not ready at customer location',
      'Customer not available',
      'Wrong waste type mentioned',
      'Large pickup but small payment',
      'Hazardous waste issue',
      'Need extra tools for collection',
      'Cannot access customer\'s building/area',
      'Location too far from selected region',
      'Waste not matching job description',
    ],
    'Payment Issues': [
      'Payment not received',
      'Wrong payment amount',
      'Payment pending too long',
      'Earnings not updated',
      'Weekly/monthly statement missing',
      'Incentives/rewards not credited',
      'Bonus not applied',
    ],
    'Active Job Issues': [
      'Cannot start job',
      'Cannot complete job',
      'Photo upload for completion failing',
      'Timer issue',
      'Job stuck in "In-Progress"',
      'Job details not opening',
      'App stuck after accepting job',
    ],
    'Vehicle Issues': [
      'Vehicle breakdown',
      'Flat tire',
      'Cannot continue job due to mechanical issue',
      'Insurance/RC upload issue',
      'Vehicle documents rejected',
    ],
    'Safety & Emergency Issues': [
      'Customer misbehaviour',
      'Safety concern in area',
      'Hazardous material found',
      'Severe weather issues',
      'Accident during job',
      'Need emergency support',
    ],
    'General Support': [
      'Need help using the app',
      'How payments work',
      'How ratings work',
      'How incentives work',
      'How to complete jobs properly',
      'How to upload photos',
      'How to manage online/offline mode',
    ],
  };

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _initTts();
    _speakForStep(0);
  }

  Future<void> _initTts() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setVoice({"name": "Karen", "locale": "en-AU"});
    await flutterTts.setPitch(1.1);
    await flutterTts.setSpeechRate(0.9);
    flutterTts.setStartHandler(() {
      setState(() => _isSpeaking = true);
    });
    flutterTts.setCompletionHandler(() {
      setState(() {
        _isSpeaking = false;
        _showContent = true;
      });
      _fadeController.forward();
    });
  }

  Future<void> _speakForStep(int step) async {
    await flutterTts.stop();
    setState(() => _showContent = false);
    _fadeController.reset();
    String message = '';
    switch (step) {
      case 0:
        message = "Hi! I'm your driver support assistant. Please click get started to begin.";
        break;
      case 1:
        message = "Great! Now select an issue category.";
        break;
      case 2:
        message = "Perfect! Choose the exact issue you're facing.";
        break;
      case 3:
        message = "Alright! Please enter the details and upload photos if needed.";
        break;
      case 4:
        message = "Your support request has been submitted successfully. You will get a response soon.";
        break;
    }
    await flutterTts.speak(message);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    _rotateController.dispose();
    _descriptionController.dispose();
    flutterTts.stop();
    super.dispose();
  }

  void _nextStep() {
    setState(() => _currentStep++);
    _speakForStep(_currentStep);
  }

  void _previousStep() {
    setState(() => _currentStep--);
    _speakForStep(_currentStep);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWeb = kIsWeb && width > 900;
    
    if (isWeb) {
      return buildWebLayout();
    }
    return buildMobileLayout();
  }

  Widget buildWebLayout() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1419) : const Color(0xFFE8F5E9),
      body: Stack(
        children: [
          Positioned(
            top: 20,
            left: 20,
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black87),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Center(child: _buildMainContent(context, isDark)),
        ],
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, bool isDark) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 900;
    
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: _currentStep == 0 ? MainAxisAlignment.center : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: _currentStep == 0 ? (isMobile ? 100 : MediaQuery.of(context).size.height * 0.2) : 60),
          if (_currentStep == 0)
            Center(
              child: Text(
                'Driver Support Assistant',
                style: TextStyle(
                  fontSize: isMobile ? 24 : 32,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          SizedBox(height: _currentStep == 0 ? 40 : 20),
          Center(child: _buildAIBall()),
          const SizedBox(height: 40),
          if (_showContent && _currentStep == 0) Center(child: _buildContentBox(isDark)),
          if (_showContent && _currentStep > 0) Center(child: _buildIssueCards(isDark)),
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  Widget _buildAIBall() {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseController, _rotateController]),
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotateController.value * 6.28,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF00E676),
                  const Color(0xFF00E676).withOpacity(0.6),
                  const Color(0xFF00E676).withOpacity(0.3),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00E676).withOpacity(0.6 * _pulseController.value),
                  blurRadius: 40 + (20 * _pulseController.value),
                  spreadRadius: 10 * _pulseController.value,
                ),
              ],
            ),
            child: Transform.rotate(
              angle: -_rotateController.value * 6.28,
              child: Icon(
                _showSuccess ? Icons.check_circle : Icons.support_agent,
                color: Colors.white,
                size: 60,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContentBox(bool isDark) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 900;
    
    return FadeTransition(
      opacity: _fadeController,
      child: Container(
        width: isMobile ? width - 48 : 500,
        constraints: BoxConstraints(maxWidth: isMobile ? width - 48 : 500),
        padding: EdgeInsets.all(isMobile ? 24 : 32),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A1A).withOpacity(0.95) : Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFF00E676).withOpacity(0.3), width: 1.5),
          boxShadow: [
            BoxShadow(color: const Color(0xFF00E676).withOpacity(0.2), blurRadius: 40),
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10)),
          ],
        ),
        child: _buildStepContent(context, isDark),
      ),
    );
  }

  Widget _buildIssueCards(bool isDark) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 900;
    
    return FadeTransition(
      opacity: _fadeController,
      child: Container(
        width: isMobile ? width - 32 : 700,
        constraints: BoxConstraints(maxWidth: isMobile ? width - 32 : 700),
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 0),
        child: _buildStepContent(context, isDark),
      ),
    );
  }

  Widget _buildStepContent(BuildContext context, bool isDark) {
    switch (_currentStep) {
      case 0:
        return _buildGreeting(isDark);
      case 1:
        return _buildCategorySelection(isDark);
      case 2:
        return _buildSubIssueSelection(isDark);
      case 3:
        return _buildDetailsForm(isDark);
      case 4:
        return _buildSuccessMessage(isDark);
      default:
        return _buildGreeting(isDark);
    }
  }

  Widget _buildGreeting(bool isDark) {
    return Column(
      children: [
        const Icon(Icons.waving_hand, size: 64, color: Color(0xFF00E676)),
        const SizedBox(height: 24),
        Text(
          'Welcome Driver!',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _nextStep,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00E676),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Get Started', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySelection(bool isDark) {
    final categories = supportIssues.keys.toList();
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: categories.asMap().entries.map((entry) {
        final index = entry.key;
        final category = entry.value;
        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 400 + (index * 100)),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Opacity(
                opacity: value,
                child: InkWell(
                  onTap: () {
                    setState(() => _selectedCategory = category);
                    _nextStep();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1A1A1A).withOpacity(0.95) : Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF00E676).withOpacity(0.3), width: 1.5),
                      boxShadow: [
                        BoxShadow(color: const Color(0xFF00E676).withOpacity(0.1), blurRadius: 20),
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildSubIssueSelection(bool isDark) {
    final issues = supportIssues[_selectedCategory] ?? [];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: issues.asMap().entries.map((entry) {
            final index = entry.key;
            final issue = entry.value;
            return TweenAnimationBuilder<double>(
              duration: Duration(milliseconds: 400 + (index * 100)),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Opacity(
                    opacity: value,
                    child: InkWell(
                      onTap: () {
                        setState(() => _selectedIssue = issue);
                        _nextStep();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1A1A1A).withOpacity(0.95) : Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF00E676).withOpacity(0.3), width: 1.5),
                          boxShadow: [
                            BoxShadow(color: const Color(0xFF00E676).withOpacity(0.1), blurRadius: 20),
                            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: Text(
                          issue,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        TextButton(
          onPressed: _previousStep,
          child: const Text('← Back', style: TextStyle(color: Color(0xFF00E676), fontSize: 14)),
        ),
      ],
    );
  }

  Widget _buildCategoriesGrid(ThemeData theme) {
    return Column(
      key: const ValueKey('categories'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
            ),
            const SizedBox(width: 12),
            const Text(
              'Driver Support',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Select a category to get help',
          style: TextStyle(
            fontSize: 16,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 32),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: 1.3,
            ),
            itemCount: supportIssues.length,
            itemBuilder: (context, index) {
              final category = supportIssues.keys.elementAt(index);
              final issues = supportIssues[category]!;
              return _buildCategoryCard(theme, category, issues);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryCard(ThemeData theme, String category, List<String> issues) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedCategory = category;
          });
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getCategoryIcon(category),
                    color: theme.colorScheme.primary,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  category,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${issues.length} issues',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black45,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIssuesList(ThemeData theme) {
    final issues = supportIssues[_selectedCategory]!;

    return Column(
      key: const ValueKey('issues'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () {
                setState(() {
                  _selectedCategory = null;
                });
              },
              icon: const Icon(Icons.arrow_back),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedCategory!,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    'Select an issue',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Expanded(
          child: ListView.builder(
            itemCount: issues.length,
            itemBuilder: (context, index) {
              final issue = issues[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  leading: Icon(
                    Icons.error_outline,
                    color: theme.colorScheme.primary,
                  ),
                  title: Text(
                    issue,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    setState(() {
                      _selectedIssue = issue;
                    });
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsForm(bool isDark) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * value),
          child: Opacity(
            opacity: value,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A1A1A).withOpacity(0.95) : Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF00E676).withOpacity(0.3), width: 1.5),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF00E676).withOpacity(0.1), blurRadius: 20),
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _descriptionController,
                    maxLines: 3,
                    textAlign: TextAlign.left,
                    decoration: InputDecoration(
                      hintText: 'Describe your issue...',
                      filled: true,
                      fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF00E676), width: 2),
                      ),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text('Upload Photos (Optional)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black87)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      if (_imagePaths.isNotEmpty)
                        ...(_imagePaths.asMap().entries.map((entry) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: Stack(
                              children: [
                                ClipRRect(borderRadius: BorderRadius.circular(8), child: Container(width: 50, height: 50, color: Colors.grey)),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: () => setState(() => _imagePaths.removeAt(entry.key)),
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                      child: const Icon(Icons.close, color: Colors.white, size: 10),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList()),
                      if (_imagePaths.length < 3)
                        GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              border: Border.all(color: const Color(0xFF00E676).withOpacity(0.5), width: 2),
                              borderRadius: BorderRadius.circular(8),
                              color: const Color(0xFF00E676).withOpacity(0.05),
                            ),
                            child: const Icon(Icons.add_photo_alternate, color: Color(0xFF00E676), size: 20),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: _previousStep,
                          style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 10)),
                          child: const Text('← Back', style: TextStyle(color: Color(0xFF00E676), fontSize: 12)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: _submitRequest,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00E676),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Submit', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSuccessMessage(bool isDark) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(
            opacity: value,
            child: Column(
              children: [
                const Icon(Icons.check_circle, size: 80, color: Color(0xFF00E676)),
                const SizedBox(height: 24),
                Text(
                  'Request Submitted!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'You will get a response soon.',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _submitRequest() {
    _rotateController.forward().then((_) {
      setState(() => _showSuccess = true);
      Future.delayed(const Duration(milliseconds: 800), () {
        _rotateController.reverse().then((_) {
          setState(() {
            _showSuccess = false;
            _currentStep = 4;
          });
          _speakForStep(4);
          
          Future.delayed(const Duration(seconds: 3), () {
            setState(() {
              _currentStep = 0;
              _selectedCategory = null;
              _selectedIssue = null;
              _descriptionController.clear();
              _imagePaths.clear();
            });
            _speakForStep(0);
          });
        });
      });
    });
  }

  Widget _buildIssueForm(ThemeData theme) {
    return SingleChildScrollView(
      key: const ValueKey('form'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _selectedIssue = null;
                    _descriptionController.clear();
                    _imagePaths.clear();
                  });
                },
                icon: const Icon(Icons.arrow_back),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Submit Support Request',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Issue Category',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _selectedCategory!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Selected Issue',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: theme.colorScheme.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _selectedIssue!,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Describe Your Issue',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Please provide detailed information about the issue',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 6,
                    decoration: InputDecoration(
                      hintText: 'Describe the issue in detail...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please describe your issue';
                      }
                      if (value.trim().length < 10) {
                        return 'Please provide more details (at least 10 characters)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Attach Photos (Optional)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Add up to 3 photos to help us understand the issue',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_imagePaths.isNotEmpty)
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: _imagePaths.asMap().entries.map((entry) {
                        return Stack(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.image,
                                size: 40,
                                color: Colors.grey.shade400,
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () => _removeImage(entry.key),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  if (_imagePaths.isNotEmpty) const SizedBox(height: 12),
                  if (_imagePaths.length < 3)
                    OutlinedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.add_photo_alternate),
                      label: Text('Add Photo (${_imagePaths.length}/3)'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isSubmitting ? null : _submitComplaint,
                      icon: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.send),
                      label: Text(_isSubmitting ? 'Submitting...' : 'Submit Support Request'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    if (_imagePaths.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum 3 images allowed')),
      );
      return;
    }

    try {
      // Use file_picker for web to select from local device
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _imagePaths.add(result.files.first.name);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _imagePaths.removeAt(index);
    });
  }

  Future<void> _submitComplaint() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isSubmitting = false;
        _selectedCategory = null;
        _selectedIssue = null;
        _descriptionController.clear();
        _imagePaths.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Support request submitted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Widget buildMobileLayout() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1419) : const Color(0xFFE8F5E9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _buildMainContent(context, isDark),
    );
  }

  Widget _buildMobileCategoryCard(BuildContext context, ThemeData theme, String category, List<String> issues) {
    return CustomCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(_getCategoryIcon(category), color: theme.colorScheme.primary, size: 28),
        title: Text(
          category,
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${issues.length} issues', style: theme.textTheme.bodySmall),
        children: issues.map((issue) {
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 4),
            title: Text(issue, style: const TextStyle(fontSize: 14)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DriverSupportDetailScreen(category: category, issue: issue),
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    if (category.contains('Account')) return Icons.account_circle;
    if (category.contains('App')) return Icons.phone_android;
    if (category.contains('Job Request')) return Icons.work;
    if (category.contains('Navigation')) return Icons.navigation;
    if (category.contains('Pickup')) return Icons.delete;
    if (category.contains('Payment')) return Icons.payment;
    if (category.contains('Active Job')) return Icons.work_history;
    if (category.contains('Vehicle')) return Icons.local_shipping;
    if (category.contains('Safety')) return Icons.warning;
    return Icons.help;
  }
}
