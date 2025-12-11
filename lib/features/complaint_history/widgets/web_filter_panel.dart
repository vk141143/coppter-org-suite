import 'package:flutter/material.dart';

class WebFilterPanel extends StatelessWidget {
  final bool isOpen;
  final String selectedStatus;
  final String selectedCategory;
  final Function(String) onStatusChanged;
  final Function(String) onCategoryChanged;
  final VoidCallback onReset;
  final VoidCallback onClose;

  const WebFilterPanel({
    super.key,
    required this.isOpen,
    required this.selectedStatus,
    required this.selectedCategory,
    required this.onStatusChanged,
    required this.onCategoryChanged,
    required this.onReset,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (!isOpen) return const SizedBox();

    return Positioned(
      left: 0,
      top: 0,
      bottom: 0,
      width: 350,
      child: Material(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: 8,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF52B788), Color(0xFF40916C)],
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.filter_list, color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  const Text('Filters', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white)),
                  const Spacer(),
                  IconButton(
                    onPressed: onClose,
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(32),
                children: [
                  Text('STATUS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: isDark ? Colors.white60 : Colors.black54)),
                  const SizedBox(height: 16),
                  _buildChip(context, 'All', selectedStatus == 'All', () => onStatusChanged('All')),
                  _buildChip(context, 'Pending', selectedStatus == 'Pending', () => onStatusChanged('Pending')),
                  _buildChip(context, 'In-Progress', selectedStatus == 'In-Progress', () => onStatusChanged('In-Progress')),
                  _buildChip(context, 'Completed', selectedStatus == 'Completed', () => onStatusChanged('Completed')),
                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 32),
                  Text('CATEGORY', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: isDark ? Colors.white60 : Colors.black54)),
                  const SizedBox(height: 16),
                  _buildChip(context, 'All', selectedCategory == 'All', () => onCategoryChanged('All')),
                  _buildChip(context, 'Plastic Waste', selectedCategory == 'Plastic Waste', () => onCategoryChanged('Plastic Waste')),
                  _buildChip(context, 'E-Waste', selectedCategory == 'E-Waste', () => onCategoryChanged('E-Waste')),
                  _buildChip(context, 'Organic Waste', selectedCategory == 'Organic Waste', () => onCategoryChanged('Organic Waste')),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: onReset,
                      icon: const Icon(Icons.refresh, size: 20),
                      label: const Text('Reset Filters'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF52B788),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: onClose,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Close'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(BuildContext context, String label, bool isSelected, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF52B788).withOpacity(0.1) : (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.02)),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? const Color(0xFF52B788) : (isDark ? Colors.white10 : Colors.black12), width: isSelected ? 2 : 1),
          ),
          child: Row(
            children: [
              Expanded(child: Text(label, style: TextStyle(fontSize: 14, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500, color: isSelected ? const Color(0xFF52B788) : (isDark ? Colors.white : Colors.black87)))),
              if (isSelected) const Icon(Icons.check_circle, size: 20, color: Color(0xFF52B788)),
            ],
          ),
        ),
      ),
    );
  }
}
