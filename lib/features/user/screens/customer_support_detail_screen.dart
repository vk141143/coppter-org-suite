import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'customer_support_detail_mobile.dart';
import 'customer_support_detail_web.dart';

class CustomerSupportDetailScreen extends StatelessWidget {
  final String category;
  final String issue;

  const CustomerSupportDetailScreen({
    super.key,
    required this.category,
    required this.issue,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (kIsWeb || width > 900) {
      return CustomerSupportDetailWeb(category: category, issue: issue);
    }
    
    return CustomerSupportDetailMobile(category: category, issue: issue);
  }
}
