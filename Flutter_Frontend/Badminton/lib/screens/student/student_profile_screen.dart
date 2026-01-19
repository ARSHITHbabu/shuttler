import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../core/theme/neumorphic_styles.dart';
import '../../widgets/common/neumorphic_container.dart';
import '../../widgets/common/neumorphic_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/loading_spinner.dart';
import '../../widgets/common/profile_image_picker.dart';
import '../../widgets/common/cached_profile_image.dart';
import '../../providers/service_providers.dart';
import '../../providers/auth_provider.dart';
import '../../core/constants/api_endpoints.dart';

/// Student Profile Screen - View and edit profile information
/// Students can view all their profile data and edit certain fields
class StudentProfileScreen extends ConsumerStatefulWidget {
  final VoidCallback? onBack;

  const StudentProfileScreen({super.key, this.onBack});

  @override
  ConsumerState<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends ConsumerState<StudentProfileScreen> {
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isEditing = false;
  bool _isUploadingImage = false;
  Map<String, dynamic> _studentData = {};
  String? _error;
  File? _selectedImage;
  String? _profilePhotoUrl;

  // Controllers for editable fields
  final _phoneController = TextEditingController();
  final _guardianNameController = TextEditingController();
  final _guardianPhoneController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _guardianNameController.dispose();
    _guardianPhoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

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

      final apiService = ref.read(apiServiceProvider);
      final response = await apiService.get('/api/students/$userId');
      if (response.statusCode == 200) {
        _studentData = Map<String, dynamic>.from(response.data);
        _profilePhotoUrl = _studentData['profile_photo']?.toString();
        _populateControllers();
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString().replaceAll('Exception: ', '');
        });
      }
    }
  }

  void _populateControllers() {
    _phoneController.text = _studentData['phone']?.toString() ?? '';
    _guardianNameController.text = _studentData['guardian_name']?.toString() ?? '';
    _guardianPhoneController.text = _studentData['guardian_phone']?.toString() ?? '';
    _addressController.text = _studentData['address']?.toString() ?? '';
  }

  Future<void> _handleImagePicked(File? image) async {
    if (image == null) {
      setState(() {
        _selectedImage = null;
        _profilePhotoUrl = null;
      });
      return;
    }

    setState(() {
      _selectedImage = image;
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

      // Update profile with new image URL
      await apiService.put(
        '/api/students/$userId',
        data: {'profile_photo': imageUrl},
      );

      setState(() {
        _profilePhotoUrl = imageUrl;
        _studentData['profile_photo'] = imageUrl;
        _isUploadingImage = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile photo updated successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isUploadingImage = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload image: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
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

      final apiService = ref.read(apiServiceProvider);
      final updateData = {
        'phone': _phoneController.text.trim(),
        'guardian_name': _guardianNameController.text.trim(),
        'guardian_phone': _guardianPhoneController.text.trim(),
        'address': _addressController.text.trim(),
      };

      final response = await apiService.put(
        '/api/students/$userId',
        data: updateData,
      );

      if (response.statusCode == 200) {
        // Update local data
        _studentData = {..._studentData, ...updateData};

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully'),
              backgroundColor: AppColors.success,
            ),
          );
          setState(() {
            _isEditing = false;
          });
        }
      } else {
        throw Exception('Failed to update profile');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _cancelEditing() {
    _populateControllers();
    setState(() {
      _isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              backgroundColor: Colors.transparent,
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
                if (!_isLoading && _error == null)
                  IconButton(
                    icon: Icon(
                      _isEditing ? Icons.close : Icons.edit,
                      color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
                    ),
                    onPressed: _isEditing ? _cancelEditing : () => setState(() => _isEditing = true),
                  ),
              ],
            ),

            // Content
            SliverToBoxAdapter(
              child: _isLoading
                  ? const SizedBox(
                      height: 400,
                      child: Center(child: LoadingSpinner()),
                    )
                  : _error != null
                      ? _buildErrorWidget(isDark)
                      : Padding(
                          padding: const EdgeInsets.all(AppDimensions.paddingL),
                          child: Column(
                            children: [
                              // Profile Header
                              _buildProfileHeader(isDark),

                              const SizedBox(height: AppDimensions.spacingL),

                              // Personal Information Section
                              _buildSection(
                                title: 'Personal Information',
                                icon: Icons.person_outline,
                                isDark: isDark,
                                children: [
                                  _buildInfoRow('Name', _studentData['name']?.toString() ?? 'N/A', isDark),
                                  _buildInfoRow('Email', _studentData['email']?.toString() ?? 'N/A', isDark),
                                  if (_isEditing)
                                    _buildEditableField(
                                      controller: _phoneController,
                                      label: 'Phone',
                                      icon: Icons.phone_outlined,
                                      isDark: isDark,
                                      keyboardType: TextInputType.phone,
                                    )
                                  else
                                    _buildInfoRow('Phone', _studentData['phone']?.toString() ?? 'Not set', isDark),
                                  _buildInfoRow(
                                    'Date of Birth',
                                    _formatDate(_studentData['date_of_birth']?.toString() ?? ''),
                                    isDark,
                                  ),
                                  _buildInfoRow('Gender', _capitalize(_studentData['gender']?.toString() ?? 'Not set'), isDark),
                                  _buildInfoRow('Blood Group', _studentData['blood_group']?.toString() ?? 'Not set', isDark),
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
                                    _buildInfoRow('Name', _studentData['guardian_name']?.toString() ?? 'Not set', isDark),
                                    _buildInfoRow('Phone', _studentData['guardian_phone']?.toString() ?? 'Not set', isDark),
                                  ],
                                  _buildInfoRow(
                                    'Relationship',
                                    _capitalize(_studentData['guardian_relationship']?.toString() ?? 'Not set'),
                                    isDark,
                                  ),
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
                                    _buildInfoRow('Address', _studentData['address']?.toString() ?? 'Not set', isDark, isFullWidth: true),
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
                                    _studentData['is_active'] == true ? 'Active' : 'Inactive',
                                    _studentData['is_active'] == true,
                                    isDark,
                                  ),
                                  _buildStatusRow(
                                    'Batch Linked',
                                    _studentData['is_linked'] == true ? 'Yes' : 'No',
                                    _studentData['is_linked'] == true,
                                    isDark,
                                  ),
                                  _buildInfoRow(
                                    'Member Since',
                                    _formatDate(_studentData['created_at']?.toString() ?? ''),
                                    isDark,
                                  ),
                                ],
                              ),

                              const SizedBox(height: AppDimensions.spacingXl),

                              // Save Button
                              if (_isEditing)
                                NeumorphicButton(
                                  text: _isSaving ? 'Saving...' : 'Save Changes',
                                  onPressed: _isSaving ? null : _saveProfile,
                                  icon: Icons.save,
                                  isAccent: true,
                                ),

                              const SizedBox(height: 100),
                            ],
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: isDark ? AppColors.error : AppColorsLight.error,
          ),
          const SizedBox(height: AppDimensions.spacingM),
          Text(
            _error!,
            style: TextStyle(
              color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.spacingL),
          ElevatedButton(
            onPressed: _loadData,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(bool isDark) {
    final name = _studentData['name']?.toString() ?? 'Student';
    final email = _studentData['email']?.toString() ?? '';
    final initials = name.isNotEmpty
        ? name.split(' ').map((n) => n.isNotEmpty ? n[0] : '').take(2).join().toUpperCase()
        : 'S';

    return NeumorphicContainer(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      child: Column(
        children: [
          // Profile Image Picker
          ProfileImagePicker(
            initialImageUrl: _profilePhotoUrl,
            size: 100,
            onImagePicked: _handleImagePicked,
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
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

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
