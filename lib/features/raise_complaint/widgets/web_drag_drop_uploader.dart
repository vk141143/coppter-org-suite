import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class WebDragDropUploader extends StatefulWidget {
  final List<XFile> images;
  final Function(List<XFile>) onImagesChanged;

  const WebDragDropUploader({super.key, required this.images, required this.onImagesChanged});

  @override
  State<WebDragDropUploader> createState() => _WebDragDropUploaderState();
}

class _WebDragDropUploaderState extends State<WebDragDropUploader> {
  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _pickImages,
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: theme.colorScheme.primary, width: 2, style: BorderStyle.solid),
              borderRadius: BorderRadius.circular(16),
              color: theme.colorScheme.primary.withOpacity(0.05),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cloud_upload_outlined, size: 64, color: theme.colorScheme.primary),
                const SizedBox(height: 16),
                Text('Drag & Drop images or Click to Upload', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text('Supports: JPG, PNG, GIF (Max 5MB each)', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6))),
              ],
            ),
          ),
        ),
        if (widget.images.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text('${widget.images.length} image(s) uploaded', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1,
            ),
            itemCount: widget.images.length,
            itemBuilder: (context, index) => _buildImageThumbnail(theme, index),
          ),
        ],
      ],
    );
  }

  Widget _buildImageThumbnail(ThemeData theme, int index) {
    final isHovered = _hoveredIndex == index;
    
    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredIndex = index),
      onExit: (_) => setState(() => _hoveredIndex = null),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: isHovered ? (Matrix4.identity()..scale(1.05)) : Matrix4.identity(),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: theme.colorScheme.surfaceVariant,
          boxShadow: isHovered ? [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 12, offset: const Offset(0, 4))] : [],
        ),
        child: Stack(
          children: [
            Center(child: Icon(Icons.image, size: 48, color: theme.colorScheme.primary)),
            if (isHovered)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: IconButton(
                      onPressed: () => _removeImage(index),
                      icon: const Icon(Icons.delete, color: Colors.white, size: 32),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _pickImages() async {
    final images = await ImagePicker().pickMultiImage();
    if (images.isNotEmpty) {
      widget.onImagesChanged([...widget.images, ...images]);
    }
  }

  void _removeImage(int index) {
    final newImages = List<XFile>.from(widget.images)..removeAt(index);
    widget.onImagesChanged(newImages);
  }
}
