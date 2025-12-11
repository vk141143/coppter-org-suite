import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:math' as math;
import '../../../shared/widgets/custom_card.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../core/constants/brand_colors.dart';
import '../widgets/job_details_dialog.dart';
import '../widgets/driver_mapbox_widget.dart';
import '../../track_complaint/widgets/cancel_animation.dart';
import 'advanced_driver_dashboard.dart';
import 'customer_chat_screen.dart';
import 'job_navigation_payment_dialog.dart';

class JobNavigationScreen extends StatefulWidget {
  final JobRequest job;

  const JobNavigationScreen({super.key, required this.job});

  @override
  State<JobNavigationScreen> createState() => _JobNavigationScreenState();
}

class _JobNavigationScreenState extends State<JobNavigationScreen> with TickerProviderStateMixin {
  String _status = 'arriving';
  final _otpController = TextEditingController();
  final String _customerOTP = '4729';
  final List<TextEditingController> _otpControllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(4, (_) => FocusNode());
  late AnimationController _pulseController;
  late AnimationController _shakeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _shakeAnimation;
  bool _showOTP = false;
  bool _isProcessing = false;
  bool _showChatDrawer = false;
  double _currentPrice = 850.0;
  double _negotiatedPrice = 850.0;
  final _messageController = TextEditingController();
  late AnimationController _chatDrawerController;
  late AnimationController _priceController2;
  late Animation<double> _chatSlideAnim;
  late Animation<double> _chatFadeAnim;
  late Animation<double> _priceScaleAnim;
  bool _workCompleted = false;
  bool _paymentPending = false;
  bool _showQRScanner = false;
  int _timerSeconds = 120;
  bool _paymentCompleted = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
    _shakeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _shakeAnimation = Tween<double>(begin: 0, end: 10).animate(CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn));
    _chatDrawerController = AnimationController(vsync: this, duration: const Duration(milliseconds: 250));
    _chatSlideAnim = Tween<double>(begin: 400, end: 0).animate(CurvedAnimation(parent: _chatDrawerController, curve: Curves.easeOutCubic));
    _chatFadeAnim = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _chatDrawerController, curve: Curves.easeOut));
    _priceController2 = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _priceScaleAnim = Tween<double>(begin: 0.8, end: 1).animate(CurvedAnimation(parent: _priceController2, curve: Curves.elasticOut));
  }

  @override
  void dispose() {
    _otpController.dispose();
    _messageController.dispose();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _otpFocusNodes) {
      node.dispose();
    }
    _pulseController.dispose();
    _shakeController.dispose();
    _chatDrawerController.dispose();
    _priceController2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWeb = kIsWeb && width > 900;
    
    if (isWeb) {
      return _buildWebLayout();
    }
    return _buildMobileLayout();
  }

  Widget _buildMobileLayout() {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Navigation'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildMapView(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildJobSummaryCard(theme),
                  const SizedBox(height: 16),
                  _buildCustomerInfoCard(theme),
                  const SizedBox(height: 16),
                  _buildStatusCard(theme),
                  const SizedBox(height: 16),
                  _buildMobileActionButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMobileActionButton() {
    if (_status == 'arriving')
      return ElevatedButton.icon(
        onPressed: _isProcessing ? null : _markAsArrived,
        icon: _isProcessing ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.location_on),
        label: Text(_isProcessing ? 'Processing...' : 'Mark as Arrived'),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 56),
          backgroundColor: BrandColors.primaryGreen,
          foregroundColor: Colors.white,
          disabledBackgroundColor: BrandColors.primaryGreen,
          disabledForegroundColor: Colors.white,
        ),
      );
    else if (_status == 'arrived')
      return ElevatedButton.icon(
        onPressed: _isProcessing ? null : _startPickup,
        icon: _isProcessing ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.play_arrow),
        label: Text(_isProcessing ? 'Processing...' : 'Start Pickup'),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 56),
          backgroundColor: BrandColors.primaryGreen,
          foregroundColor: Colors.white,
          disabledBackgroundColor: BrandColors.primaryGreen,
          disabledForegroundColor: Colors.white,
        ),
      );
    else if (_status == 'with_customer')
      return ElevatedButton.icon(
        onPressed: _showOTPEntryDialog,
        icon: const Icon(Icons.lock_outline),
        label: const Text('Enter Customer OTP'),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 56),
          backgroundColor: BrandColors.primaryGreen,
          foregroundColor: Colors.white,
        ),
      );
    else if (_status == 'working')
      return ElevatedButton.icon(
        onPressed: _completeWork,
        icon: const Icon(Icons.done_all),
        label: const Text('Complete Work'),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 56),
          backgroundColor: BrandColors.primaryGreen,
          foregroundColor: Colors.white,
        ),
      );
    else if (_workCompleted && !_paymentCompleted)
      return ElevatedButton.icon(
        onPressed: _showPaymentDialog,
        icon: const Icon(Icons.payment),
        label: const Text('Request Payment'),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 56),
          backgroundColor: BrandColors.primaryGreen,
          foregroundColor: Colors.white,
        ),
      );
    return const SizedBox.shrink();
  }

  Widget _buildWebLayout() {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final isTwoColumn = width > 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Job Navigation'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.colorScheme.primary.withOpacity(0.05),
                  theme.colorScheme.surface,
                ],
              ),
            ),
            child: isTwoColumn ? _buildTwoColumnLayout(theme) : _buildSingleColumnLayout(theme),
          ),
          if (_showChatDrawer) _buildChatDrawer(theme),
        ],
      ),
    );
  }

  Widget _buildTwoColumnLayout(ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 40,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: _buildDetailsSection(theme),
          ),
        ),
        Expanded(
          flex: 60,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Expanded(child: _buildMapSection(theme)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSingleColumnLayout(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildMapSection(theme),
          const SizedBox(height: 16),
          _buildDetailsSection(theme),
        ],
      ),
    );
  }

  Widget _buildMapSection(ThemeData theme) {
    return Column(
      children: [
        CustomCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Navigation Map', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              SizedBox(
                height: 300,
                child: Stack(
                  children: [
                    const DriverMapboxWidget(),
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getStatusColor(),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(_getStatusIcon(), color: Colors.white, size: 14),
                            const SizedBox(width: 6),
                            Text(_getStatusText(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (_status == 'arriving')
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isProcessing ? null : _markAsArrived,
              icon: _isProcessing ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.location_on),
              label: Text(_isProcessing ? 'Processing...' : 'Mark as Arrived'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: BrandColors.primaryGreen,
                foregroundColor: Colors.white,
                disabledBackgroundColor: BrandColors.primaryGreen,
                disabledForegroundColor: Colors.white,
              ),
            ),
          )
        else if (_status == 'arrived')
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isProcessing ? null : _startPickup,
              icon: _isProcessing ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.play_arrow),
              label: Text(_isProcessing ? 'Processing...' : 'Start Pickup'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: BrandColors.primaryGreen,
                foregroundColor: Colors.white,
                disabledBackgroundColor: BrandColors.primaryGreen,
                disabledForegroundColor: Colors.white,
              ),
            ),
          )
        else if (_status == 'with_customer')
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _showOTPEntryDialog,
              icon: const Icon(Icons.lock_outline),
              label: const Text('Enter Customer OTP'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: BrandColors.primaryGreen,
                foregroundColor: Colors.white,
              ),
            ),
          )
        else if (_status == 'working')
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _completeWork,
              icon: Icon(Icons.done_all, color: theme.colorScheme.primary),
              label: Text('Complete Work', style: TextStyle(color: theme.colorScheme.primary)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.white,
                side: BorderSide(color: theme.colorScheme.primary, width: 2),
              ),
            ),
          )


      ],
    );
  }

  Widget _buildDetailsSection(ThemeData theme) {
    return Column(
      children: [
        _buildJobSummaryCard(theme),
        const SizedBox(height: 24),
        _buildCustomerInfoCard(theme),
        const SizedBox(height: 24),
        _buildStatusCard(theme),
        const SizedBox(height: 24),
        _buildActionCard(theme),
      ],
    );
  }



  Widget _buildJobSummaryCard(ThemeData theme) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Job Summary', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              ),
              if (_workCompleted && !_paymentCompleted)
                Flexible(
                  child: TextButton.icon(
                    onPressed: _showPaymentDialog,
                    icon: const Icon(Icons.payment, size: 16),
                    label: const Text('Request', style: TextStyle(fontSize: 12)),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.orange,
                      backgroundColor: Colors.orange.withOpacity(0.1),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    ),
                  ),
                ),
              if (_workCompleted && !_paymentCompleted)
                const SizedBox(width: 4),
              IconButton(
                onPressed: () => showDialog(context: context, builder: (context) => JobDetailsDialog(negotiatedPrice: _negotiatedPrice)),
                icon: const Icon(Icons.info_outline, size: 18),
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(),
                tooltip: 'Details',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(widget.job.icon, style: const TextStyle(fontSize: 40)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.job.wasteType, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Job #${widget.job.id}', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
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
                  animation: _priceController2,
                  builder: (context, child) => Transform.scale(
                    scale: _priceScaleAnim.value,
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
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.route, size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text('${widget.job.distance} km', style: theme.textTheme.bodyMedium),
              const SizedBox(width: 16),
              Icon(Icons.access_time, size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text('12 min ETA', style: theme.textTheme.bodyMedium),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerInfoCard(ThemeData theme) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Customer Info', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              ),
              IconButton(
                onPressed: _callCustomer,
                icon: const Icon(Icons.phone, size: 20),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.green.withOpacity(0.1),
                  foregroundColor: Colors.green,
                  padding: const EdgeInsets.all(8),
                  minimumSize: const Size(36, 36),
                ),
                tooltip: 'Call',
              ),
              const SizedBox(width: 4),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CustomerChatScreen(customerName: 'John Doe'),
                    ),
                  );
                },
                icon: const Icon(Icons.chat_bubble_outline, size: 20),
                style: IconButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                  foregroundColor: theme.colorScheme.primary,
                  padding: const EdgeInsets.all(8),
                  minimumSize: const Size(36, 36),
                ),
                tooltip: 'Chat',
              ),
              const SizedBox(width: 4),
              IconButton(
                onPressed: _showCancelJobDialog,
                icon: const Icon(Icons.close, size: 20),
                style: IconButton.styleFrom(
                  backgroundColor: BrandColors.secondaryGreen.withOpacity(0.3),
                  foregroundColor: BrandColors.primaryGreen,
                  padding: const EdgeInsets.all(8),
                  minimumSize: const Size(36, 36),
                ),
                tooltip: 'Cancel',
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDetailRow(Icons.person_outline, 'John Doe', theme),
          const SizedBox(height: 12),
          _buildDetailRow(Icons.location_on_outlined, widget.job.address, theme),
          const SizedBox(height: 12),
          _buildDetailRow(Icons.phone_outlined, '+1 234 567 8900', theme),
          const SizedBox(height: 12),
          _buildDetailRow(Icons.directions_car_outlined, '${widget.job.distance} km away', theme),
        ],
      ),
    );
  }

  Widget _buildStatusCard(ThemeData theme) {
    String statusDescription;
    switch (_status) {
      case 'arriving':
        statusDescription = 'Reaching customer location';
        break;
      case 'arrived':
        statusDescription = 'Waiting at customer location';
        break;
      case 'with_customer':
        statusDescription = 'Verify customer OTP';
        break;
      case 'working':
        statusDescription = 'Collecting waste';
        break;
      case 'completed':
        statusDescription = 'Pickup completed';
        break;
      default:
        statusDescription = 'Unknown status';
    }

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Job Status', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _getStatusColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _getStatusColor().withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(_getStatusIcon(), color: _getStatusColor(), size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_getStatusText(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _getStatusColor())),
                      const SizedBox(height: 4),
                      Text(statusDescription, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6))),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text, ThemeData theme) {
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
      ],
    );
  }

  Widget _buildActionCard(ThemeData theme) {
    return const SizedBox.shrink();
  }



  Widget _buildPaymentDetailRow(String label, String value, ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7), fontSize: 11)),
        ),
        Expanded(
          flex: 3,
          child: Text(value, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, fontSize: 11), textAlign: TextAlign.right, overflow: TextOverflow.ellipsis, maxLines: 1),
        ),
      ],
    );
  }





  Widget _buildMapView() {
    return const SizedBox(
      height: 300,
      child: DriverMapboxWidget(),
    );
  }

  Widget _buildCustomerDetails() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Job Details
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: BrandColors.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    widget.job.icon,
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.job.wasteType,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Payment: £${widget.job.payment.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: BrandColors.primaryGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Customer Info
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Customer Details',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(Icons.person, 'John Doe'),
                  const SizedBox(height: 8),
                  _buildInfoRow(Icons.location_on, widget.job.address),
                  const SizedBox(height: 8),
                  _buildInfoRow(Icons.phone, '+1 234 567 8900'),
                  const SizedBox(height: 8),
                  _buildInfoRow(Icons.directions_car, '${widget.job.distance} km away'),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Action Button or OTP Input
            if (_status == 'arriving')
              ElevatedButton(
                onPressed: _isProcessing ? null : _markAsArrived,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  backgroundColor: BrandColors.primaryGreen,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: BrandColors.primaryGreen,
                  disabledForegroundColor: Colors.white,
                ),
                child: _isProcessing
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                          SizedBox(width: 12),
                          Text('Processing...', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      )
                    : const Text('Mark as Arrived', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              )
            else if (_status == 'arrived')
              ElevatedButton(
                onPressed: _isProcessing ? null : _startPickup,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  backgroundColor: BrandColors.primaryGreen,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: BrandColors.primaryGreen,
                  disabledForegroundColor: Colors.white,
                ),
                child: _isProcessing
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                          SizedBox(width: 12),
                          Text('Processing...', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      )
                    : const Text('Start Pickup', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              )
            else if (_status == 'with_customer')
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Enter Customer OTP',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    decoration: InputDecoration(
                      hintText: 'Enter 4-digit OTP',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      counterText: '',
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _verifyOTP,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                      backgroundColor: Colors.green,
                    ),
                    child: const Text(
                      'Verify & Complete',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor() {
    switch (_status) {
      case 'arriving':
        return BrandColors.primaryGreen;
      case 'arrived':
        return BrandColors.primaryGreen;
      case 'with_customer':
        return BrandColors.primaryGreen;
      case 'working':
        return BrandColors.primaryGreen;
      case 'completed':
        return BrandColors.primaryGreen;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon() {
    switch (_status) {
      case 'arriving':
        return Icons.directions_car;
      case 'arrived':
        return Icons.location_on;
      case 'with_customer':
        return Icons.person;
      case 'working':
        return Icons.construction;
      case 'completed':
        return Icons.check_circle;
      default:
        return Icons.info;
    }
  }

  String _getStatusText() {
    switch (_status) {
      case 'arriving':
        return 'Arriving at Location';
      case 'arrived':
        return 'Arrived at Location';
      case 'with_customer':
        return 'With Customer';
      case 'working':
        return 'Work in Progress';
      case 'completed':
        return 'Pickup Completed';
      default:
        return 'Unknown';
    }
  }

  void _markAsArrived() {
    setState(() => _isProcessing = true);
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _status = 'arrived';
        });
      }
    });
  }

  void _startPickup() {
    setState(() => _isProcessing = true);
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _status = 'with_customer';
        });
      }
    });
  }

  void _showOTPEntryDialog() {
    _otpController.clear();
    bool isVerifying = false;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lock_outline, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 12),
                        const Expanded(child: Text('Enter Customer OTP', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (!isVerifying) ...[
                      Text('Ask the customer to provide their 4-digit OTP', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _otpController,
                        keyboardType: TextInputType.number,
                        maxLength: 4,
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: 'Enter 4-digit OTP',
                          prefixIcon: Icon(Icons.lock_outline, color: Theme.of(context).colorScheme.primary),
                          border: const OutlineInputBorder(),
                          counterText: '',
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      ),
                      const SizedBox(height: 12),
                      TextButton.icon(
                        onPressed: _showCustomerOTPDialog,
                        icon: const Icon(Icons.visibility),
                        label: const Text('Show OTP to Customer'),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: () {
                              if (_otpController.text == _customerOTP) {
                                setDialogState(() => isVerifying = true);
                                Future.delayed(const Duration(milliseconds: 1500), () {
                                  Navigator.pop(context);
                                  setState(() {
                                    _status = 'working';
                                  });
                                });
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Invalid OTP. Please try again.'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.check_circle, size: 18),
                            label: const Text('Verify'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: BrandColors.primaryGreen,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (isVerifying) ...[
                      Center(
                        child: Column(
                          children: [
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.0, end: 1.0),
                              duration: const Duration(milliseconds: 600),
                              builder: (context, value, child) {
                                return Transform.scale(
                                  scale: value,
                                  child: const Icon(Icons.check_circle, color: BrandColors.primaryGreen, size: 60),
                                );
                              },
                            ),
                            const SizedBox(height: 16),
                            const Text('OTP Verified!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _completeWork() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 350),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 600),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: BrandColors.primaryGreen.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_circle, color: BrandColors.primaryGreen, size: 48),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              Text('Work Completed!', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('You can now request payment', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)), textAlign: TextAlign.center),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      _workCompleted = true;
                      _status = 'completed';
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: BrandColors.primaryGreen,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Continue'),
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
      builder: (context) => PaymentRequestDialog(
        amount: _negotiatedPrice,
        onPaymentComplete: _showPaymentSuccessDialog,
      ),
    );
  }

  void _showPaymentSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 350,
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _paymentCompleted = true;
                        });
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.close, size: 18),
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.check_circle, color: Colors.green.shade700, size: 40),
                      ),
                      const SizedBox(height: 12),
                      Text('Payment Received Successfully!', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            _buildPaymentDetailRow('Amount', '£${_negotiatedPrice.toStringAsFixed(0)}', Theme.of(context)),
                            const Divider(height: 12),
                            _buildPaymentDetailRow('Transaction ID', 'TXN${(DateTime.now().millisecondsSinceEpoch % 1000000).toString().padLeft(6, '0')}', Theme.of(context)),
                            const Divider(height: 12),
                            _buildPaymentDetailRow('Payment Method', 'QR Code', Theme.of(context)),
                            const Divider(height: 12),
                            _buildPaymentDetailRow('Date & Time', '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year} ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}', Theme.of(context)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _paymentCompleted = true;
                            });
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.home, size: 16),
                          label: const Text('Back to Dashboard', style: TextStyle(fontSize: 13)),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            backgroundColor: BrandColors.primaryGreen,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _verifyOTPWeb() {
    final enteredOTP = _otpControllers.map((c) => c.text).join();
    if (enteredOTP == _customerOTP) {
      setState(() => _status = 'completed');
      _showSuccessModal();
    } else {
      _shakeController.forward(from: 0);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid OTP. Please try again.'), backgroundColor: Colors.red),
      );
    }
  }

  void _showSuccessModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ScaleTransition(
        scale: CurvedAnimation(parent: AnimationController(vsync: this, duration: const Duration(milliseconds: 400))..forward(), curve: Curves.elasticOut),
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          contentPadding: const EdgeInsets.all(40),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.green.shade50, shape: BoxShape.circle),
                child: Icon(Icons.check_circle, color: Colors.green.shade600, size: 80),
              ),
              const SizedBox(height: 24),
              const Text('Pickup Completed!', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text('Payment Received', style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(20)),
                child: Text('£${widget.job.payment.toStringAsFixed(2)}', style: const TextStyle(fontSize: 28, color: BrandColors.primaryGreen, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.home),
                label: const Text('Back to Dashboard', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _verifyOTP() {
    if (_otpController.text == _customerOTP) {
      setState(() {
        _status = 'completed';
      });
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 64,
              ),
              const SizedBox(height: 16),
              const Text(
                'Pickup Completed!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Payment: £${widget.job.payment.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16,
                  color: BrandColors.primaryGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  backgroundColor: BrandColors.primaryGreen,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Back to Dashboard'),
              ),
            ],
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid OTP. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showCustomerOTPDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Customer OTP'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Customer should provide this OTP:'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _customerOTP,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 8,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _callCustomer() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Calling customer...'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _chatWithCustomer() {
    setState(() => _showChatDrawer = true);
  }

  void _showCancelJobDialog() {
    final reasons = [
      'Customer not available',
      'Wrong location',
      'Vehicle breakdown',
      'Emergency situation',
      'Customer requested cancellation',
      'Other',
    ];
    String? selectedReason;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 400,
              maxHeight: MediaQuery.of(context).size.height * 0.7,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
                  child: Row(
                    children: [
                      Icon(Icons.cancel_outlined, color: BrandColors.primaryGreen, size: 22),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Cancel Job',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, size: 20),
                        padding: const EdgeInsets.all(8),
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Please select a reason for cancellation:', style: TextStyle(fontSize: 13)),
                        const SizedBox(height: 4),
                        ...reasons.map((reason) => RadioListTile<String>(
                          title: Text(reason, style: const TextStyle(fontSize: 13)),
                          value: reason,
                          groupValue: selectedReason,
                          onChanged: (value) => setDialogState(() => selectedReason = value),
                          contentPadding: EdgeInsets.zero,
                          activeColor: BrandColors.primaryGreen,
                          dense: true,
                          visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                        )),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Back', style: TextStyle(fontSize: 13)),
                      ),
                      const SizedBox(width: 8),
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
                                    Navigator.of(context).popUntil((route) => route.isFirst);
                                  },
                                );
                              },
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: BrandColors.primaryGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                        child: const Text('Confirm', style: TextStyle(fontSize: 13)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChatDrawer(ThemeData theme) {
    if (_chatDrawerController.status != AnimationStatus.forward && _chatDrawerController.status != AnimationStatus.completed) {
      _chatDrawerController.forward();
    }
    
    return AnimatedBuilder(
      animation: _chatDrawerController,
      builder: (context, child) => Positioned(
        right: -(_chatSlideAnim.value),
        top: 0,
        bottom: 0,
        child: Opacity(
          opacity: _chatFadeAnim.value,
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
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, color: theme.colorScheme.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('John Doe', style: theme.textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                          Text('Customer', style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70)),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        _chatDrawerController.reverse().then((_) {
                          setState(() => _showChatDrawer = false);
                        });
                      },
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildMessage(theme, 'Hi, I\'m on my way to your location.', false, '2:30 PM'),
                    _buildMessage(theme, 'Great! How long will it take?', true, '2:31 PM'),
                    _buildMessage(theme, 'Around 12 minutes. I\'ll be there soon.', false, '2:32 PM'),
                  ],
                ),
              ),
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
                        onPressed: () => _messageController.clear(),
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

  Widget _buildMessage(ThemeData theme, String text, bool isCustomer, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isCustomer ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isCustomer) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Icon(Icons.person, size: 16, color: theme.colorScheme.primary),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isCustomer ? theme.colorScheme.primary : theme.colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(text, style: theme.textTheme.bodyMedium?.copyWith(color: isCustomer ? Colors.white : theme.colorScheme.onSurface)),
                  const SizedBox(height: 4),
                  Text(time, style: theme.textTheme.bodySmall?.copyWith(color: isCustomer ? Colors.white70 : theme.colorScheme.onSurface.withOpacity(0.6))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
