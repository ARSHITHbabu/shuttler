import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import 'cached_profile_image.dart';

/// Profile image picker widget
/// Circular avatar with camera icon overlay, tap to pick from gallery or camera
class ProfileImagePicker extends StatefulWidget {
  final String? initialImageUrl;
  final double size;
  final ValueChanged<File?>? onImagePicked;
  final bool isLoading;

  const ProfileImagePicker({
    super.key,
    this.initialImageUrl,
    this.size = AppDimensions.avatarXl,
    this.onImagePicked,
    this.isLoading = false,
  });

  @override
  State<ProfileImagePicker> createState() => _ProfileImagePickerState();
}

class _ProfileImagePickerState extends State<ProfileImagePicker> {
  File? _pickedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _showImageSourceDialog() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusXl)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppColors.accent),
              title: const Text(
                'Choose from Gallery',
                style: TextStyle(color: AppColors.textPrimary),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.accent),
              title: const Text(
                'Take Photo',
                style: TextStyle(color: AppColors.textPrimary),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            if (_pickedImage != null || widget.initialImageUrl != null)
              ListTile(
                leading: const Icon(Icons.delete, color: AppColors.error),
                title: const Text(
                  'Remove Photo',
                  style: TextStyle(color: AppColors.error),
                ),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _pickedImage = null;
                  });
                  widget.onImagePicked?.call(null);
                },
              ),
            const SizedBox(height: AppDimensions.spacingS),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 90,
      );

      if (image != null) {
        // Crop the image
        if (kIsWeb) {
          // On web, skip cropping for now (web support requires additional setup)
          // The image_cropper package supports web but needs proper configuration
          // For now, we'll just pass null and let the parent handle the XFile
          widget.onImagePicked?.call(null);
        } else {
          final croppedFile = await _cropImage(File(image.path));
          if (croppedFile != null) {
            setState(() {
              _pickedImage = croppedFile;
            });
            widget.onImagePicked?.call(croppedFile);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<File?> _cropImage(File imageFile) async {
    if (kIsWeb) {
      // Skip cropping on web
      return imageFile;
    }
    
    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: AppColors.accent,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            title: 'Crop Image',
            aspectRatioLockEnabled: true,
          ),
        ],
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 85,
      );

      if (croppedFile != null) {
        return File(croppedFile.path);
      }
      return null;
    } catch (e) {
      // If cropping fails, return original image
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error cropping image: $e. Using original image.'),
            backgroundColor: AppColors.warning,
            duration: const Duration(seconds: 2),
          ),
        );
      }
      return imageFile;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isLoading ? null : _showImageSourceDialog,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Image or placeholder
          Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.accent,
                width: 3,
              ),
            ),
            child: ClipOval(
              child: widget.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
                      ),
                    )
                  : _pickedImage != null
                      ? Image.file(
                          _pickedImage!,
                          fit: BoxFit.cover,
                        )
                      : widget.initialImageUrl != null && widget.initialImageUrl!.isNotEmpty
                          ? CachedProfileImage(
                              imageUrl: widget.initialImageUrl!,
                              size: widget.size,
                            )
                          : Container(
                              color: AppColors.cardBackground,
                              child: Icon(
                                Icons.person,
                                size: widget.size * 0.5,
                                color: AppColors.textSecondary,
                              ),
                            ),
            ),
          ),
          // Camera icon overlay
          if (!widget.isLoading)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: widget.size * 0.3,
                height: widget.size * 0.3,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.background,
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
