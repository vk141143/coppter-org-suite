import 'package:flutter/material.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        elevation: 0,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildContactCard(theme, Icons.email, 'Email Us', 'support@wastemanagement.com', () {}),
            const SizedBox(height: 12),
            _buildContactCard(theme, Icons.phone, 'Call Us', '+1 800 123 4567', () {}),
            const SizedBox(height: 12),
            _buildContactCard(theme, Icons.chat, 'Live Chat', 'Chat with our team', () {}),
            const SizedBox(height: 24),
            Text('Frequently Asked Questions', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildFAQ(theme, 'How do I schedule a pickup?', 'Go to the dashboard and tap on "Raise Issue" to schedule a new pickup.'),
            _buildFAQ(theme, 'How can I track my pickup?', 'Use the "Track Pickup" option from the dashboard to see real-time status.'),
            _buildFAQ(theme, 'What types of waste do you collect?', 'We collect household waste, recyclables, garden waste, e-waste, and more.'),
            _buildFAQ(theme, 'How do I change my address?', 'Go to Profile > Address and tap the edit button to update your address.'),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(ThemeData theme, IconData icon, String title, String subtitle, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: theme.colorScheme.primary, size: 24),
        ),
        title: Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6))),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: theme.colorScheme.onSurface.withOpacity(0.4)),
        onTap: onTap,
      ),
    );
  }

  Widget _buildFAQ(ThemeData theme, String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(answer, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7))),
        ],
      ),
    );
  }
}
