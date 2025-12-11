import 'package:flutter/material.dart';
import '../../../shared/widgets/custom_card.dart';
import 'customer_support_detail_screen.dart';

class CustomerSupportMobile extends StatelessWidget {
  const CustomerSupportMobile({super.key});

  static final Map<String, List<String>> supportIssues = {
    'Account & Login Issues': [
      'Cannot log in',
      'OTP not received',
      'Forgot password',
      'Email/phone number not updating',
      'Account verification pending',
      'Profile details incorrect',
      'Unable to delete account',
    ],
    'Waste Pickup Booking Issues': [
      'Unable to raise a new complaint',
      'Cannot select waste category',
      'Cannot upload images',
      'Location not detecting',
      'Pickup slot not available',
      'Pickup request not submitting',
    ],
    'Tracking & Status Issues': [
      'Pickup status stuck at "Pending"',
      'Driver not assigned',
      'Driver taking too long',
      'Pickup delayed',
      'Wrong ETA shown',
      'Not receiving notifications',
      'Cannot track driver location',
    ],
    'Waste Collection Issues': [
      'Driver did not arrive',
      'Driver left without collecting',
      'Driver collected only partial waste',
      'Driver refused to collect',
      'Waste not cleaned properly',
      'Wrong charges added',
      'Incorrect waste category assigned',
      'Hazardous waste handling issue',
    ],
    'Payment & Billing Issues': [
      'Payment failed',
      'Charged incorrectly',
      'Extra charges added',
      'Refund not received',
      'Coupon/discount not applied',
      'Wrong bill shown',
      'Unable to download bill/invoice',
    ],
    'App & Technical Issues': [
      'App crashing',
      'App is slow',
      'Buttons not working',
      'Camera not opening',
      'Map not loading',
      'Images not uploading',
      'Dark/light theme issues',
    ],
    'Location & Address Issues': [
      'Cannot add address',
      'Wrong address showing',
      'GPS inaccurate',
      'Cannot change saved address',
      'Pickup location outside service area',
    ],
    'Safety & Behaviour Issues': [
      'Driver rude or misbehaving',
      'Driver asked for extra money',
      'Driver irresponsible handling of waste',
      'Driver violated safety protocols',
      'Waste left scattered after pickup',
    ],
    'Complaint History & Records': [
      'Cannot see past complaints',
      'Wrong details in history',
      'Completed job not showing',
      'Images not loading in history',
    ],
    'Notifications & Alerts': [
      'Not receiving notifications',
      'Getting too many notifications',
      'Sound/vibration issues',
      'Notification settings not saving',
    ],
    'Feedback & Suggestions': [
      'Report issues with app features',
      'Request new feature',
      'Suggest improvement',
      'Provide rating/feedback',
    ],
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Support'),
        elevation: 0,
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
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: supportIssues.length,
          itemBuilder: (context, index) {
            final category = supportIssues.keys.elementAt(index);
            final issues = supportIssues[category]!;
            return _buildCategoryCard(context, theme, category, issues);
          },
        ),
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, ThemeData theme, String category, List<String> issues) {
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
                  builder: (context) => CustomerSupportDetailScreen(category: category, issue: issue),
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
    if (category.contains('Booking')) return Icons.add_circle;
    if (category.contains('Tracking')) return Icons.location_on;
    if (category.contains('Collection')) return Icons.delete;
    if (category.contains('Payment')) return Icons.payment;
    if (category.contains('App')) return Icons.phone_android;
    if (category.contains('Location')) return Icons.map;
    if (category.contains('Safety')) return Icons.warning;
    if (category.contains('History')) return Icons.history;
    if (category.contains('Notifications')) return Icons.notifications;
    return Icons.feedback;
  }
}
