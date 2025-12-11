import 'package:flutter/material.dart';
import 'support_category_detail_screen.dart';

class SupportCenterWeb extends StatefulWidget {
  const SupportCenterWeb({super.key});

  @override
  State<SupportCenterWeb> createState() => _SupportCenterWebState();
}

class _SupportCenterWebState extends State<SupportCenterWeb> {
  String _searchQuery = '';

  static final Map<String, List<String>> supportIssues = {
    'Account & Login': ['Cannot log in', 'OTP not received', 'Forgot password', 'Email/phone not updating', 'Account verification pending', 'Profile details incorrect', 'Unable to delete account'],
    'Waste Pickup Booking': ['Unable to raise request', 'Cannot select category', 'Cannot upload images', 'Location not detecting', 'Pickup slot unavailable', 'Request not submitting'],
    'Tracking & Status': ['Status stuck at Pending', 'Driver not assigned', 'Driver taking too long', 'Pickup delayed', 'Wrong ETA shown', 'Not receiving notifications', 'Cannot track driver'],
    'Waste Collection': ['Driver did not arrive', 'Driver left without collecting', 'Partial waste collected', 'Driver refused collection', 'Waste not cleaned', 'Wrong charges', 'Incorrect category', 'Hazardous waste issue'],
    'Payment & Billing': ['Payment failed', 'Charged incorrectly', 'Extra charges', 'Refund not received', 'Coupon not applied', 'Wrong bill shown', 'Cannot download invoice'],
    'App & Technical': ['App crashing', 'App is slow', 'Buttons not working', 'Camera not opening', 'Map not loading', 'Images not uploading', 'Theme issues'],
    'Location & Address': ['Cannot add address', 'Wrong address showing', 'GPS inaccurate', 'Cannot change address', 'Outside service area'],
    'Safety & Behaviour': ['Driver rude', 'Driver asked extra money', 'Irresponsible handling', 'Safety protocols violated', 'Waste left scattered'],
    'Request History': ['Cannot see past requests', 'Wrong details in history', 'Completed job not showing', 'Images not loading'],
    'Notifications': ['Not receiving notifications', 'Too many notifications', 'Sound/vibration issues', 'Settings not saving'],
    'Feedback': ['Report app issues', 'Request new feature', 'Suggest improvement', 'Provide rating'],
  };

  List<MapEntry<String, List<String>>> get _filteredCategories {
    if (_searchQuery.isEmpty) return supportIssues.entries.toList();
    return supportIssues.entries.where((entry) {
      return entry.key.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          entry.value.any((issue) => issue.toLowerCase().contains(_searchQuery.toLowerCase()));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categories = _filteredCategories;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 48),
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)]),
              ),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.arrow_back, color: Colors.white),
                          ),
                          const Spacer(),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text('How can we help you?', style: TextStyle(fontSize: 48, fontWeight: FontWeight.w800, color: Colors.white), textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      Text('Search issues or browse categories below', style: TextStyle(fontSize: 18, color: Colors.white.withOpacity(0.9)), textAlign: TextAlign.center),
                      const SizedBox(height: 40),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 30, offset: const Offset(0, 10))],
                        ),
                        child: TextField(
                          onChanged: (value) => setState(() => _searchQuery = value),
                          decoration: const InputDecoration(
                            hintText: 'Search for help...',
                            hintStyle: TextStyle(fontSize: 18, color: Color(0xFF757575)),
                            prefixIcon: Icon(Icons.search, color: Color(0xFF1B5E20), size: 28),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                          ),
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(48),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: _buildQuickAction(context, isDark, Icons.report_problem, 'Report Issue', 'Submit a new support request', () {})),
                          const SizedBox(width: 24),
                          Expanded(child: _buildQuickAction(context, isDark, Icons.track_changes, 'Track Request', 'Check status of your requests', () {})),
                          const SizedBox(width: 24),
                          Expanded(child: _buildQuickAction(context, isDark, Icons.chat_bubble, 'Chat Support', 'Talk to our support team', () {})),
                        ],
                      ),
                      const SizedBox(height: 48),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Browse Categories', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: isDark ? Colors.white : const Color(0xFF212121))),
                      ),
                      const SizedBox(height: 32),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 24,
                          mainAxisSpacing: 24,
                          childAspectRatio: 1.5,
                        ),
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final entry = categories[index];
                          return _buildCategoryCard(context, isDark, entry.key, entry.value);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(BuildContext context, bool isDark, IconData icon, String title, String subtitle, VoidCallback onTap) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 4))],
          ),
          child: Column(
            children: [
              Icon(icon, color: const Color(0xFF1B5E20), size: 48),
              const SizedBox(height: 16),
              Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: isDark ? Colors.white : const Color(0xFF212121))),
              const SizedBox(height: 8),
              Text(subtitle, style: TextStyle(fontSize: 14, color: isDark ? Colors.white60 : const Color(0xFF757575)), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, bool isDark, String category, List<String> issues) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SupportCategoryDetailScreen(category: category, issues: issues))),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 4))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFF76FF03).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(_getCategoryIcon(category), color: const Color(0xFF1B5E20), size: 32),
              ),
              const SizedBox(height: 20),
              Text(category, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: isDark ? Colors.white : const Color(0xFF212121))),
              const SizedBox(height: 8),
              Text('${issues.length} topics', style: TextStyle(fontSize: 14, color: isDark ? Colors.white60 : const Color(0xFF757575))),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    if (category.contains('Account')) return Icons.person;
    if (category.contains('Booking')) return Icons.add_circle;
    if (category.contains('Tracking')) return Icons.location_searching;
    if (category.contains('Collection')) return Icons.delete_sweep;
    if (category.contains('Payment')) return Icons.credit_card;
    if (category.contains('App')) return Icons.phone_android;
    if (category.contains('Location')) return Icons.map;
    if (category.contains('Safety')) return Icons.security;
    if (category.contains('History')) return Icons.history;
    if (category.contains('Notifications')) return Icons.notifications;
    return Icons.feedback;
  }
}
