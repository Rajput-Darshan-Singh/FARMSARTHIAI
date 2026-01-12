import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../app_localizations.dart';
import '../utils/helpers.dart';

class ImageInput extends StatefulWidget {
  final Function(String) onImageSelected;

  const ImageInput({Key? key, required this.onImageSelected}) : super(key: key);

  @override
  _ImageInputState createState() => _ImageInputState();
}

class _ImageInputState extends State<ImageInput> {
  String? _selectedImagePath;
  final ImagePicker _picker = ImagePicker();

  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 80,
      );

      if (image != null) _setSelectedImage(image.path);
    } catch (e) {
      Helpers.showSnackBar(context, 'Failed to take photo: $e', isError: true);
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 80,
      );

      if (image != null) _setSelectedImage(image.path);
    } catch (e) {
      Helpers.showSnackBar(context, 'Failed to pick image: $e', isError: true);
    }
  }

  void _setSelectedImage(String path) {
    if (!Helpers.isImageSizeValid(path)) {
      Helpers.showSnackBar(context, 'Image must be below 5MB', isError: true);
      return;
    }

    setState(() => _selectedImagePath = path);
    widget.onImageSelected(path);
  }

  void _removeImage() {
    setState(() => _selectedImagePath = null);
    widget.onImageSelected('');
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          /// ----------------------------------------------------
          /// SHOW HEADER WHEN NO IMAGE IS SELECTED
          /// ----------------------------------------------------
          if (_selectedImagePath == null)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withOpacity(0.1),
                    theme.colorScheme.tertiary.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(Icons.camera_alt,
                      size: 64, color: theme.colorScheme.primary),
                  const SizedBox(height: 12),
                  Text(
                    loc.translate('selectInputMethod'),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Capture or upload a clear photo of the affected plant',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

          /// ----------------------------------------------------
          /// SHOW IMAGE PREVIEW WHEN SELECTED
          /// ----------------------------------------------------
          if (_selectedImagePath != null)
            _buildImagePreview(theme),

          const SizedBox(height: 30),

          /// ----------------------------------------------------
          /// ALWAYS SHOW BUTTONS (VERTICAL)
          /// ----------------------------------------------------
          _buildImageOption(
            context,
            Icons.camera_alt,
            loc.translate('takePhoto'),
            "Take a new photo",
            _takePhoto,
            theme.colorScheme.primary,
          ),

          const SizedBox(height: 16),

          _buildImageOption(
            context,
            Icons.photo_library,
            loc.translate('uploadImage'),
            "Choose from gallery",
            _pickFromGallery,
            theme.colorScheme.secondary,
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // BUTTON WIDGET (VERTICAL)
  // --------------------------------------------------------------------------
  Widget _buildImageOption(
    BuildContext context,
    IconData icon,
    String label,
    String subtitle,
    VoidCallback onTap,
    Color color,
  ) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: color.withOpacity(0.12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.25),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // IMAGE PREVIEW
  // --------------------------------------------------------------------------
  Widget _buildImagePreview(ThemeData theme) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            /// Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.check_circle,
                        color: theme.colorScheme.primary, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      "Image Selected",
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: _removeImage,
                  icon: Icon(Icons.close, color: theme.colorScheme.error),
                ),
              ],
            ),

            const SizedBox(height: 16),

            /// Preview Image (Fixed Height)
            Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: FileImage(File(_selectedImagePath!)),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _removeImage,
                icon: Icon(Icons.delete_outline),
                label: Text("Remove Image"),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  foregroundColor: theme.colorScheme.error,
                  side: BorderSide(color: theme.colorScheme.error),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
