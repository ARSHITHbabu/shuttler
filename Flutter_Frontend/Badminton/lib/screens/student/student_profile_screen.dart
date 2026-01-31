import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../core/theme/neumorphic_styles.dart';
import '../../widgets/common/neumorphic_container.dart';
import '../../widgets/common/neumorphic_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/skeleton_screen.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/success_snackbar.dart';
import '../../widgets/common/profile_image_picker.dart';
import '../../providers/service_providers.dart';
import '../../providers/auth_provider.dart';
import '../../providers/student_provider.dart';
import '../../models/student.dart';

/// Student Profile Screen - View and edit profile information
/// Students can view all their profile data and edit certain fields
class StudentProfileScreen extends ConsumerStatefulWidget {
  final VoidCallback? onBack;

  const StudentProfileScreen({super.key, this.onBack});

  @override
  ConsumerState<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends ConsumerState<StudentProfileScreen> {
  bool _isSaving = false;
  bool _isEditing = false;
  bool _isUploadingImage = false;

  // Controllers for editable fields
  final _phoneController = TextEditingController();
  final _guardianNameController = TextEditingController();
  final _guardianPhoneController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _guardianNameController.dispose();
    _guardianPhoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _populateControllers(Student student) {
    _phoneController.text = student.phone;
    _guardianNameController.text = student.guardianName ?? '';
    _guardianPhoneController.text = student.guardianPhone ?? '';
    _addressController.text = student.address ?? '';
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
      // Get user ID
      int? userId;
      final authStateAsync = ref.read(authProvider);
      final authState = authStateAsync.value;

      if (authState is Authenticated) {
        userId = authState.userId;
      } else {
        final storageService = ref.read(storageServiceProvider);
        if (!storageService.isInitialized) await storageService.init();
        userId = storageService.getUserId();
      }

      if (userId == null) {
        throw Exception('User not logged in');
      }

      // Upload image
      final apiService = ref.read(apiServiceProvider);
      final imageUrl = await apiService.uploadImage(image.path);

      // Update profile with new image URL using provider
      final studentList = ref.read(studentListProvider.notifier);
      await studentList.updateStudent(userId, {'profile_photo': imageUrl});

      setState(() {
        _isUploadingImage = false;
      });

      // Invalidate to refresh data
      ref.invalidate(studentByIdProvider(userId));

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
    if (bytes == null) {
      return;
    }

    setState(() {
      _isUploadingImage = true;
    });

    try {
      // Get user ID
      int? userId;
      final authStateAsync = ref.read(authProvider);
      final authState = authStateAsync.value;

      if (authState is Authenticated) {
        userId = authState.userId;
      } else {
        final storageService = ref.read(storageServiceProvider);
        if (!storageService.isInitialized) await storageService.init();
        userId = storageService.getUserId();
      }

      if (userId == null) {
        throw Exception('User not logged in');
      }

      // Upload image bytes (for web)
      final apiService = ref.read(apiServiceProvider);
      final imageUrl = await apiService.uploadImageBytes(bytes);

      // Update profile with new image URL using provider
      final studentList = ref.read(studentListProvider.notifier);
      await studentList.updateStudent(userId, {'profile_photo': imageUrl});

      setState(() {
        _isUploadingImage = false;
      });

      // Invalidate to refresh data
      ref.invalidate(studentByIdProvider(userId));

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

  Future<void> _saveProfile(int userId) async {
    setState(() => _isSaving = true);

    try {
      // Get user ID from auth provider (preferred) or storage (fallback)
      int? userId;
      
      // Try to get from auth provider first
      final authStateAsync = ref.read(authProvider);
      final authState = authStateAsync.value;
      
      if (authState is Authenticated) {
        userId = authState.userId;
      }
      
      // Fallback: try to get from storage if auth provider doesn't have it
      if (userId == null) {
        final storageService = ref.read(storageServiceProvider);
        
        // Ensure storage is initialized
        if (!storageService.isInitialized) {
          await storageService.init();
        }
        
        userId = storageService.getUserId();
      }
      
      if (userId == null) {
        throw Exception('User not logged in. Please try logging in again.');
      }

      final updateData = {
        'phone': _phoneController.text.trim(),
        'guardian_name': _guardianNameController.text.trim(),
        'guardian_phone': _guardianPhoneController.text.trim(),
        'address': _addressController.text.trim(),
      };

      // Update using provider
      final studentList = ref.read(studentListProvider.notifier);
      await studentList.updateStudent(userId, updateData);

      // Invalidate to refresh data
      ref.invalidate(studentByIdProvider(userId));

      if (mounted) {
        SuccessSnackbar.show(context, 'Profile updated successfully');
        setState(() {
          _isEditing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        SuccessSnackbar.showError(context, e.toString().replaceAll('Exception: ', ''));
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _cancelEditing(Student student) {
    _populateControllers(student);
    setState(() {
      _isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Get user ID from auth provider
    final authStateAsync = ref.watch(authProvider);
    
    return authStateAsync.when(
      loading: () => Scaffold(
        backgroundColor: isDark ? AppColors.background : AppColorsLight.background,
        body: const Center(child: ProfileSkeleton()),
      ),
      error: (error, stack) => Scaffold(
        backgroundColor: isDark ? AppColors.background : AppColorsLight.background,
        body: ErrorDisplay(
          message: 'Failed to load user data: ${error.toString()}',
          onRetry: () => ref.invalidate(authProvider),
        ),
      ),
      data: (authState) {
        if (authState is! Authenticated) {
          return Scaffold(
            backgroundColor: isDark ? AppColors.background : AppColorsLight.background,
            body: ErrorDisplay(
              message: 'Please log in to view profile',
              onRetry: () => ref.invalidate(authProvider),
            ),
          );
        }

        final userId = authState.userId;
        final studentAsync = ref.watch(studentByIdProvider(userId));

        return Scaffold(
          backgroundColor: isDark ? AppColors.background : AppColorsLight.background,
          body: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(studentByIdProvider(userId));
            },
            child: CustomScrollView(
              slivers: [
                // App Bar
                SliverAppBar(
                  backgroundColor: isDark ? AppColors.background : AppColorsLight.background,
                  elevation: 0,
                  pinned: true,
                  leading: widget.onBack != null
                      ? IconButton(
                          icon: Icon(
                            Icons.arrow_back,
                            color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
                          ),
                          onPressed: widget.onBack,
                        )
                      : null,
                  title: Text(
                    'My Profile',
                    style: TextStyle(
                      color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  centerTitle: true,
                  actions: [
                    studentAsync.when(
                      data: (student) => IconButton(
                        icon: Icon(
                          _isEditing ? Icons.close : Icons.edit,
                          color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
                        ),
                        onPressed: _isEditing 
                            ? () => _cancelEditing(student)
                            : () => setState(() {
                              _populateControllers(student);
                              _isEditing = true;
                            }),
                      ),
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                  ],
                ),

                // Content
                SliverToBoxAdapter(
                  child: studentAsync.when(
                    loading: () => const SizedBox(
                      height: 400,
                      child: ProfileSkeleton(),
                    ),
                    error: (error, stack) => Padding(
                      padding: const EdgeInsets.all(AppDimensions.paddingL),
                      child: ErrorDisplay(
                        message: 'Failed to load profile: ${error.toString()}',
                        onRetry: () => ref.invalidate(studentByIdProvider(userId)),
                      ),
                    ),
                    data: (student) {
                      // Populate controllers on first load
                      if (!_isEditing && _phoneController.text.isEmpty) {
                        _populateControllers(student);
                      }
                      
                      return Padding(
                        padding: const EdgeInsets.all(AppDimensions.paddingL),
                        child: Column(
                          children: [
                            // Profile Header
                            _buildProfileHeader(isDark, student),

                            const SizedBox(height: AppDimensions.spacingL),

                            // Personal Information Section
                            _buildSection(
                              title: 'Personal Information',
                              icon: Icons.person_outline,
                              isDark: isDark,
                              children: [
                                _buildInfoRow('Name', student.name, isDark),
                                _buildInfoRow('Email', student.email, isDark),
                                if (_isEditing)
                                  _buildEditableField(
                                    controller: _phoneController,
                                    label: 'Phone',
                                    icon: Icons.phone_outlined,
                                    isDark: isDark,
                                    keyboardType: TextInputType.phone,
                                  )
                                else
                                  _buildInfoRow('Phone', student.phone, isDark),
                                _buildInfoRow(
                                  'Date of Birth',
                                  student.dateOfBirth != null ? _formatDate(student.dateOfBirth!) : 'Not set',
                                  isDark,
                                ),
                                _buildInfoRow('Age', student.age?.toString() ?? 'Not set', isDark),
                                _buildInfoRow(
                                  'Blood Group',
                                  student.bloodGroup ?? 'Not set',
                                  isDark,
                                ),
                              ],
                            ),

                            const SizedBox(height: AppDimensions.spacingL),

                            // Guardian Information Section
                            _buildSection(
                              title: 'Guardian Information',
                              icon: Icons.family_restroom,
                              isDark: isDark,
                              children: [
                                if (_isEditing) ...[
                                  _buildEditableField(
                                    controller: _guardianNameController,
                                    label: 'Guardian Name',
                                    icon: Icons.person_outline,
                                    isDark: isDark,
                                  ),
                                  const SizedBox(height: AppDimensions.spacingM),
                                  _buildEditableField(
                                    controller: _guardianPhoneController,
                                    label: 'Guardian Phone',
                                    icon: Icons.phone_outlined,
                                    isDark: isDark,
                                    keyboardType: TextInputType.phone,
                                  ),
                                ] else ...[
                                  _buildInfoRow('Name', student.guardianName ?? 'Not set', isDark),
                                  _buildInfoRow('Phone', student.guardianPhone ?? 'Not set', isDark),
                                ],
                              ],
                            ),

                            const SizedBox(height: AppDimensions.spacingL),

                            // Address Section
                            _buildSection(
                              title: 'Address',
                              icon: Icons.location_on_outlined,
                              isDark: isDark,
                              children: [
                                if (_isEditing)
                                  _buildEditableField(
                                    controller: _addressController,
                                    label: 'Address',
                                    icon: Icons.home_outlined,
                                    isDark: isDark,
                                    maxLines: 3,
                                  )
                                else
                                  _buildInfoRow('Address', student.address ?? 'Not set', isDark),
                              ],
                            ),

                            const SizedBox(height: AppDimensions.spacingL),

                            // Account Status Section
                            _buildSection(
                              title: 'Account Status',
                              icon: Icons.verified_user_outlined,
                              isDark: isDark,
                              children: [
                                _buildStatusRow(
                                  'Account Status',
                                  student.status == 'active' ? 'Active' : 'Inactive',
                                  student.status == 'active',
                                  isDark,
                                ),
                                _buildInfoRow(
                                  'Status',
                                  student.status == 'active' ? 'Active' : 'Inactive',
                                  isDark,
                                ),
                              ],
                            ),

                            const SizedBox(height: AppDimensions.spacingXl),

                            // Save Button
                            if (_isEditing)
                              NeumorphicButton(
                                text: _isSaving ? 'Saving...' : 'Save Changes',
                                onPressed: _isSaving ? null : () => _saveProfile(userId),
                                icon: Icons.save,
                                isAccent: true,
                              ),

                            const SizedBox(height: 100),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(bool isDark, Student student) {
    final name = student.name;
    final email = student.email;

    return NeumorphicContainer(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      child: Column(
        children: [
          // Profile Image Picker
          ProfileImagePicker(
            initialImageUrl: student.profilePhoto,
            size: 100,
            onImagePicked: _handleImagePicked,
            onImageBytesPickedForWeb: _handleImageBytesPickedForWeb,
            isLoading: _isUploadingImage,
          ),
          const SizedBox(height: AppDimensions.spacingM),

          // Name
          Text(
            name,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
            ),
          ),
          const SizedBox(height: 4),

          // Email
          Text(
            email,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required bool isDark,
    required List<Widget> children,
  }) {
    return NeumorphicContainer(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: (isDark ? AppColors.accent : AppColorsLight.accent).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: isDark ? AppColors.accent : AppColorsLight.accent,
                ),
              ),
              const SizedBox(width: AppDimensions.spacingM),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.spacingM),

          // Section Content
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingS),
            decoration: BoxDecoration(
              color: isDark ? AppColors.background : AppColorsLight.background,
              borderRadius: BorderRadius.circular(AppDimensions.radiusS),
              boxShadow: NeumorphicStyles.getSmallInsetShadow(),
            ),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool isDark, {bool isFullWidth = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingS),
      child: isFullWidth
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
                  ),
                ),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
                  ),
                ),
                const Spacer(),
                Expanded(
                  flex: 2,
                  child: Text(
                    value,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildStatusRow(String label, String value, bool isPositive, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingS),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingM,
              vertical: AppDimensions.spacingXs,
            ),
            decoration: BoxDecoration(
              color: isPositive
                  ? (isDark ? AppColors.success : AppColorsLight.success).withValues(alpha: 0.1)
                  : (isDark ? AppColors.error : AppColorsLight.error).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusS),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isPositive ? Icons.check_circle : Icons.cancel,
                  size: 14,
                  color: isPositive
                      ? (isDark ? AppColors.success : AppColorsLight.success)
                      : (isDark ? AppColors.error : AppColorsLight.error),
                ),
                const SizedBox(width: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isPositive
                        ? (isDark ? AppColors.success : AppColorsLight.success)
                        : (isDark ? AppColors.error : AppColorsLight.error),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return CustomTextField(
      controller: controller,
      label: label,
      prefixIcon: icon,
      keyboardType: keyboardType,
      maxLines: maxLines,
      enabled: !_isSaving,
    );
  }

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      final months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

}
