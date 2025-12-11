import 'package:flutter/material.dart';

class LanguageSettingsScreen extends StatefulWidget {
  const LanguageSettingsScreen({super.key});

  @override
  State<LanguageSettingsScreen> createState() => _LanguageSettingsScreenState();
}

class _LanguageSettingsScreenState extends State<LanguageSettingsScreen> {
  String _selectedLanguage = 'English';
  final List<Map<String, String>> _languages = [
    {'name': 'English', 'code': 'EN'},
    {'name': 'Spanish', 'code': 'ES'},
    {'name': 'French', 'code': 'FR'},
    {'name': 'German', 'code': 'DE'},
    {'name': 'Chinese', 'code': 'ZH'},
    {'name': 'Japanese', 'code': 'JA'},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Language'),
        elevation: 0,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _languages.length,
        itemBuilder: (context, index) {
          final lang = _languages[index];
          final isSelected = _selectedLanguage == lang['name'];
          
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? theme.colorScheme.primary : Colors.transparent,
                width: 2,
              ),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(lang['code']!, style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
              ),
              title: Text(lang['name']!, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
              trailing: isSelected ? Icon(Icons.check_circle, color: theme.colorScheme.primary) : null,
              onTap: () {
                setState(() => _selectedLanguage = lang['name']!);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Language changed to ${lang['name']}')),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
