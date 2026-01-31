import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/skeleton_screen.dart';
import '../../widgets/common/success_snackbar.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/neumorphic_button.dart';
import '../../widgets/common/profile_image_picker.dart';
import '../../providers/auth_provider.dart';
import '../../providers/service_providers.dart';
import '../../providers/owner_provider.dart';
import '../../models/owner.dart';

/// Profile Screen - Edit owner profile details
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  
  bool _isSaving = false;
  bool _isUploadingImage = false;
  Owner? _owner;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = isDark ? AppColors.background : AppColorsLight.background;
    final textPrimaryColor = theme.colorScheme.onSurface;
    final textSecondaryColor = theme.colorScheme.onSurface.withValues(alpha: 0.6);
    final iconPrimaryColor = isDark ? AppColors.iconPrimary : AppColorsLight.iconPrimary;
    final cardBackground = isDark ? AppColors.cardBackground : AppColorsLight.cardBackground;

    final authState = ref.watch(authProvider);
    
    return authState.when(
      data: (authValue) {
        if (authValue is! Authenticated) {
          return Scaffold(
            backgroundColor: backgroundColor,
            appBar: AppBar(
              backgroundColor: backgroundColor,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: textPrimaryColor),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: Text(
                'Profile',
                style: TextStyle(
                  color: textPrimaryColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            body: const Center(
              child: Text(
                'Please login',
                style: TextStyle(color: AppColors.error),
              ),
            ),
          );
        }

        final ownerId = authValue.userId;
        return _buildScaffold(ownerId, backgroundColor, textPrimaryColor, textSecondaryColor, iconPrimaryColor, cardBackground);
      },
      loading: () => Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: backgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: textPrimaryColor),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'Profile',
            style: TextStyle(
              color: textPrimaryColor,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: const Center(child: ProfileSkeleton()),
      ),
      error: (error, stack) => Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: backgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: textPrimaryColor),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'Profile',
            style: TextStyle(
              color: textPrimaryColor,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: Center(
          child: Text(
            'Error: ${error.toString()}',
            style: const TextStyle(color: AppColors.error),
          ),
        ),
      ),
    );
  }

  Widget _buildScaffold(int ownerId, Color backgroundColor, Color textPrimaryColor, Color textSecondaryColor, Color iconPrimaryColor, Color cardBackground) {
    final ownerAsync = ref.watch(ownerByIdProvider(ownerId));

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textPrimaryColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Profile',
          style: TextStyle(
            color: textPrimaryColor,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(ownerByIdProvider(ownerId));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ownerAsync.when(
            loading: () => const ProfileSkeleton(),
            error: (error, stack) => ErrorDisplay(
              message: 'Failed to load profile: ${error.toString()}',
              onRetry: () => ref.invalidate(ownerByIdProvider(ownerId)),
            ),
            data: (owner) {
              if (_owner == null || _owner!.id != owner.id) {
                _owner = owner;
                _nameController.text = owner.name;
                _phoneController.text = owner.phone;
              }

              return _buildContent(owner, textPrimaryColor, textSecondaryColor, iconPrimaryColor, cardBackground);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContent(Owner owner, Color textPrimaryColor, Color textSecondaryColor, Color iconPrimaryColor, Color cardBackground) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Avatar Section
            Center(
              child: Column(
                children: [
                  ProfileImagePicker(
                    initialImageUrl: owner.profilePhoto,
                    size: 100,
                    onImagePicked: _handleImagePicked,
                    onImageBytesPickedForWeb: _handleImageBytesPickedForWeb,
                    isLoading: _isUploadingImage,
                  ),
                  const SizedBox(height: AppDimensions.spacingM),
                  Text(
                    owner.name,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: textPrimaryColor,
                    ),
                  ),
                  Text(
                    'Owner',
                    style: TextStyle(
                      fontSize: 14,
                      color: textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.spacingL),

            // Full Name Field
            CustomTextField(
              controller: _nameController,
              label: 'Full Name',
              prefixIcon: Icons.person_outline,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Name is required';
                }
                return null;
              },
            ),

            const SizedBox(height: AppDimensions.spacingM),

            // Email Field
            CustomTextField(
              controller: TextEditingController(text: owner.email),
              label: 'Email',
              prefixIcon: Icons.email_outlined,
              enabled: false,
              readOnly: true,
            ),

            const SizedBox(height: AppDimensions.spacingM),

            // Phone Field
            CustomTextField(
              controller: _phoneController,
              label: 'Phone Number',
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Phone number is required';
                }
                if (value.length < 10) {
                  return 'Enter a valid phone number';
                }
                return null;
              },
            ),

            const SizedBox(height: AppDimensions.spacingL),

            // Save Button
            NeumorphicButton(
              text: _isSaving ? 'Saving...' : 'Save Changes',
              onPressed: _isSaving ? null : _saveProfile,
              icon: _isSaving ? null : Icons.save_outlined,
              isAccent: true,
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Future<void> _handleImagePicked(File? image) async {
    if (image == null) {
      // On web, this might be called with null when bytes are handled separately
      if (kIsWeb) return;
      return;
    }

    setState(() {
      _isUploadingImage = true;
    });

    try {
      final authState = ref.read(authProvider);
      if (authState.value is! Authenticated) {
        throw Exception('Not authenticated');
      }

      final ownerId = (authState.value as Authenticated).userId;
      final apiService = ref.read(apiServiceProvider);

      // Upload image
      final imageUrl = await apiService.uploadImage(image.path);

      // Update profile with new image URL
      final ownerService = ref.read(ownerServiceProvider);
      await ownerService.updateOwner(ownerId, {
        'profile_photo': imageUrl,
      });

      // Invalidate provider to refresh the owner data
      ref.invalidate(ownerByIdProvider(ownerId));

      setState(() {
        _isUploadingImage = false;
        _owner = null; // Force refresh
      });

      if (mounted) {
        SuccessSnackbar.show(context, 'Profile photo updated successfully');
      }
    } catch (e) {
      setState(() {
        _isUploadingImage = false;
      });
      if (mounted) {
        SuccessSnackbar.showError(context, 'Failed to upload image: ${e.toString()}');
      }
    }
  }

  Future<void> _handleImageBytesPickedForWeb(Uint8List? bytes) async {
    if (bytes == null) return;

    setState(() {
      _isUploadingImage = true;
    });

    try {
      final authState = ref.read(authProvider);
      if (authState.value is! Authenticated) {
        throw Exception('Not authenticated');
      }

      final ownerId = (authState.value as Authenticated).userId;
      final apiService = ref.read(apiServiceProvider);

      // Upload image bytes (for web)
      final imageUrl = await apiService.uploadImageBytes(bytes);

      // Update profile with new image URL
      final ownerService = ref.read(ownerServiceProvider);
      await ownerService.updateOwner(ownerId, {
        'profile_photo': imageUrl,
      });

      // Invalidate provider to refresh the owner data
      ref.invalidate(ownerByIdProvider(ownerId));

      setState(() {
        _isUploadingImage = false;
        _owner = null; // Force refresh
      });

      if (mounted) {
        SuccessSnackbar.show(context, 'Profile photo updated successfully');
      }
    } catch (e) {
      setState(() {
        _isUploadingImage = false;
      });
      if (mounted) {
        SuccessSnackbar.showError(context, 'Failed to upload image: ${e.toString()}');
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final ownerService = ref.read(ownerServiceProvider);
      final authState = ref.read(authProvider);
      
      if (authState.value is! Authenticated) {
        throw Exception('Not authenticated');
      }

      final ownerId = (authState.value as Authenticated).userId;

      await ownerService.updateOwner(ownerId, {
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
      });

      if (mounted) {
        SuccessSnackbar.show(context, 'Profile updated successfully');
        // Refresh profile
        setState(() {
          _owner = null;
        });
        ref.invalidate(ownerByIdProvider(ownerId));
      }
    } catch (e) {
      if (mounted) {
        SuccessSnackbar.showError(context, 'Failed to update profile: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}
