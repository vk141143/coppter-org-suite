import 'package:flutter/material.dart';

class WebFilterBar extends StatelessWidget {
  final String selectedStatus;
  final String selectedCategory;
  final String selectedSort;
  final Function(String) onStatusChanged;
  final Function(String) onCategoryChanged;
  final Function(String) onSortChanged;
  final VoidCallback onReset;

  const WebFilterBar({
    super.key,
    required this.selectedStatus,
    required this.selectedCategory,
    required this.selectedSort,
    required this.onStatusChanged,
    required this.onCategoryChanged,
    required this.onSortChanged,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.03)
            : Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : Colors.black.withOpacity(0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            'Filters:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
          const SizedBox(width: 16),
          _buildChip(context, 'All', selectedStatus == 'All',
              () => onStatusChanged('All')),
          _buildChip(context, 'Pending', selectedStatus == 'Pending',
              () => onStatusChanged('Pending')),
          _buildChip(context, 'In-Progress', selectedStatus == 'In-Progress',
              () => onStatusChanged('In-Progress')),
          _buildChip(context, 'Completed', selectedStatus == 'Completed',
              () => onStatusChanged('Completed')),
          const SizedBox(width: 16),
          Container(
            width: 1,
            height: 24,
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.1),
          ),
          const SizedBox(width: 16),
          _buildDropdown(context, 'Category', selectedCategory,
              ['All', 'Plastic', 'E-Waste', 'Organic'], onCategoryChanged),
          const SizedBox(width: 12),
          _buildDropdown(context, 'Sort', selectedSort,
              ['Newest', 'Oldest', 'Status'], onSortChanged),
          const Spacer(),
          TextButton.icon(
            onPressed: onReset,
            icon: const Icon(Icons.clear_all, size: 18),
            label: const Text('Reset'),
            style: TextButton.styleFrom(
              foregroundColor: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(
      BuildContext context, String label, bool selected, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFF1A73E8)
                : isDark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.black.withOpacity(0.03),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected
                  ? const Color(0xFF1A73E8)
                  : isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.08),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: selected
                  ? Colors.white
                  : isDark
                      ? Colors.white70
                      : Colors.black54,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(BuildContext context, String label, String value,
      List<String> items, Function(String) onChanged) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.08),
        ),
      ),
      child: DropdownButton<String>(
        value: value,
        underline: const SizedBox(),
        icon: Icon(Icons.arrow_drop_down,
            size: 20, color: isDark ? Colors.white70 : Colors.black54),
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white70 : Colors.black54,
        ),
        dropdownColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        items: items.map((item) {
          return DropdownMenuItem(value: item, child: Text(item));
        }).toList(),
        onChanged: (val) => onChanged(val!),
      ),
    );
  }
}
