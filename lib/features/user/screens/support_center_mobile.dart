import 'package:flutter/material.dart';
import 'support_category_detail_screen.dart';

class SupportCenterMobile extends StatefulWidget {
  const SupportCenterMobile({super.key});

  @override
  State<SupportCenterMobile> createState() => _SupportCenterMobileState();
}

class _SupportCenterMobileState extends State<SupportCenterMobile> {
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
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: const Color(0xFF1B5E20),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('How can we help you?', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white)),
                        const SizedBox(height: 8),
                        Text('Search issues or browse categories', style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.9))),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 4))],
                    ),
                    child: TextField(
                      onChanged: (value) => setState(() => _searchQuery = value),
                      decoration: InputDecoration(
                        hintText: 'Search for help...',
                        prefixIcon: const Icon(Icons.search, color: Color(0xFF1B5E20)),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(child: _buildQuickAction(context, Icons.report_problem, 'Report Issue', () {})),
                      const SizedBox(width: 12),
                      Expanded(child: _buildQuickAction(context, Icons.track_changes, 'Track Request', () {})),
                      const SizedBox(width: 12),
                      Expanded(child: _buildQuickAction(context, Icons.chat_bubble, 'Chat', () {})),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Browse Categories', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: isDark ? Colors.white : const Color(0xFF212121))),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final entry = categories[index];
                  return _buildCategoryCard(context, isDark, entry.key, entry.value);
                },
                childCount: categories.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }

  Widget _buildQuickAction(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF1B5E20), size: 28),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF212121)), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, bool isDark, String category, List<String> issues) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SupportCategoryDetailScreen(category: category, issues: issues))),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFF76FF03).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(_getCategoryIcon(category), color: const Color(0xFF1B5E20), size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(category, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: isDark ? Colors.white : const Color(0xFF212121))),
                      const SizedBox(height: 4),
                      Text('${issues.length} topics', style: TextStyle(fontSize: 13, color: isDark ? Colors.white60 : const Color(0xFF757575))),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, size: 16, color: isDark ? Colors.white38 : Colors.black38),
              ],
            ),
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
