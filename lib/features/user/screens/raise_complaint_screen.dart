import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import '../../raise_complaint/screens/raise_complaint_mobile.dart';
import '../../raise_complaint/screens/raise_complaint_web.dart';

class RaiseComplaintScreen extends StatelessWidget {
  final XFile? image;
  
  const RaiseComplaintScreen({super.key, this.image});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    // Use Web version ONLY for web platform with large screens
    if (kIsWeb && width > 900) {
      return RaiseComplaintWeb(image: image);
    }
    
    // Mobile version for all mobile apps and small web screens
    return RaiseComplaintMobile(image: image);
  }
}
