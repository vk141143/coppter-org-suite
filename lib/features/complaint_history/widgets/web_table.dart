import 'package:flutter/material.dart';

class WebTable extends StatefulWidget {
  final List<Map<String, dynamic>> complaints;
  final Function(Map<String, dynamic>) onComplaintTap;

  const WebTable({
    super.key,
    required this.complaints,
    required this.onComplaintTap,
  });

  @override
  State<WebTable> createState() => _WebTableState();
}

class _WebTableState extends State<WebTable> {
  int? _hoveredIndex;
  String _sortColumn = 'date';
  bool _sortAscending = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 48),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.05)
              : Colors.black.withOpacity(0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(context),
          const Divider(height: 1),
          ...List.generate(widget.complaints.length, (index) {
            return _buildRow(context, widget.complaints[index], index);
          }),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          _buildHeaderCell('ID', 80),
          _buildHeaderCell('Category', 140),
          _buildHeaderCell('Description', 280),
          _buildHeaderCell('Status', 120),
          _buildHeaderCell('Date', 120),
          _buildHeaderCell('Actions', 100),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String label, double width) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      width: width,
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white60 : Colors.black54,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildRow(
      BuildContext context, Map<String, dynamic> complaint, int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isHovered = _hoveredIndex == index;

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredIndex = index),
      onExit: (_) => setState(() => _hoveredIndex = null),
      child: InkWell(
        onTap: () => widget.onComplaintTap(complaint),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: isHovered
                ? (isDark
                    ? Colors.white.withOpacity(0.03)
                    : Colors.black.withOpacity(0.02))
                : (index % 2 == 0
                    ? (isDark
                        ? Colors.white.withOpacity(0.01)
                        : Colors.black.withOpacity(0.005))
                    : Colors.transparent),
          ),
          transform: Matrix4.identity()
            ..translate(isHovered ? 4.0 : 0.0, 0.0, 0.0),
          child: Row(
            children: [
              SizedBox(
                width: 80,
                child: Text(
                  complaint['id'],
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
              ),
              SizedBox(
                width: 140,
                child: Row(
                  children: [
                    Text(
                      complaint['icon'],
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        complaint['category'],
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 280,
                child: Text(
                  complaint['description'],
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(
                width: 120,
                child: _buildStatusChip(complaint['status']),
              ),
              SizedBox(
                width: 120,
                child: Text(
                  complaint['date'],
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
              ),
              SizedBox(
                width: 100,
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.visibility_outlined, size: 18),
                      onPressed: () => widget.onComplaintTap(complaint),
                      tooltip: 'View',
                      color: isDark ? Colors.white60 : Colors.black54,
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

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case 'Pending':
        color = const Color(0xFFFF9800);
        break;
      case 'In-Progress':
        color = const Color(0xFF2196F3);
        break;
      case 'Completed':
        color = const Color(0xFF4CAF50);
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
