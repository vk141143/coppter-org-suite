import 'package:flutter/material.dart';
import '../widgets/web_status_timeline.dart';
import '../widgets/web_live_map.dart';
import '../widgets/web_eta_distance_cards.dart';
import '../widgets/cancel_animation.dart';
import '../widgets/payment_dialog.dart';
import '../widgets/payment_details_dialog.dart';
import '../../user/screens/user_dashboard.dart';

class TrackComplaintWeb extends StatefulWidget {
  const TrackComplaintWeb({super.key});

  @override
  State<TrackComplaintWeb> createState() => _TrackComplaintWebState();
}

class _TrackComplaintWebState extends State<TrackComplaintWeb> with TickerProviderStateMixin {
  int _currentStatus = 2;
  bool _showChatDrawer = false;
  double _currentPrice = 850.0;
  double _negotiatedPrice = 850.0;
  bool _isPaymentDone = false;
  String _transactionId = '';
  String _paymentDate = '';
  final _messageController = TextEditingController();
  
  AnimationController? _driverCardController;
  AnimationController? _otpController;
  AnimationController? _chatDrawerController;
  AnimationController? _priceController2;
  
  Animation<double>? _driverSlideAnim;
  Animation<double>? _driverFadeAnim;
  Animation<double>? _otpSlideAnim;
  Animation<double>? _otpFadeAnim;
  Animation<double>? _chatSlideAnim;
  Animation<double>? _chatFadeAnim;
  Animation<double>? _priceScaleAnim;

