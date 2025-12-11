import 'package:flutter/material.dart';

class CustomerSupportWeb extends StatefulWidget {
  const CustomerSupportWeb({super.key});

  @override
  State<CustomerSupportWeb> createState() => _CustomerSupportWebState();
}

class _CustomerSupportWebState extends State<CustomerSupportWeb>
    with TickerProviderStateMixin {
  late AnimationController _dotController;
  late AnimationController _fadeController;
  
  int _currentStep = 0;
  String? _selectedCategory;
  String? _selectedIssue;
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();

  static final Map<String, List<String>> supportIssues = {
    'Account & Login Issues': ['Cannot log in', 'OTP not received', 'Forgot password', 'Email/phone number not updating'],
    'Waste Pickup Booking Issues': ['Unable to raise a new complaint', 'Cannot select waste category', 'Cannot upload images'],
    'Tracking & Status Issues': ['Pickup status stuck at \"Pending\"', 'Driver not assigned', 'Driver taking too long'],
    'Payment & Billing Issues': ['Payment failed', 'Charged incorrectly', 'Extra charges added', 'Refund not received'],
    'App & Technical Issues': ['App crashing', 'App is slow', 'Buttons not working', 'Camera not opening'],
    'Location & Address Issues': ['Cannot add address', 'Wrong address showing', 'GPS inaccurate'],
    'Safety & Behaviour Issues': ['Driver rude or misbehaving', 'Driver asked for extra money'],
    'Complaint History & Records': ['Cannot see past complaints', 'Wrong details in history'],
    'Notifications & Alerts': ['Not receiving notifications', 'Getting too many notifications'],
    'Feedback & Suggestions': ['Report issues with app features', 'Request new feature'],
  };

  @override
  void initState() {
    super.initState();
    _dotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _dotController.dispose();
    _fadeController.dispose();
    _descriptionController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  void _nextStep() {
    _fadeController.reset();
    setState(() => _currentStep++);
    _fadeController.forward();
  }

  void _previousStep() {
    _fadeController.reset();
    setState(() => _currentStep--);
    _fadeController.forward();
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
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Center(child: _buildAssistantBox(context, isDark)),
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

  Widget _buildAssistantBox(BuildContext context, bool isDark) {
    return Container(
      width: 420,
      constraints: const BoxConstraints(maxWidth: 420),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildAnimatedDots(),
          const SizedBox(height: 24),
          FadeTransition(
            opacity: _fadeController,
            child: SlideTransition(
              position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(_fadeController),
              child: _buildStepContent(context, isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedDots() {
    return AnimatedBuilder(
      animation: _dotController,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            final offset = (index * 0.33);
            final value = (_dotController.value + offset) % 1.0;
            final scale = 1.0 + (0.5 * (0.5 - (value - 0.5).abs()) * 2);
            
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 12,
              height: 12 * scale,
              decoration: BoxDecoration(
                color: const Color(0xFF00E676),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: const Color(0xFF00E676).withOpacity(0.6), blurRadius: 8 * scale, spreadRadius: 2),
                ],
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildStepContent(BuildContext context, bool isDark) {
    switch (_currentStep) {
      case 0: return _buildGreeting(isDark);
      case 1: return _buildCategorySelection(isDark);
      case 2: return _buildSubIssueSelection(isDark);
      case 3: return _buildDetailsForm(isDark);
      default: return _buildGreeting(isDark);
    }
  }

  Widget _buildGreeting(bool isDark) {
    return Column(
      children: [
        Text('Hi! I\'m your Support Assistant 👋', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: isDark ? Colors.white : Colors.black87), textAlign: TextAlign.center),
        const SizedBox(height: 12),
        Text('Please choose an issue category below.', style: TextStyle(fontSize: 14, color: isDark ? Colors.white70 : Colors.black54), textAlign: TextAlign.center),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _nextStep,
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00E676), foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          child: const Text('Get Started', style: TextStyle(fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  Widget _buildCategorySelection(bool isDark) {
    return Column(
      children: [
        Text('Choose an issue category', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: isDark ? Colors.white : Colors.black87), textAlign: TextAlign.center),
        const SizedBox(height: 20),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: supportIssues.keys.map((category) {
            return InkWell(
              onTap: () {
                setState(() => _selectedCategory = category);
                _nextStep();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF00E676).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF00E676).withOpacity(0.3)),
                ),
                child: Text(category, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black87)),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSubIssueSelection(bool isDark) {
    final issues = supportIssues[_selectedCategory] ?? [];
    return Column(
      children: [
        Text('Great! Now choose the exact issue.', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: isDark ? Colors.white : Colors.black87), textAlign: TextAlign.center),
        const SizedBox(height: 20),
        ...issues.map((issue) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: () {
                setState(() => _selectedIssue = issue);
                _nextStep();
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                child: Text(issue, style: TextStyle(fontSize: 13, color: isDark ? Colors.white : Colors.black87)),
              ),
            ),
          );
        }).toList(),
        const SizedBox(height: 12),
        TextButton(onPressed: _previousStep, child: const Text('← Back', style: TextStyle(color: Color(0xFF00E676)))),
      ],
    );
  }

  Widget _buildDetailsForm(bool isDark) {
    return Column(
      children: [
        Text('Got it! Please enter the details.', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: isDark ? Colors.white : Colors.black87), textAlign: TextAlign.center),
        const SizedBox(height: 20),
        TextField(
          controller: _descriptionController,
          maxLines: 3,
          decoration: InputDecoration(hintText: 'Describe your issue...', filled: true, fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100], border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _contactController,
          decoration: InputDecoration(hintText: 'Contact info (email/phone)', filled: true, fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100], border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(child: TextButton(onPressed: _previousStep, child: const Text('← Back', style: TextStyle(color: Color(0xFF00E676))))),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Support request submitted!')));
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00E676), foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text('Submit', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
