import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../user/screens/chat_driver_screen.dart';
import '../widgets/cancel_animation.dart';
import '../widgets/payment_dialog.dart';
import '../widgets/payment_details_dialog.dart';
import '../../user/screens/user_dashboard.dart';

class TrackComplaintMobile extends StatefulWidget {
  const TrackComplaintMobile({super.key});

  @override
  State<TrackComplaintMobile> createState() => _TrackComplaintMobileState();
}

class _TrackComplaintMobileState extends State<TrackComplaintMobile> {
  int _currentStatus = 2;
  double _currentPrice = 850.0;
  bool _isPaymentDone = false;
  String _transactionId = '';
  String _paymentDate = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Track Issue'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const UserDashboard()),
            (route) => false,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [theme.colorScheme.primary.withOpacity(0.05), theme.colorScheme.surface],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildComplaintInfo(theme),
              const SizedBox(height: 24),
              _buildStatusTimeline(theme),
              const SizedBox(height: 24),
              if (_currentStatus >= 1) _buildDriverDetails(theme),
              const SizedBox(height: 24),
              if (_currentStatus >= 2) _buildETADistanceCards(theme),
              const SizedBox(height: 24),
              if (_currentStatus >= 2) _buildLiveLocation(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComplaintInfo(ThemeData theme) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: theme.colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: const Text('🏠', style: TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Complaint #WM001234', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Household Waste Collection', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7))),
                    const SizedBox(height: 4),
                    Text('Submitted on March 15, 2024', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: theme.colorScheme.surfaceVariant.withOpacity(0.5), borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                Icon(Icons.location_on_outlined, color: theme.colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text('123 Main Street, City, State 12345', style: theme.textTheme.bodySmall)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTimeline(ThemeData theme) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Status Timeline', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Column(
            children: List.generate(AppConstants.complaintStatus.length, (index) {
              final status = AppConstants.complaintStatus[index];
              final isCompleted = index <= _currentStatus;
              final isCurrent = index == _currentStatus;
              
              return Row(
                children: [
                  Column(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: isCompleted ? theme.colorScheme.primary : theme.colorScheme.outline.withOpacity(0.3),
                          shape: BoxShape.circle,
                          border: isCurrent ? Border.all(color: theme.colorScheme.primary, width: 3) : null,
                        ),
                        child: isCompleted ? Icon(index < _currentStatus ? Icons.check : Icons.circle, color: Colors.white, size: 12) : null,
                      ),
                      if (index < AppConstants.complaintStatus.length - 1)
                        Container(width: 2, height: 40, color: isCompleted ? theme.colorScheme.primary : theme.colorScheme.outline.withOpacity(0.3)),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(status, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600, color: isCompleted ? theme.colorScheme.onSurface : theme.colorScheme.onSurface.withOpacity(0.6))),
                          const SizedBox(height: 4),
                          Text(_getStatusDescription(index), style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6))),
                          if (isCompleted && index < _currentStatus)
                            Text(_getStatusTime(index), style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverDetails(ThemeData theme) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Assigned Driver', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Column(
            children: [
              Row(
                children: [
                  CircleAvatar(radius: 28, backgroundColor: theme.colorScheme.primary.withOpacity(0.1), child: Icon(Icons.person, color: theme.colorScheme.primary, size: 28)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Mike Johnson', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Row(children: [const Icon(Icons.star, color: Colors.amber, size: 14), const SizedBox(width: 4), Text('4.8 (124)', style: theme.textTheme.bodySmall)]),
                        const SizedBox(height: 2),
                        Text('WM-1234', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6))),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatDriverScreen(driverName: 'Mike Johnson', complaintId: 'WM001234'))),
                      icon: const Icon(Icons.chat_bubble_outline, size: 14),
                      label: const Flexible(child: FittedBox(fit: BoxFit.scaleDown, child: Text('Chat'))),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                        side: BorderSide(color: theme.colorScheme.primary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.phone, size: 14),
                      label: const Flexible(child: FittedBox(fit: BoxFit.scaleDown, child: Text('Call'))),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                        side: BorderSide(color: theme.colorScheme.primary),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _showCancelDialog,
                      icon: const Icon(Icons.cancel, size: 14),
                      label: const Flexible(child: FittedBox(fit: BoxFit.scaleDown, child: Text('Cancel'))),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                        foregroundColor: const Color(0xFF0F5132),
                        side: const BorderSide(color: Color(0xFF0F5132)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isPaymentDone ? _showPaymentDetailsDialog : _showPaymentDialog,
                      icon: Icon(_isPaymentDone ? Icons.check_circle : Icons.payment, size: 14),
                      label: Flexible(child: FittedBox(fit: BoxFit.scaleDown, child: Text(_isPaymentDone ? 'Paid' : 'Pay'))),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                        backgroundColor: _isPaymentDone ? Colors.green : const Color(0xFF0F5132),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F5132), Color(0xFF198754)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Estimated Price', style: theme.textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
                Text(
                  '£$_currentPrice',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          if (_isPaymentDone) ...[
            const SizedBox(height: 16),
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
    );
  }

  Widget _buildETADistanceCards(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: CustomCard(
            gradient: const LinearGradient(
              colors: [Color(0xFF0F5132), Color(0xFF198754)],
            ),
            child: Column(
              children: [
                const Icon(Icons.access_time, color: Colors.white, size: 32),
                const SizedBox(height: 8),
                Text('ETA', style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70)),
                const SizedBox(height: 4),
                Text('15 mins', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: CustomCard(
            gradient: const LinearGradient(
              colors: [Color(0xFF2D7A4F), Color(0xFF5A9F6E)],
            ),
            child: Column(
              children: [
                const Icon(Icons.location_on, color: Colors.white, size: 32),
                const SizedBox(height: 8),
                Text('Distance', style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70)),
                const SizedBox(height: 4),
                Text('3.2 km', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showPaymentDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PaymentDialog(
        amount: _currentPrice,
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
        amount: _currentPrice,
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
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F5132)),
              child: const Text('Confirm Cancel'),
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildLiveLocation(ThemeData theme) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Live Tracking', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Container(
            height: 200,
            decoration: BoxDecoration(color: theme.colorScheme.surfaceVariant.withOpacity(0.3), borderRadius: BorderRadius.circular(12), border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2))),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map_outlined, size: 48, color: theme.colorScheme.primary),
                  const SizedBox(height: 8),
                  Text('Live Map View', style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('Driver is 5 minutes away', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6))),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F5132), Color(0xFF198754)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.verified_user, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text('Verification OTP', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Share this OTP with the driver:', style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70, fontSize: 11)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildOTPDigit('4', theme),
                    const SizedBox(width: 8),
                    _buildOTPDigit('7', theme),
                    const SizedBox(width: 8),
                    _buildOTPDigit('2', theme),
                    const SizedBox(width: 8),
                    _buildOTPDigit('9', theme),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusDescription(int index) {
    switch (index) {
      case 0: return 'Your complaint has been received and is being reviewed';
      case 1: return 'A driver has been assigned to handle your request';
      case 2: return 'Driver is on the way to your location';
      case 3: return 'Waste collection has been completed successfully';
      default: return '';
    }
  }

  String _getStatusTime(int index) {
    switch (index) {
      case 0: return 'Completed at 10:30 AM';
      case 1: return 'Completed at 11:15 AM';
      case 2: return 'Started at 2:00 PM';
      default: return '';
    }
  }
  
  Widget _buildOTPDigit(String digit, ThemeData theme) {
    return Container(
      width: 40,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
      ),
      child: Center(
        child: Text(
          digit,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
