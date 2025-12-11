import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'support_two_panel_web.dart';

class CustomerSupportScreen extends StatelessWidget {
  const CustomerSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Use voice assistant for both web and mobile
    return const SupportTwoPanelWeb();
  }
}
