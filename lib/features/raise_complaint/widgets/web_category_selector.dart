import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';

class WebCategorySelector extends StatefulWidget {
  final String? selectedCategory;
  final Function(String) onCategorySelected;

  const WebCategorySelector({super.key, this.selectedCategory, required this.onCategorySelected});

  @override
  State<WebCategorySelector> createState() => _WebCategorySelectorState();
}

class _WebCategorySelectorState extends State<WebCategorySelector> {
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredCategories = [];

  @override
  void initState() {
    super.initState();
    _filteredCategories = AppConstants.wasteCategories;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search categories...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onChanged: _filterCategories,
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.5,
          ),
          itemCount: _filteredCategories.length,
          itemBuilder: (context, index) => _buildCategoryCard(theme, _filteredCategories[index]),
        ),
      ],
    );
  }

  Widget _buildCategoryCard(ThemeData theme, Map<String, dynamic> category) {
    final isSelected = widget.selectedCategory == category['name'];
    
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => widget.onCategorySelected(category['name']),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected ? theme.colorScheme.primary.withOpacity(0.1) : theme.colorScheme.surface,
            border: Border.all(
              color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline.withOpacity(0.3),
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected ? [BoxShadow(color: theme.colorScheme.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))] : [],
          ),
          child: Row(
            children: [
              Text(category['icon'], style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  category['name'],
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? theme.colorScheme.primary : null,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isSelected) Icon(Icons.check_circle, color: theme.colorScheme.primary, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _filterCategories(String query) {
    setState(() {
      _filteredCategories = AppConstants.wasteCategories
          .where((cat) => cat['name'].toString().toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
