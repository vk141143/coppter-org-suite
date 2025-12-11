import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../complaint_history/screens/complaint_history_mobile.dart';
import '../../complaint_history/screens/complaint_history_web.dart';

class ComplaintHistoryScreen extends StatelessWidget {
  const ComplaintHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    // Use Web version ONLY for web platform with large screens
    if (kIsWeb && width > 900) {
      return const ComplaintHistoryWeb();
    }
    
    // Mobile version for all mobile apps and small web screens
    return const ComplaintHistoryMobile();
  }
}