  @override
  void initState() {
    super.initState();
    
    _driverCardController = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    _otpController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _chatDrawerController = AnimationController(vsync: this, duration: const Duration(milliseconds: 250));
    _priceController2 = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    
    _driverSlideAnim = Tween<double>(begin: -50, end: 0).animate(CurvedAnimation(parent: _driverCardController!, curve: Curves.easeOutBack));
    _driverFadeAnim = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _driverCardController!, curve: Curves.easeOut));
    _otpSlideAnim = Tween<double>(begin: 30, end: 0).animate(CurvedAnimation(parent: _otpController!, curve: Curves.easeOutCubic));
    _otpFadeAnim = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _otpController!, curve: Curves.easeOut));
    _chatSlideAnim = Tween<double>(begin: 400, end: 0).animate(CurvedAnimation(parent: _chatDrawerController!, curve: Curves.easeOutCubic));
    _chatFadeAnim = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _chatDrawerController!, curve: Curves.easeOut));
    _priceScaleAnim = Tween<double>(begin: 0.8, end: 1).animate(CurvedAnimation(parent: _priceController2!, curve: Curves.elasticOut));
    
    _driverCardController!.forward();
    Future.delayed(const Duration(milliseconds: 100), () => _otpController!.forward());
  }

  @override
  void dispose() {
    _driverCardController?.dispose();
    _otpController?.dispose();
    _chatDrawerController?.dispose();
    _priceController2?.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
        ),
        title: const Text('Track Service'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: () => setState(() {}),
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Stack(
        children: [
          Container(
            color: theme.colorScheme.surface,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Panel (40%)
                  Expanded(
                    flex: 4,
                    child: Column(
                      children: [
                        // Driver Info
                        if (_currentStatus >= 1) _buildDriverInfo(theme),
                        
                        if (_currentStatus >= 1) const SizedBox(height: 24),
                        
                        // OTP Section
                        if (_currentStatus >= 2) _buildOTPSection(theme),
                      ],
                    ),
                  ),
                  
                  const SizedBox(width: 32),
                  
                  // Right Panel (60%)
                  Expanded(
                    flex: 6,
                    child: Column(
                      children: [
                        // Status Timeline
                        WebStatusTimeline(currentStatus: _currentStatus),
                        
                        const SizedBox(height: 24),
                        
                        // ETA & Distance Cards
                        if (_currentStatus >= 2) const WebEtaDistanceCards(),
                        
                        if (_currentStatus >= 2) const SizedBox(height: 24),
                        
                        // Live Map
                        if (_currentStatus >= 2) const WebLiveMap(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Chat Drawer
          if (_showChatDrawer) _buildChatDrawer(theme),
        ],
      ),
    );
  }

  Widget _buildDriverInfo(ThemeData theme) {
    if (_driverCardController == null) return const SizedBox();
    return AnimatedBuilder(
      animation: _driverCardController!,
      builder: (context, child) => Transform.translate(
        offset: Offset(_driverSlideAnim?.value ?? 0, 0),
        child: Opacity(
          opacity: _driverFadeAnim?.value ?? 1,
          child: child,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
            child: Icon(Icons.person, size: 40, color: theme.colorScheme.primary),
          ),
          const SizedBox(height: 16),
          Text('Rajesh Kumar', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.star, color: Colors.amber, size: 18),
              const SizedBox(width: 4),
              Text('4.8', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
              Text(' (234 trips)', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6))),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text('MH 02 AB 1234', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 20),
          
          // Price Display
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Estimated Price', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7))),
                    if (_negotiatedPrice != _currentPrice)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('Negotiated', style: theme.textTheme.bodySmall?.copyWith(color: Colors.green, fontWeight: FontWeight.w600)),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                AnimatedBuilder(
                  animation: _priceController2 ?? AnimationController(vsync: this, duration: Duration.zero),
                  builder: (context, child) => Transform.scale(
                    scale: _priceScaleAnim?.value ?? 1,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('£${_negotiatedPrice.toStringAsFixed(0)}', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                        if (_negotiatedPrice != _currentPrice) ...[
                          const SizedBox(width: 8),
                          Text('£${_currentPrice.toStringAsFixed(0)}', style: theme.textTheme.bodyMedium?.copyWith(decoration: TextDecoration.lineThrough, color: theme.colorScheme.onSurface.withOpacity(0.5))),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.call, size: 18),
                  label: const Text('Call'),
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => setState(() => _showChatDrawer = true),
                  icon: const Icon(Icons.chat, size: 18),
                  label: const Text('Chat'),
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _showCancelDialog,
                  icon: const Icon(Icons.cancel, size: 18),
                  label: const Text('Cancel'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    foregroundColor: theme.colorScheme.error,
                    side: BorderSide(color: theme.colorScheme.error),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isPaymentDone ? null : _showPaymentDialog,
                  icon: Icon(_isPaymentDone ? Icons.check_circle : Icons.payment, size: 18),
                  label: Text(_isPaymentDone ? 'Paid' : 'Payment'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: _isPaymentDone ? Colors.green : null,
                  ),
                ),
              ),
            ],
          ),
          if (_isPaymentDone) ...[
            const SizedBox(height: 12),
            InkWell(
              onTap: _showPaymentDetailsDialog,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Payment Completed', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.green)),
                          Text('Tap to view details', style: theme.textTheme.bodySmall?.copyWith(fontSize: 11)),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.green),
                  ],
                ),
              ),
            ),
          ],
        ],
        ),
      ),
    );
  }

  Widget _buildOTPSection(ThemeData theme) {
    if (_otpController == null) return const SizedBox();
    return AnimatedBuilder(
      animation: _otpController!,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, _otpSlideAnim?.value ?? 0),
        child: Opacity(
          opacity: _otpFadeAnim?.value ?? 1,
          child: child,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.verified_user, color: theme.colorScheme.primary, size: 28),
              const SizedBox(width: 12),
              Text('Verification OTP', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          Text('Share this OTP with the driver for verification:', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7))),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorScheme.primary.withOpacity(0.3), width: 2),
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildOTPDigit('4', 0, theme),
                  const SizedBox(width: 16),
                  _buildOTPDigit('7', 1, theme),
                  const SizedBox(width: 16),
                  _buildOTPDigit('2', 2, theme),
                  const SizedBox(width: 16),
                  _buildOTPDigit('9', 3, theme),
                ],
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }
  
  Widget _buildOTPDigit(String digit, int index, ThemeData theme) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 300 + (index * 100)),
      curve: Curves.elasticOut,
      builder: (context, value, child) => Transform.scale(
        scale: value,
        child: Text(
          digit,
          style: theme.textTheme.displayMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildChatDrawer(ThemeData theme) {
    if (_chatDrawerController == null) return const SizedBox();
    if (_chatDrawerController!.status != AnimationStatus.forward && _chatDrawerController!.status != AnimationStatus.completed) {
      _chatDrawerController!.forward();
    }
    
    return AnimatedBuilder(
      animation: _chatDrawerController!,
      builder: (context, child) => Positioned(
        right: -(_chatSlideAnim?.value ?? 0),
        top: 0,
        bottom: 0,
        child: Opacity(
          opacity: _chatFadeAnim?.value ?? 1,
          child: child,
        ),
      ),
      child: Material(
        elevation: 8,
        child: Container(
          width: 400,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20)],
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                      child: Icon(Icons.person, size: 20, color: theme.colorScheme.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Rajesh Kumar', style: theme.textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                          Text('Online', style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70)),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        _chatDrawerController?.reverse().then((_) {
                          setState(() => _showChatDrawer = false);
                        });
                      },
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),
              
              // Messages
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildMessage(theme, 'Hello! I\'m on my way to pick up your waste.', true, '2:30 PM'),
                    _buildMessage(theme, 'Great! How long will it take?', false, '2:31 PM'),
                    _buildMessage(theme, 'Around 15 minutes. I\'ll be there soon.', true, '2:32 PM'),
                  ],
                ),
              ),
              
              // Message Input
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  border: Border(top: BorderSide(color: theme.colorScheme.outline.withOpacity(0.2))),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      backgroundColor: theme.colorScheme.primary,
                      child: IconButton(
                        onPressed: () {
                          _messageController.clear();
                        },
                        icon: const Icon(Icons.send, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    ),
    );
  }

  void _showPaymentDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PaymentDialog(
        amount: _negotiatedPrice,
        onPaymentComplete: () {
          setState(() {
            _isPaymentDone = true;
            _transactionId = 'TXN${DateTime.now().millisecondsSinceEpoch}';
            _paymentDate = '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year} ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}';
          });
        },
      ),
    );
  }

  void _showPaymentDetailsDialog() {
    showDialog(
      context: context,
      builder: (context) => PaymentDetailsDialog(
        amount: _negotiatedPrice,
        transactionId: _transactionId,
        paymentMethod: 'Credit Card',
        date: _paymentDate,
      ),
    );
  }

  void _showCancelDialog() {
    final reasons = [
      'Changed my mind',
      'Found another service',
      'Price too high',
      'Driver taking too long',
      'Wrong location selected',
      'Other',
    ];
    String? selectedReason;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.cancel_outlined, color: Theme.of(context).colorScheme.error),
              const SizedBox(width: 12),
              const Text('Cancel Request'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Please select a reason for cancellation:'),
              const SizedBox(height: 16),
              ...reasons.map((reason) => RadioListTile<String>(
                title: Text(reason),
                value: reason,
                groupValue: selectedReason,
                onChanged: (value) => setDialogState(() => selectedReason = value),
                contentPadding: EdgeInsets.zero,
              )),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back'),
            ),
            ElevatedButton(
              onPressed: selectedReason == null ? null : () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  PageRouteBuilder(
                    opaque: false,
                    barrierColor: Colors.transparent,
                    pageBuilder: (context, animation, secondaryAnimation) {
                      return CancelAnimation(
                        onComplete: () {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (context) => const UserDashboard()),
                            (route) => false,
                          );
                        },
                      );
                    },
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
              child: const Text('Confirm Cancel'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessage(ThemeData theme, String text, bool isDriver, String time) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Transform.translate(
        offset: Offset(0, 10 * (1 - value)),
        child: Transform.scale(
          scale: 0.9 + (0.1 * value),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          mainAxisAlignment: isDriver ? MainAxisAlignment.start : MainAxisAlignment.end,
          children: [
            if (isDriver) ...[
              CircleAvatar(
                radius: 16,
                backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                child: Icon(Icons.person, size: 16, color: theme.colorScheme.primary),
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDriver ? theme.colorScheme.surfaceVariant : theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(text, style: theme.textTheme.bodyMedium?.copyWith(color: isDriver ? theme.colorScheme.onSurface : Colors.white)),
                  const SizedBox(height: 4),
                  Text(time, style: theme.textTheme.bodySmall?.copyWith(color: isDriver ? theme.colorScheme.onSurface.withOpacity(0.6) : Colors.white70)),
                ],
              ),
            ),
          ),
          ],
        ),
      ),
    );
  }
}
