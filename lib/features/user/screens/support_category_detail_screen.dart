import 'package:flutter/material.dart';
import 'support_issue_detail_screen.dart';

class SupportCategoryDetailScreen extends StatelessWidget {
  final String category;
  final List<String> issues;

  const SupportCategoryDetailScreen({
    super.key,
    required this.category,
    required this.issues,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      appBar: AppBar(
        title: Text(category),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: issues.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SupportIssueDetailScreen(category: category, issue: issues[index]))),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF76FF03).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.help_outline, color: Color(0xFF1B5E20), size: 20),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(issues[index], style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF212121))),
                      ),
                      Icon(Icons.arrow_forward_ios, size: 14, color: isDark ? Colors.white38 : Colors.black38),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
