import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../widgets/common/neumorphic_container.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/neumorphic_button.dart';
import '../../widgets/common/success_snackbar.dart';
import '../../providers/service_providers.dart';

/// Academy Details Screen - Edit academy information
class AcademyDetailsScreen extends ConsumerStatefulWidget {
  const AcademyDetailsScreen({super.key});

  @override
  ConsumerState<AcademyDetailsScreen> createState() => _AcademyDetailsScreenState();
}

class _AcademyDetailsScreenState extends ConsumerState<AcademyDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _academyNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _contactController = TextEditingController();
  final _emailController = TextEditingController();
  
  bool _isSaving = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAcademyDetails();
  }

  @override
  void dispose() {
    _academyNameController.dispose();
    _addressController.dispose();
    _contactController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadAcademyDetails() async {
    try {
      final storageService = ref.read(storageServiceProvider);
      if (!storageService.isInitialized) {
        await storageService.init();
      }

      setState(() {
        _academyNameController.text = storageService.getAcademyName() ?? '';
        _addressController.text = storageService.getAcademyAddress() ?? '';
        _contactController.text = storageService.getAcademyContact() ?? '';
        _emailController.text = storageService.getAcademyEmail() ?? '';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveAcademyDetails() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final storageService = ref.read(storageServiceProvider);
      if (!storageService.isInitialized) {
        await storageService.init();
      }

      await storageService.saveAcademyName(_academyNameController.text.trim());
      await storageService.saveAcademyAddress(_addressController.text.trim());
      await storageService.saveAcademyContact(_contactController.text.trim());
      await storageService.saveAcademyEmail(_emailController.text.trim());

      if (mounted) {
        SuccessSnackbar.show(context, 'Academy details saved successfully');
      }
    } catch (e) {
      if (mounted) {
        SuccessSnackbar.showError(context, 'Failed to save academy details: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = theme.scaffoldBackgroundColor;
    final textPrimaryColor = theme.colorScheme.onSurface;

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
          'Academy Details',
          style: TextStyle(
            color: textPrimaryColor,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingL),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Academy Name Field
                      CustomTextField(
                        controller: _academyNameController,
                        label: 'Academy Name',
                        prefixIcon: Icons.school_outlined,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Academy name is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppDimensions.spacingM),

                      // Address Field
                      CustomTextField(
                        controller: _addressController,
                        label: 'Address',
                        prefixIcon: Icons.location_on_outlined,
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Address is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppDimensions.spacingM),

                      // Contact Number Field
                      CustomTextField(
                        controller: _contactController,
                        label: 'Contact Number',
                        prefixIcon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Contact number is required';
                          }
                          if (value.length < 10) {
                            return 'Enter a valid contact number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppDimensions.spacingM),

                      // Email Field
                      CustomTextField(
                        controller: _emailController,
                        label: 'Academy Email',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Email is required';
                          }
                          if (!value.contains('@')) {
                            return 'Enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppDimensions.spacingL),

                      // Save Button
                      NeumorphicButton(
                        text: _isSaving ? 'Saving...' : 'Save Changes',
                        onPressed: _isSaving ? null : _saveAcademyDetails,
                        icon: _isSaving ? null : Icons.save_outlined,
                        isAccent: true,
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
