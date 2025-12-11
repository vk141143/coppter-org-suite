import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../track_complaint/screens/track_complaint_mobile.dart';
import '../../track_complaint/screens/track_complaint_web.dart';

class TrackComplaintScreen extends StatelessWidget {
  const TrackComplaintScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    // Use Web version ONLY for web platform with large screens
    if (kIsWeb && width > 900) {
      return const TrackComplaintWeb();
    }
    
    // Mobile version for all mobile apps and small web screens
    return const TrackComplaintMobile();
  }
}
