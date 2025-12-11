import 'package:flutter/material.dart';
import 'support_detail_page.dart';

class SupportHierarchicalWeb extends StatefulWidget {
  const SupportHierarchicalWeb({super.key});

  @override
  State<SupportHierarchicalWeb> createState() => _SupportHierarchicalWebState();
}

class _SupportHierarchicalWebState extends State<SupportHierarchicalWeb> {
  String? _expandedCategory;
  String? _expandedIssue;

  static final Map<String, Map<String, List<String>>> supportData = {
    'Account & Login Issues': {
      'Cannot log in': ['Forgot password', 'Account locked', 'Wrong credentials', 'Email not verified'],
      'OTP not received': ['Delay from provider', 'Phone number not active', 'Check spam folder', 'Network issues'],
      'Forgot password': ['Reset via email', 'Reset via phone', 'Contact support'],
      'Email/phone number not updating': ['Verification pending', 'Already in use', 'Invalid format'],
      'Account verification pending': ['Check email', 'Resend verification', 'Contact support'],
      'Profile details incorrect': ['Update profile', 'Sync issues', 'Cache problem'],
      'Unable to delete account': ['Pending requests', 'Outstanding balance', 'Contact support'],
    },
    'Waste Pickup Booking Issues': {
      'Unable to raise a new request': ['App not responding', 'Server error', 'Network timeout'],
      'Cannot select waste category': ['Category unavailable', 'Service area issue', 'App bug'],
      'Cannot upload images': ['File size too large', 'Format not supported', 'Storage permission'],
      'Location not detecting': ['GPS disabled', 'Permission denied', 'Poor signal'],
      'Pickup slot not available': ['All slots booked', 'Service unavailable', 'Holiday schedule'],
      'Pickup request not submitting': ['Network error', 'Validation failed', 'Server issue'],
    },
    'Tracking & Status Issues': {
      'Pickup status stuck at Pending': ['Driver not assigned', 'System delay', 'Refresh status'],
      'Driver not assigned': ['High demand', 'Area unavailable', 'Contact support'],
      'Driver taking too long': ['Traffic delay', 'Multiple pickups', 'Track driver'],
      'Pickup delayed': ['Weather conditions', 'Vehicle breakdown', 'Rescheduling'],
      'Wrong ETA shown': ['GPS inaccuracy', 'Route changed', 'Refresh app'],
      'Not receiving notifications': ['Settings disabled', 'App permissions', 'Device issue'],
      'Cannot track driver location': ['GPS disabled', 'Driver offline', 'App issue'],
    },
    'Waste Collection Issues': {
      'Driver did not arrive': ['Wrong address', 'Cancelled pickup', 'Contact driver'],
      'Driver left without collecting': ['Access issue', 'Wrong location', 'Report issue'],
      'Driver collected only partial waste': ['Weight limit', 'Category mismatch', 'File complaint'],
      'Driver refused to collect': ['Hazardous waste', 'Not segregated', 'Policy violation'],
      'Waste not cleaned properly': ['Spillage', 'Incomplete pickup', 'Request cleanup'],
      'Wrong charges added': ['Pricing error', 'Extra fees', 'Request refund'],
      'Incorrect waste category assigned': ['Reclassification needed', 'Dispute category', 'Contact support'],
      'Hazardous waste handling issue': ['Special disposal', 'Safety concern', 'Report immediately'],
    },
    'Payment & Billing Issues': {
      'Payment failed': ['Insufficient funds', 'Card declined', 'Network error', 'Try again'],
      'Charged incorrectly': ['Wrong amount', 'Duplicate charge', 'Request refund'],
      'Extra charges added': ['Service fee', 'Late fee', 'Dispute charge'],
      'Refund not received': ['Processing time', 'Bank delay', 'Check status'],
      'Coupon/discount not applied': ['Expired code', 'Invalid code', 'Terms not met'],
      'Wrong bill shown': ['Calculation error', 'Old bill', 'Refresh billing'],
      'Unable to download bill/invoice': ['Server error', 'Format issue', 'Email invoice'],
    },
    'App & Technical Issues': {
      'App crashing': ['Update app', 'Clear cache', 'Reinstall app'],
      'App is slow': ['Poor network', 'Low storage', 'Background apps'],
      'Buttons not working': ['UI freeze', 'Touch issue', 'Restart app'],
      'Camera not opening': ['Permission denied', 'Camera in use', 'Device issue'],
      'Map not loading': ['Network error', 'GPS disabled', 'Refresh map'],
      'Images not uploading': ['File size', 'Format issue', 'Network problem'],
      'Dark/light theme issues': ['Cache problem', 'Update app', 'Reset settings'],
    },
  };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: const Color(0xFF1B5E20),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(48, 60, 48, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Support Center', style: TextStyle(fontSize: 48, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -1)),
                        const SizedBox(height: 8),
                        Text('Browse categories and find solutions', style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.9))),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(48),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final category = supportData.keys.elementAt(index);
                  final issues = supportData[category]!;
                  return _CategoryItem(
                    category: category,
                    issues: issues,
                    isExpanded: _expandedCategory == category,
                    expandedIssue: _expandedIssue,
                    onCategoryTap: () {
                      setState(() {
                        _expandedCategory = _expandedCategory == category ? null : category;
                        _expandedIssue = null;
                      });
                    },
                    onIssueTap: (issue) {
                      setState(() {
                        _expandedIssue = _expandedIssue == issue ? null : issue;
                      });
                    },
                    onSubIssueTap: (category, issue, subIssue) {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          transitionDuration: const Duration(milliseconds: 350),
                          pageBuilder: (_, animation, __) {
                            return FadeTransition(
                              opacity: animation,
                              child: SupportDetailPage(
                                category: category,
                                issue: issue,
                                subIssue: subIssue,
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
                childCount: supportData.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryItem extends StatefulWidget {
  final String category;
  final Map<String, List<String>> issues;
  final bool isExpanded;
  final String? expandedIssue;
  final VoidCallback onCategoryTap;
  final Function(String) onIssueTap;
  final Function(String, String, String) onSubIssueTap;

  const _CategoryItem({
    required this.category,
    required this.issues,
    required this.isExpanded,
    required this.expandedIssue,
    required this.onCategoryTap,
    required this.onIssueTap,
    required this.onSubIssueTap,
  });

  @override
  State<_CategoryItem> createState() => _CategoryItemState();
}

class _CategoryItemState extends State<_CategoryItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeInOutCubic,
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: widget.isExpanded ? const Color(0xFF1B5E20) : (_isHovered ? const Color(0xFF76FF03).withOpacity(0.3) : const Color(0xFFE2E8F0)),
            width: widget.isExpanded ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.isExpanded ? const Color(0xFF1B5E20).withOpacity(0.2) : Colors.black.withOpacity(_isHovered ? 0.08 : 0.04),
              blurRadius: _isHovered ? 20 : 10,
              offset: Offset(0, _isHovered ? 8 : 4),
            ),
          ],
        ),
        child: Column(
          children: [
            InkWell(
              onTap: widget.onCategoryTap,
              borderRadius: BorderRadius.circular(24),
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: widget.isExpanded ? [Color(0xFF1B5E20), Color(0xFF2E7D32)] : [Color(0xFF76FF03).withOpacity(0.2), Color(0xFF76FF03).withOpacity(0.1)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(_getCategoryIcon(widget.category), color: widget.isExpanded ? Colors.white : Color(0xFF1B5E20), size: 28),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.category, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: isDark ? Colors.white : const Color(0xFF212121))),
                          const SizedBox(height: 4),
                          Text('${widget.issues.length} issues', style: TextStyle(fontSize: 14, color: isDark ? Colors.white60 : const Color(0xFF757575))),
                        ],
                      ),
                    ),
                    AnimatedRotation(
                      turns: widget.isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 240),
                      child: Icon(Icons.keyboard_arrow_down, color: widget.isExpanded ? Color(0xFF1B5E20) : (isDark ? Colors.white60 : Color(0xFF757575)), size: 32),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOutCubic,
              child: widget.isExpanded
                  ? Column(
                      children: widget.issues.entries.map((entry) {
                        return _IssueItem(
                          category: widget.category,
                          issue: entry.key,
                          subIssues: entry.value,
                          isExpanded: widget.expandedIssue == entry.key,
                          onIssueTap: () => widget.onIssueTap(entry.key),
                          onSubIssueTap: (subIssue) => widget.onSubIssueTap(widget.category, entry.key, subIssue),
                        );
                      }).toList(),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    if (category.contains('Account')) return Icons.person;
    if (category.contains('Booking')) return Icons.add_circle;
    if (category.contains('Tracking')) return Icons.location_searching;
    if (category.contains('Collection')) return Icons.delete_sweep;
    if (category.contains('Payment')) return Icons.credit_card;
    if (category.contains('App')) return Icons.phone_android;
    return Icons.help_outline;
  }
}

