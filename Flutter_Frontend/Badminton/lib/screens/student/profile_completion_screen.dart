import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../core/utils/validators.dart';
import '../../widgets/common/neumorphic_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/success_snackbar.dart';
import '../../providers/service_providers.dart';
import '../../providers/auth_provider.dart';
import '../../providers/student_provider.dart';

/// Profile completion screen for students
/// Students must fill all required profile fields before accessing the dashboard
class ProfileCompletionScreen extends ConsumerStatefulWidget {
  const ProfileCompletionScreen({super.key});

  @override
  ConsumerState<ProfileCompletionScreen> createState() =>
      _ProfileCompletionScreenState();
}

class _ProfileCompletionScreenState
    extends ConsumerState<ProfileCompletionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _guardianNameController = TextEditingController();
  final _guardianPhoneController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  final _addressController = TextEditingController();
  final _tShirtSizeController = TextEditingController();

  bool _isLoading = false;
  DateTime? _selectedDate;
  String? _selectedTShirtSize;
  String? _selectedBloodGroup;
  String? _profilePhotoUrl;

  final List<String> _tShirtSizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL', 'XXXL'];

  final List<String> _bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  @override
  void dispose() {
    _guardianNameController.dispose();
    _guardianPhoneController.dispose();
    _dateOfBirthController.dispose();
    _addressController.dispose();
    _tShirtSizeController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 10)),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.accent,
              onPrimary: AppColors.textPrimary,
              surface: AppColors.cardBackground,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateOfBirthController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedTShirtSize == null) {
      SuccessSnackbar.showError(context, 'Please select a T-shirt size');
      return;
    }

    if (_selectedBloodGroup == null) {
      SuccessSnackbar.showError(context, 'Please select your blood group');
      return;
    }

    setState(() => _isLoading = true);

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

      // Prepare update data
      final updateData = {
        'guardian_name': _guardianNameController.text.trim(),
        'guardian_phone': _guardianPhoneController.text.trim(),
        'date_of_birth': _dateOfBirthController.text.trim(),
        'address': _addressController.text.trim(),
        't_shirt_size': _selectedTShirtSize,
        'blood_group': _selectedBloodGroup,
        if (_profilePhotoUrl != null) 'profile_photo': _profilePhotoUrl,
      };

      // Update student profile using provider
      final studentList = ref.read(studentListProvider.notifier);
      await studentList.updateStudent(userId, updateData);

      // Invalidate to refresh data
      ref.invalidate(studentByIdProvider(userId));
      ref.invalidate(studentDashboardProvider(userId));

      if (mounted) {
        SuccessSnackbar.show(context, 'Profile completed successfully!');

        // Navigate to student dashboard
        context.go('/student-dashboard');
      }
    } catch (e) {
      if (mounted) {
        SuccessSnackbar.showError(
          context,
          e.toString().replaceAll('Exception: ', ''),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Complete Your Profile',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppDimensions.spacingM),

                // Info message
                Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingM),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: AppColors.info,
                        size: 24,
                      ),
                      const SizedBox(width: AppDimensions.spacingM),
                      Expanded(
                        child: Text(
                          'Please complete your profile to continue. All fields are required.',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppDimensions.spacingXl),

                // Guardian Name Field
                CustomTextField(
                  controller: _guardianNameController,
                  label: 'Guardian Name *',
                  hint: 'Enter guardian\'s full name',
                  prefixIcon: Icons.person_outline,
                  validator: Validators.validateName,
                  enabled: !_isLoading,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppDimensions.spacingL),

                // Guardian Phone Field
                CustomTextField(
                  controller: _guardianPhoneController,
                  label: 'Guardian Phone Number *',
                  hint: 'Enter guardian\'s phone number',
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.phone_outlined,
                  validator: Validators.validatePhone,
                  enabled: !_isLoading,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppDimensions.spacingL),

                // Date of Birth Field
                CustomTextField(
                  controller: _dateOfBirthController,
                  label: 'Date of Birth *',
                  hint: 'Select your date of birth',
                  prefixIcon: Icons.calendar_today_outlined,
                  readOnly: true,
                  onTap: () => _selectDate(context),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select your date of birth';
                    }
                    return null;
                  },
                  enabled: !_isLoading,
                ),
                const SizedBox(height: AppDimensions.spacingL),

                // Address Field
                CustomTextField(
                  controller: _addressController,
                  label: 'Address *',
                  hint: 'Enter your complete address',
                  prefixIcon: Icons.location_on_outlined,
                  validator: Validators.validateAddress,
                  enabled: !_isLoading,
                  maxLines: 3,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppDimensions.spacingL),

                // T-Shirt Size Dropdown
                DropdownButtonFormField<String>(
                  initialValue: _selectedTShirtSize,
                  decoration: InputDecoration(
                    labelText: 'T-Shirt Size *',
                    hintText: 'Select your T-shirt size',
                    prefixIcon: const Icon(
                      Icons.checkroom_outlined,
                      color: AppColors.textSecondary,
                    ),
                    filled: true,
                    fillColor: AppColors.cardBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusM,
                      ),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusM,
                      ),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusM,
                      ),
                      borderSide: const BorderSide(
                        color: AppColors.accent,
                        width: 2,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusM,
                      ),
                      borderSide: const BorderSide(
                        color: AppColors.error,
                        width: 1,
                      ),
                    ),
                    labelStyle: const TextStyle(color: AppColors.textSecondary),
                    hintStyle: const TextStyle(color: AppColors.textHint),
                  ),
                  dropdownColor: AppColors.cardBackground,
                  style: const TextStyle(color: AppColors.textPrimary),
                  items: _tShirtSizes.map((String size) {
                    return DropdownMenuItem<String>(
                      value: size,
                      child: Text(size),
                    );
                  }).toList(),
                  onChanged: _isLoading
                      ? null
                      : (String? newValue) {
                          setState(() {
                            _selectedTShirtSize = newValue;
                          });
                        },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a T-shirt size';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.spacingL),

                // Blood Group Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedBloodGroup,
                  decoration: InputDecoration(
                    labelText: 'Blood Group *',
                    hintText: 'Select your blood group',
                    prefixIcon: const Icon(
                      Icons.bloodtype_outlined,
                      color: AppColors.textSecondary,
                    ),
                    filled: true,
                    fillColor: AppColors.cardBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusM,
                      ),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusM,
                      ),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusM,
                      ),
                      borderSide: const BorderSide(
                        color: AppColors.accent,
                        width: 2,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusM,
                      ),
                      borderSide: const BorderSide(
                        color: AppColors.error,
                        width: 1,
                      ),
                    ),
                    labelStyle: const TextStyle(color: AppColors.textSecondary),
                    hintStyle: const TextStyle(color: AppColors.textHint),
                  ),
                  dropdownColor: AppColors.cardBackground,
                  style: const TextStyle(color: AppColors.textPrimary),
                  items: _bloodGroups.map((String group) {
                    return DropdownMenuItem<String>(
                      value: group,
                      child: Text(group),
                    );
                  }).toList(),
                  onChanged: _isLoading
                      ? null
                      : (String? newValue) {
                          setState(() {
                            _selectedBloodGroup = newValue;
                          });
                        },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select your blood group';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.spacingXl),

                // Profile Photo Section (Placeholder for Phase 3)
                // TODO: Implement image picker in Phase 3
                Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingM),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  ),
                  child: Column(
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.camera_alt_outlined,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                          SizedBox(width: AppDimensions.spacingS),
                          Text(
                            'Profile Photo *',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.spacingM),
                      Text(
                        'Profile photo upload will be available in Phase 3',
                        style: const TextStyle(
                          color: AppColors.textHint,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingXl),

                // Submit Button
                NeumorphicButton(
                  text: 'Complete Profile',
                  onPressed: _isLoading ? null : _handleSubmit,
                  icon: Icons.check_circle_outline,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
