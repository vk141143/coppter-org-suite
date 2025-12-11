import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CustomerSupportDetailWeb extends StatefulWidget {
  final String category;
  final String issue;

  const CustomerSupportDetailWeb({
    super.key,
    required this.category,
    required this.issue,
  });

  @override
  State<CustomerSupportDetailWeb> createState() => _CustomerSupportDetailWebState();
}

class _CustomerSupportDetailWebState extends State<CustomerSupportDetailWeb> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final List<File> _images = [];
  bool _isSubmitting = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    if (_images.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Maximum 3 images allowed')));
      return;
    }

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() => _images.add(File(pickedFile.path)));
    }
  }

  void _removeImage(int index) {
    setState(() => _images.removeAt(index));
  }

  Future<void> _submitComplaint() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Support request submitted successfully'), backgroundColor: Colors.green));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1419) : const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            padding: const EdgeInsets.all(48),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildIssueBanner(context, isDark),
                  const SizedBox(height: 48),
                  _buildDescriptionSection(context, isDark),
                  const SizedBox(height: 32),
                  _buildUploadSection(context, isDark),
                  const SizedBox(height: 48),
                  _buildSubmitButton(context, isDark),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIssueBanner(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_getCategoryColor().withOpacity(0.1), _getCategoryColor().withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _getCategoryColor().withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: _getCategoryColor().withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(_getCategoryIcon(), size: 36, color: _getCategoryColor()),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.issue,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.category,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Describe your issue',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Please provide as much detail as possible to help us resolve your issue quickly',
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.white60 : Colors.black54,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
            ),
          ),
          child: TextFormField(
            controller: _descriptionController,
            maxLines: 10,
            decoration: InputDecoration(
              hintText: 'Describe the issue in detail...\n\nInclude:\n• What happened\n• When it happened\n• Steps to reproduce',
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(20),
            ),
            style: const TextStyle(fontSize: 15, height: 1.6),
            validator: (value) {
              if (value == null || value.trim().isEmpty) return 'Please describe your issue';
              if (value.trim().length < 10) return 'Please provide more details (at least 10 characters)';
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildUploadSection(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upload photos (Optional)',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Add up to 3 screenshots or photos to help us understand the issue',
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.white60 : Colors.black54,
          ),
        ),
        const SizedBox(height: 20),
        if (_images.isEmpty)
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.2),
                  width: 2,
                  style: BorderStyle.solid,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.cloud_upload_outlined,
                      size: 48,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Click to upload',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'or drag and drop',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white38 : Colors.black38,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              ..._images.asMap().entries.map((entry) {
                return MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(entry.value, width: 150, height: 150, fit: BoxFit.cover),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () => _removeImage(entry.key),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                            child: const Icon(Icons.close, color: Colors.white, size: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              if (_images.length < 3)
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.2),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate, size: 32, color: isDark ? Colors.white60 : Colors.black54),
                        const SizedBox(height: 8),
                        Text('Add Photo', style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : Colors.black54)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }

  Widget _buildSubmitButton(BuildContext context, bool isDark) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitComplaint,
        style: ElevatedButton.styleFrom(
          backgroundColor: _getCategoryColor(),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
        ),
        child: _isSubmitting
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Text('Submit Support Request', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      ),
    );
  }

  IconData _getCategoryIcon() {
    if (widget.category.contains('Account')) return Icons.account_circle;
    if (widget.category.contains('Booking')) return Icons.add_circle;
    if (widget.category.contains('Tracking')) return Icons.location_on;
    if (widget.category.contains('Collection')) return Icons.delete;
    if (widget.category.contains('Payment')) return Icons.payment;
    if (widget.category.contains('App')) return Icons.phone_android;
    if (widget.category.contains('Location')) return Icons.map;
    if (widget.category.contains('Safety')) return Icons.warning;
    if (widget.category.contains('History')) return Icons.history;
    if (widget.category.contains('Notifications')) return Icons.notifications;
    return Icons.feedback;
  }

  Color _getCategoryColor() {
    if (widget.category.contains('Account')) return const Color(0xFF1A73E8);
    if (widget.category.contains('Booking')) return const Color(0xFF00C853);
    if (widget.category.contains('Tracking')) return const Color(0xFFFF9800);
    if (widget.category.contains('Collection')) return const Color(0xFF9C27B0);
    if (widget.category.contains('Payment')) return const Color(0xFF4CAF50);
    if (widget.category.contains('App')) return const Color(0xFF2196F3);
    if (widget.category.contains('Location')) return const Color(0xFFE91E63);
    if (widget.category.contains('Safety')) return const Color(0xFFF44336);
    if (widget.category.contains('History')) return const Color(0xFF607D8B);
    if (widget.category.contains('Notifications')) return const Color(0xFFFF5722);
    return const Color(0xFF9E9E9E);
  }
}
