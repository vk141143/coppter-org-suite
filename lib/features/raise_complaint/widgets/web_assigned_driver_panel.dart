import 'package:flutter/material.dart';
import 'dart:math' as math;

class WebAssignedDriverPanel extends StatefulWidget {
  final String driverName;
  final String driverPhone;
  final String vehicleNumber;
  final String status;
  final String eta;
  final double currentPrice;
  final double negotiatedPrice;
  final VoidCallback onCallTap;
  final VoidCallback onChatTap;
  final VoidCallback onTrackTap;
  final VoidCallback onNegotiateTap;
  final VoidCallback onCancelTap;

  const WebAssignedDriverPanel({
    super.key,
    required this.driverName,
    required this.driverPhone,
    required this.vehicleNumber,
    required this.status,
    required this.eta,
    required this.currentPrice,
    required this.negotiatedPrice,
    required this.onCallTap,
    required this.onChatTap,
    required this.onTrackTap,
    required this.onNegotiateTap,
    required this.onCancelTap,
  });

  @override
  State<WebAssignedDriverPanel> createState() => _WebAssignedDriverPanelState();
}

class _WebAssignedDriverPanelState extends State<WebAssignedDriverPanel> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_shipping, color: Color(0xFF1A73E8), size: 20),
              const SizedBox(width: 8),
              Text(
                'Assigned Driver',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          Row(
            children: [
              Stack(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1A73E8), Color(0xFF4285F4)],
                      ),
                    ),
                    child: const Center(
                      child: Icon(Icons.person, color: Colors.white, size: 32),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF4CAF50),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF4CAF50).withOpacity(0.5 * (1 - _pulseController.value)),
                                blurRadius: 10 * _pulseController.value,
                                spreadRadius: 5 * _pulseController.value,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.driverName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '4.8',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CAF50).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            widget.status,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF4CAF50),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.02),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.directions_car, size: 16, color: isDark ? Colors.white70 : Colors.black54),
                const SizedBox(width: 8),
                Text(
                  widget.vehicleNumber,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A73E8).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time, size: 12, color: Color(0xFF1A73E8)),
                      const SizedBox(width: 4),
                      Text(
                        'ETA: ${widget.eta}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A73E8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: widget.negotiatedPrice > 0
                    ? [const Color(0xFFFF9800).withOpacity(0.1), const Color(0xFFFF9800).withOpacity(0.05)]
                    : [const Color(0xFF4CAF50).withOpacity(0.1), const Color(0xFF4CAF50).withOpacity(0.05)],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: widget.negotiatedPrice > 0 ? const Color(0xFFFF9800).withOpacity(0.3) : const Color(0xFF4CAF50).withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  widget.negotiatedPrice > 0 ? Icons.pending : Icons.currency_pound,
                  size: 16,
                  color: widget.negotiatedPrice > 0 ? const Color(0xFFFF9800) : const Color(0xFF4CAF50),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.negotiatedPrice > 0 ? 'Negotiation Pending' : 'Agreed Price',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 2),
                      if (widget.negotiatedPrice > 0) ...[
                        Text(
                          'Your Offer: £${widget.negotiatedPrice.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFFF9800),
                          ),
                        ),
                        Text(
                          'Original: £${widget.currentPrice.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 11,
                            decoration: TextDecoration.lineThrough,
                            color: isDark ? Colors.white54 : Colors.black38,
                          ),
                        ),
                      ] else ...[Text(
                          '£${widget.currentPrice.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF4CAF50),
                          ),
                        ),]
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.phone,
                  label: 'Call',
                  color: const Color(0xFF4CAF50),
                  onTap: widget.onCallTap,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.chat_bubble_outline,
                  label: 'Chat',
                  color: const Color(0xFF1A73E8),
                  onTap: widget.onChatTap,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.my_location,
                  label: 'Track',
                  color: const Color(0xFFFF9800),
                  onTap: widget.onTrackTap,
                  isDark: isDark,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.handshake,
                  label: 'Negotiate',
                  color: const Color(0xFFFF9800),
                  onTap: widget.onNegotiateTap,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.cancel,
                  label: 'Cancel',
                  color: const Color(0xFFE53E3E),
                  onTap: widget.onCancelTap,
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