class _IssueItem extends StatefulWidget {
  final String category;
  final String issue;
  final List<String> subIssues;
  final bool isExpanded;
  final VoidCallback onIssueTap;
  final Function(String) onSubIssueTap;

  const _IssueItem({
    required this.category,
    required this.issue,
    required this.subIssues,
    required this.isExpanded,
    required this.onIssueTap,
    required this.onSubIssueTap,
  });

  @override
  State<_IssueItem> createState() => _IssueItemState();
}

class _IssueItemState extends State<_IssueItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
        decoration: BoxDecoration(
          color: widget.isExpanded ? const Color(0xFF76FF03).withOpacity(0.1) : (_isHovered ? (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.02)) : Colors.transparent),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            InkWell(
              onTap: widget.onIssueTap,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: widget.isExpanded ? const Color(0xFF1B5E20) : const Color(0xFF76FF03).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.help_outline, color: widget.isExpanded ? Colors.white : Color(0xFF1B5E20), size: 20),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(widget.issue, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF212121))),
                    ),
                    AnimatedRotation(
                      turns: widget.isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(Icons.keyboard_arrow_down, color: isDark ? Colors.white60 : Color(0xFF757575), size: 24),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              child: widget.isExpanded
                  ? Padding(
                      padding: const EdgeInsets.only(left: 72, right: 16, bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: widget.subIssues.map((subIssue) {
                          return _SubIssueItem(
                            subIssue: subIssue,
                            onTap: () => widget.onSubIssueTap(subIssue),
                          );
                        }).toList(),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubIssueItem extends StatefulWidget {
  final String subIssue;
  final VoidCallback onTap;

  const _SubIssueItem({required this.subIssue, required this.onTap});

  @override
  State<_SubIssueItem> createState() => _SubIssueItemState();
}

class _SubIssueItemState extends State<_SubIssueItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: _isHovered ? const Color(0xFF1B5E20).withOpacity(0.1) : (isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.02)),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isHovered ? const Color(0xFF1B5E20).withOpacity(0.3) : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.arrow_forward, size: 16, color: _isHovered ? Color(0xFF1B5E20) : (isDark ? Colors.white60 : Color(0xFF757575))),
              const SizedBox(width: 12),
              Expanded(
                child: Text(widget.subIssue, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: isDark ? Colors.white : const Color(0xFF212121))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
