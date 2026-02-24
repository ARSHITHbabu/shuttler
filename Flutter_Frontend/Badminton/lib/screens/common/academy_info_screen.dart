import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../widgets/common/neumorphic_container.dart';
import '../../providers/service_providers.dart';
import '../../providers/owner_provider.dart';
import '../../core/utils/contact_utils.dart';

class AcademyInfoScreen extends ConsumerWidget {
  final VoidCallback? onBack;

  const AcademyInfoScreen({super.key, this.onBack});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = isDark ? AppColors.background : AppColorsLight.background;
    final textPrimaryColor = isDark ? AppColors.textPrimary : AppColorsLight.textPrimary;
    final textSecondaryColor = isDark ? AppColors.textSecondary : AppColorsLight.textSecondary;

    final storageService = ref.watch(storageServiceProvider);
    final ownerAsync = ref.watch(activeOwnerProvider);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textPrimaryColor),
          onPressed: onBack ?? () => Navigator.of(context).pop(),
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
      body: ownerAsync.when(
        data: (owner) {
          final academyName = owner?.academyName ?? storageService.getAcademyName() ?? 'Not Set';
          final academyAddress = owner?.academyAddress ?? storageService.getAcademyAddress() ?? 'Not Set';
          final academyContact = owner?.academyContact ?? storageService.getAcademyContact() ?? 'Not Set';
          final academyEmail = owner?.academyEmail ?? storageService.getAcademyEmail() ?? 'Not Set';

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Academy Information Section
                  _buildSectionTitle('Academy Information', textSecondaryColor),
                  const SizedBox(height: AppDimensions.spacingM),
                  NeumorphicContainer(
                    padding: const EdgeInsets.all(AppDimensions.paddingM),
                    child: Column(
                      children: [
                        _buildInfoRow(
                          Icons.school_outlined,
                          'Name',
                          academyName,
                          isDark,
                        ),
                        const Divider(height: 32),
                        _buildInfoRow(
                          Icons.location_on_outlined,
                          'Address',
                          academyAddress,
                          isDark,
                        ),
                        const Divider(height: 32),
                        _buildInfoRow(
                          Icons.phone_outlined,
                          'General Contact',
                          academyContact,
                          isDark,
                        ),
                        const Divider(height: 32),
                        _buildInfoRow(
                          Icons.email_outlined,
                          'General Email',
                          academyEmail,
                          isDark,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppDimensions.spacingL),

                  // Owner Information Section
                  _buildSectionTitle('Owner Details', textSecondaryColor),
                  const SizedBox(height: AppDimensions.spacingM),
                  if (owner == null)
                    Text(
                      'Owner information not available',
                      style: TextStyle(color: textSecondaryColor),
                    )
                  else
                    NeumorphicContainer(
                      padding: const EdgeInsets.all(AppDimensions.paddingM),
                      child: Column(
                        children: [
                          _buildInfoRow(
                            Icons.person_outline,
                            'Owner Name',
                            owner.name,
                            isDark,
                          ),
                          const Divider(height: 32),
                          _buildInfoRow(
                            Icons.phone_outlined,
                            'Owner Contact',
                            owner.phone,
                            isDark,
                            onTap: () => ContactUtils.showContactOptions(
                              context,
                              owner.phone,
                              name: owner.name,
                            ),
                          ),
                          const Divider(height: 32),
                          _buildInfoRow(
                            Icons.email_outlined,
                            'Owner Email',
                            owner.email,
                            isDark,
                            onTap: () => ContactUtils.launchEmail(owner.email),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingL),
            child: Text('Error loading academy details: $err', textAlign: TextAlign.center),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color color) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: color,
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, bool isDark, {VoidCallback? onTap}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(AppDimensions.paddingS),
          decoration: BoxDecoration(
            color: (isDark ? AppColors.accent : AppColorsLight.accent).withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppDimensions.radiusS),
          ),
          child: Icon(
            icon,
            size: 20,
            color: isDark ? AppColors.accent : AppColorsLight.accent,
          ),
        ),
        const SizedBox(width: AppDimensions.spacingM),
        Expanded(
          child: Column(
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
              onTap != null
                  ? InkWell(
                      onTap: onTap,
                      borderRadius: BorderRadius.circular(4),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                        child: Text(
                          value,
                          style: TextStyle(
                            fontSize: 15,
                            color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.underline,
                            decorationColor: (isDark ? AppColors.accent : AppColorsLight.accent).withOpacity(0.5),
                          ),
                        ),
                      ),
                    )
                  : Text(
                      value,
                      style: TextStyle(
                        fontSize: 15,
                        color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
            ],
          ),
        ),
        if (onTap != null)
          Icon(
            Icons.open_in_new,
            size: 14,
            color: isDark ? AppColors.textTertiary : AppColorsLight.textTertiary,
          ),
      ],
    );
  }
}
