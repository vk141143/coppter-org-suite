import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class SupportTwoPanelWeb extends StatefulWidget {
  const SupportTwoPanelWeb({super.key});

  @override
  State<SupportTwoPanelWeb> createState() => _SupportTwoPanelWebState();
}

class _SupportTwoPanelWebState extends State<SupportTwoPanelWeb>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late AnimationController _rotateController;
  final FlutterTts flutterTts = FlutterTts();
  
  int _currentStep = 0;
  String? _selectedCategory;
  String? _selectedIssue;
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  bool _isSpeaking = false;
  bool _showContent = false;
  final List<File> _images = [];
  bool _showSuccess = false;

  static final Map<String, List<String>> supportIssues = {
    'Account & Login Issues': ['Cannot log in', 'OTP not received', 'Forgot password', 'Email/phone number not updating'],
    'Waste Pickup Booking': ['Unable to raise request', 'Cannot select category', 'Cannot upload images'],
    'Tracking & Status': ['Status stuck at Pending', 'Driver not assigned', 'Driver taking too long'],
    'Payment & Billing': ['Payment failed', 'Charged incorrectly', 'Extra charges added', 'Refund not received'],
    'App & Technical': ['App crashing', 'App is slow', 'Buttons not working', 'Camera not opening'],
    'Location & Address': ['Cannot add address', 'Wrong address showing', 'GPS inaccurate'],
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
    await flutterTts.setSpeechRate(1.0);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);
    
    flutterTts.setStartHandler(() {
      if (mounted) setState(() => _isSpeaking = true);
    });
    flutterTts.setCompletionHandler(() {
      if (mounted) {
        setState(() {
          _isSpeaking = false;
          _showContent = true;
        });
        _fadeController.forward();
      }
    });
    flutterTts.setErrorHandler((msg) {
      if (mounted) setState(() => _isSpeaking = false);
    });
  }

  Future<void> _speakForStep(int step) async {
    await flutterTts.stop();
    setState(() => _showContent = false);
    _fadeController.reset();
    String message = '';
    switch (step) {
      case 0:
        message = "Hi! I'm your support assistant. Please click get started to begin.";
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
    _contactController.dispose();
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

  Future<void> _pickImage() async {
    if (_images.length >= 3) return;
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) setState(() => _images.add(File(pickedFile.path)));
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
              _contactController.clear();
              _images.clear();
            });
            _speakForStep(0);
          });
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1419) : const Color(0xFFE8F5E9),
      body: Stack(
        children: [
          ..._buildFloatingLeaves(),
          Positioned(
            top: 20,
            left: 20,
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black87),
              onPressed: () {
                flutterTts.stop();
                Navigator.pop(context);
              },
            ),
          ),
          Center(child: _buildMainContent(context, isDark)),
        ],
      ),
    );
  }

  List<Widget> _buildFloatingLeaves() {
    return List.generate(5, (index) {
      return TweenAnimationBuilder(
        duration: Duration(seconds: 10 + index * 2),
        tween: Tween<double>(begin: -100, end: 1000),
        builder: (context, double value, child) {
          return Positioned(
            top: value,
            left: 100.0 + (index * 200),
            child: Opacity(
              opacity: 0.05,
              child: Icon(
                index % 2 == 0 ? Icons.eco : Icons.recycling,
                size: 40,
                color: const Color(0xFF00E676),
              ),
            ),
          );
        },
        onEnd: () => setState(() {}),
      );
    });
  }

  Widget _buildMainContent(BuildContext context, bool isDark) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: _currentStep == 0 ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: [
          SizedBox(height: _currentStep == 0 ? MediaQuery.of(context).size.height * 0.2 : 60),
          if (_currentStep == 0)
            Text(
              'Support Assistant',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          SizedBox(height: _currentStep == 0 ? 40 : 20),
          _buildAIBall(),
          const SizedBox(height: 40),
          if (_showContent && _currentStep == 0) _buildContentBox(isDark),
          if (_showContent && _currentStep > 0) _buildIssueCards(isDark),
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
    return FadeTransition(
      opacity: _fadeController,
      child: Container(
        width: 500,
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(32),
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
    return FadeTransition(
      opacity: _fadeController,
      child: Container(
        width: 700,
        constraints: const BoxConstraints(maxWidth: 700),
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
          'Welcome!',
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
                  TextField(
                    controller: _contactController,
                    textAlign: TextAlign.left,
                    decoration: InputDecoration(
                      hintText: 'Contact info (email/phone)',
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
                      if (_images.isNotEmpty)
                        ...(_images.asMap().entries.map((entry) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: Stack(
                              children: [
                                ClipRRect(borderRadius: BorderRadius.circular(8), child: Container(width: 50, height: 50, color: Colors.grey)),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: () => setState(() => _images.removeAt(entry.key)),
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
                      if (_images.length < 3)
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
}
