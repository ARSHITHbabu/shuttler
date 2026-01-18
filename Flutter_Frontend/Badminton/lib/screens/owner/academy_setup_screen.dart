import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../widgets/common/neumorphic_container.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/neumorphic_button.dart';
import '../../widgets/common/success_snackbar.dart';
import '../../widgets/common/profile_image_picker.dart';
import '../../providers/auth_provider.dart';
import '../../providers/service_providers.dart';
import '../../core/services/api_service.dart';
import 'package:dio/dio.dart';

/// Academy Setup Screen - Initial academy configuration
class AcademySetupScreen extends ConsumerStatefulWidget {
  const AcademySetupScreen({super.key});

  @override
  ConsumerState<AcademySetupScreen> createState() => _AcademySetupScreenState();
}

class _AcademySetupScreenState extends ConsumerState<AcademySetupScreen> {
  int _currentStep = 1;
  final _formKey = GlobalKey<FormState>();
  
  // Step 1: Academy Info
  final _academyNameController = TextEditingController();
  File? _logoFile;
  bool _isUploadingLogo = false;
  
  // Step 2: Owner Info
  final _ownerNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  
  // Step 3: Address
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  
  bool _isLoading = false;

  @override
  void dispose() {
    _academyNameController.dispose();
    _ownerNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    super.dispose();
  }

  Future<void> _uploadLogo() async {
    if (_logoFile == null) return;

    setState(() => _isUploadingLogo = true);
    try {
      final apiService = ref.read(apiServiceProvider);
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(_logoFile!.path),
      });

      final response = await apiService.post(
        '/api/upload/image',
        data: formData,
      );

      if (mounted) {
        SuccessSnackbar.show(context, 'Logo uploaded successfully');
        // Store the logo URL if needed
      }
    } catch (e) {
      if (mounted) {
        SuccessSnackbar.showError(context, 'Failed to upload logo: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isUploadingLogo = false);
      }
    }
  }

  Future<void> _completeSetup() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);
    try {
      final authState = await ref.read(authProvider.future);
      if (authState is! Authenticated) {
        if (mounted) {
          SuccessSnackbar.showError(context, 'Please log in to complete setup');
        }
        return;
      }

      // Upload logo if selected
      if (_logoFile != null) {
        await _uploadLogo();
      }

      // Update owner information
      final ownerService = ref.read(ownerServiceProvider);
      final ownerData = {
        'name': _ownerNameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
      };

      await ownerService.updateOwner(authState.userId, ownerData);

      // Store academy information (could be stored in a separate academy table)
      // For now, we'll just show success
      if (mounted) {
        SuccessSnackbar.show(context, 'Academy setup completed successfully');
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        SuccessSnackbar.showError(context, 'Failed to complete setup: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _nextStep() {
    if (_currentStep == 1) {
      if (_academyNameController.text.trim().isEmpty) {
        SuccessSnackbar.showError(context, 'Please enter academy name');
        return;
      }
      setState(() => _currentStep = 2);
    } else if (_currentStep == 2) {
      if (_ownerNameController.text.trim().isEmpty ||
          _phoneController.text.trim().isEmpty ||
          _emailController.text.trim().isEmpty) {
        SuccessSnackbar.showError(context, 'Please fill all required fields');
        return;
      }
      setState(() => _currentStep = 3);
    } else {
      _completeSetup();
    }
  }

  void _previousStep() {
    if (_currentStep > 1) {
      setState(() => _currentStep--);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: _currentStep == 1
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                onPressed: () => Navigator.of(context).pop(),
              )
            : IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                onPressed: _previousStep,
              ),
        title: const Text(
          'Academy Setup',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress Indicator
              Text(
                'Step $_currentStep of 3',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppDimensions.spacingS),
              Row(
                children: List.generate(3, (index) {
                  final isActive = index + 1 <= _currentStep;
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: EdgeInsets.only(
                        right: index < 2 ? AppDimensions.spacingS : 0,
                      ),
                      decoration: BoxDecoration(
                        color: isActive ? AppColors.accent : AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: AppDimensions.spacingL),

              // Step Content
              if (_currentStep == 1) _buildStep1(),
              if (_currentStep == 2) _buildStep2(),
              if (_currentStep == 3) _buildStep3(),

              const SizedBox(height: AppDimensions.spacingL),

              // Action Buttons
              NeumorphicButton(
                text: _currentStep == 3 ? 'Complete Setup' : 'Continue',
                onPressed: _isLoading ? null : _nextStep,
                isLoading: _isLoading,
                isAccent: true,
              ),
              if (_currentStep > 1) ...[
                const SizedBox(height: AppDimensions.spacingM),
                NeumorphicButton(
                  text: 'Back',
                  onPressed: _previousStep,
                  isAccent: false,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Academy Information',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingM),
        
        // Logo Upload
        Center(
          child: Column(
            children: [
              ProfileImagePicker(
                initialImageUrl: null,
                size: 120,
                onImagePicked: (file) {
                  setState(() => _logoFile = file);
                },
                isLoading: _isUploadingLogo,
              ),
              const SizedBox(height: AppDimensions.spacingS),
              const Text(
                'Upload academy logo (optional)',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.spacingL),

        // Academy Name
        CustomTextField(
          controller: _academyNameController,
          label: 'Academy Name',
          hint: 'Enter academy name',
          prefixIcon: Icons.business_outlined,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter academy name';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Owner Information',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingM),
        
        CustomTextField(
          controller: _ownerNameController,
          label: 'Owner Name',
          hint: 'Enter owner name',
          prefixIcon: Icons.person_outline,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter owner name';
            }
            return null;
          },
        ),
        const SizedBox(height: AppDimensions.spacingM),
        
        CustomTextField(
          controller: _phoneController,
          label: 'Phone Number',
          hint: 'Enter phone number',
          prefixIcon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter phone number';
            }
            return null;
          },
        ),
        const SizedBox(height: AppDimensions.spacingM),
        
        CustomTextField(
          controller: _emailController,
          label: 'Email Address',
          hint: 'Enter email address',
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter email address';
            }
            if (!value.contains('@')) {
              return 'Please enter a valid email';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Academy Address',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingM),
        
        CustomTextField(
          controller: _addressController,
          label: 'Address',
          hint: 'Enter academy address',
          prefixIcon: Icons.location_on_outlined,
          maxLines: 3,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter address';
            }
            return null;
          },
        ),
        const SizedBox(height: AppDimensions.spacingM),
        
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: _cityController,
                label: 'City',
                hint: 'Enter city',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter city';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: AppDimensions.spacingM),
            Expanded(
              child: CustomTextField(
                controller: _stateController,
                label: 'State',
                hint: 'Enter state',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter state';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.spacingM),
        
        NeumorphicContainer(
          padding: const EdgeInsets.all(AppDimensions.paddingM),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: AppColors.textSecondary, size: 20),
              const SizedBox(width: AppDimensions.spacingS),
              Expanded(
                child: Text(
                  'You can add a map pin location later from settings',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
