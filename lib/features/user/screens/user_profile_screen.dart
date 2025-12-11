import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'user_profile_mobile.dart';
import 'user_profile_web.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (kIsWeb && width > 900) {
      return const UserProfileWeb();
    }
    
    return const UserProfileMobile();
  }
}
