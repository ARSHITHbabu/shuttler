import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../widgets/common/neumorphic_container.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/skeleton_screen.dart';
import '../../widgets/common/success_snackbar.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/neumorphic_button.dart';
import '../../widgets/common/profile_image_picker.dart';
import '../../providers/auth_provider.dart';
import '../../providers/service_providers.dart';
import '../../providers/coach_provider.dart';
import '../../models/coach.dart';

/// Coach Profile Screen - View and edit coach profile
class CoachProfileScreen extends ConsumerStatefulWidget {
  const CoachProfileScreen({super.key});

  @override
  ConsumerState<CoachProfileScreen> createState() => _CoachProfileScreenState();
}

class _CoachProfileScreenState extends ConsumerState<CoachProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _specializationController = TextEditingController();
  final _experienceController = TextEditingController();
  
  bool _isSaving = false;
  bool _isUploadingImage = false;
  Coach? _coach;
  File? _selectedImage;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _specializationController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    
    return authState.when(
      data: (authValue) {
        if (authValue is! Authenticated) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Profile'),
            ),
            body: const Center(
              child: Text(
                'Please login',
                style: TextStyle(color: AppColors.error),
              ),
            ),
          );
        }

        final coachId = authValue.userId;
        return _buildScaffold(coachId);
      },
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(child: ProfileSkeleton()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: Center(
          child: Text(
            'Error: ${error.toString()}',
            style: const TextStyle(color: AppColors.error),
          ),
        ),
      ),
    );
  }

  Widget _buildScaffold(int coachId) {
    final coachAsync = ref.watch(coachByIdProvider(coachId));
    final coachStatsAsync = ref.watch(coachStatsProvider(coachId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(coachByIdProvider(coachId));
          ref.invalidate(coachStatsProvider(coachId));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: coachAsync.when(
            loading: () => const ProfileSkeleton(),
            error: (error, stack) => ErrorDisplay(
              message: 'Failed to load profile: ${error.toString()}',
              onRetry: () => ref.invalidate(coachByIdProvider(coachId)),
            ),
            data: (coach) {
              if (_coach == null || _coach!.id != coach.id) {
                _coach = coach;
                _nameController.text = coach.name;
                _phoneController.text = coach.phone;
                _specializationController.text = coach.specialization ?? '';
                _experienceController.text = coach.experienceYears?.toString() ?? '';
              }

              return _buildContent(coach, coachStatsAsync);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContent(Coach coach, AsyncValue<CoachStats> statsAsync) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Header
              Center(
                child: Column(
                  children: [
                    ProfileImagePicker(
                      initialImageUrl: coach.profilePhoto,
                      size: 100,
                      onImagePicked: _handleImagePicked,
                      isLoading: _isUploadingImage,
                    ),
                    const SizedBox(height: AppDimensions.spacingM),
                    Text(
                      coach.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      coach.email,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimensions.spacingL),

              // Personal Information
              const _SectionTitle(title: 'Personal Information'),
              const SizedBox(height: AppDimensions.spacingM),

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

              CustomTextField(
                controller: TextEditingController(text: coach.email),
                label: 'Email',
                prefixIcon: Icons.email_outlined,
                enabled: false,
                readOnly: true,
              ),

              const SizedBox(height: AppDimensions.spacingM),

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

              // Professional Information
              const _SectionTitle(title: 'Professional Information'),
              const SizedBox(height: AppDimensions.spacingM),

              CustomTextField(
                controller: _specializationController,
                label: 'Specialization',
                prefixIcon: Icons.star_outline,
                hint: 'e.g., Advanced Training, Beginners',
              ),

              const SizedBox(height: AppDimensions.spacingM),

              CustomTextField(
                controller: _experienceController,
                label: 'Experience (Years)',
                prefixIcon: Icons.work_outline,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final years = int.tryParse(value);
                    if (years == null || years < 0 || years > 50) {
                      return 'Enter valid experience (0-50 years)';
                    }
                  }
                  return null;
                },
              ),

              const SizedBox(height: AppDimensions.spacingL),

              // Statistics Section
              const _SectionTitle(title: 'My Statistics'),
              const SizedBox(height: AppDimensions.spacingM),

              statsAsync.when(
                data: (stats) => NeumorphicContainer(
                  padding: const EdgeInsets.all(AppDimensions.paddingM),
                  child: Column(
                    children: [
                      _StatRow(
                        label: 'Total Batches Assigned',
                        value: stats.assignedBatches.toString(),
                      ),
                      const Divider(),
                      _StatRow(
                        label: 'Total Students',
                        value: stats.totalStudents.toString(),
                      ),
                      const Divider(),
                      _StatRow(
                        label: 'Attendance Rate',
                        value: '${stats.attendanceRate.toStringAsFixed(1)}%',
                      ),
                    ],
                  ),
                ),
                loading: () => const Center(child: ListSkeleton(itemCount: 3)),
                error: (error, stack) => const SizedBox(),
              ),

              const SizedBox(height: AppDimensions.spacingL),

              // Save Button
              NeumorphicButton(
                text: _isSaving ? 'Saving...' : 'Save Changes',
                onPressed: _isSaving ? null : _saveProfile,
                icon: _isSaving ? null : Icons.save_outlined,
                isAccent: true,
              ),

              const SizedBox(height: 100), // Space for bottom nav
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleImagePicked(File? image) async {
    if (image == null) {
      setState(() {
        _selectedImage = null;
      });
      return;
    }

    setState(() {
      _selectedImage = image;
      _isUploadingImage = true;
    });

    try {
      final authState = ref.read(authProvider);
      if (authState.value is! Authenticated) {
        throw Exception('Not authenticated');
      }

      final coachId = (authState.value as Authenticated).userId;
      final apiService = ref.read(apiServiceProvider);
      
      // Upload image
      final imageUrl = await apiService.uploadImage(image.path);

      // Update profile with new image URL
      final coachService = ref.read(coachServiceProvider);
      await coachService.updateCoach(coachId, {
        'profile_photo': imageUrl,
      });

      setState(() {
        _isUploadingImage = false;
        _coach = null; // Force refresh
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
      final coachService = ref.read(coachServiceProvider);
      final authState = ref.read(authProvider);
      
      if (authState.value is! Authenticated) {
        throw Exception('Not authenticated');
      }

      final coachId = (authState.value as Authenticated).userId;

      await coachService.updateCoach(coachId, {
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'specialization': _specializationController.text.trim().isEmpty
            ? null
            : _specializationController.text.trim(),
        'experience_years': _experienceController.text.trim().isEmpty
            ? null
            : int.tryParse(_experienceController.text.trim()),
      });

      if (mounted) {
        SuccessSnackbar.show(context, 'Profile updated successfully');
        // Refresh profile
        setState(() {
          _coach = null;
        });
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

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingS),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
