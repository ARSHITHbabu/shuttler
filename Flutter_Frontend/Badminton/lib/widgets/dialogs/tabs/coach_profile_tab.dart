import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/dimensions.dart';
import '../../../widgets/common/neumorphic_container.dart';
import '../../../widgets/common/success_snackbar.dart';
import '../../../widgets/common/confirmation_dialog.dart';
import '../../../providers/coach_provider.dart';
import '../../../models/coach.dart';
import '../../../core/utils/contact_utils.dart';

/// Profile Tab - Shows coach information and management actions
class CoachProfileTab extends ConsumerStatefulWidget {
  final Coach coach;
  final VoidCallback? onCoachUpdated;

  const CoachProfileTab({
    super.key,
    required this.coach,
    this.onCoachUpdated,
  });

  @override
  ConsumerState<CoachProfileTab> createState() => _CoachProfileTabState();
}

class _CoachProfileTabState extends ConsumerState<CoachProfileTab> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Header
          _buildProfileHeader(),
          
          const SizedBox(height: AppDimensions.spacingL),
          
          // Contact Information
          _buildContactInfo(),
          
          const SizedBox(height: AppDimensions.spacingL),

          // Professional Information
          _buildProfessionalInfo(),
          
          const SizedBox(height: AppDimensions.spacingL),
          
          // Action Buttons
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return NeumorphicContainer(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                widget.coach.name[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accent,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.coach.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingXs),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacingS,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: widget.coach.status == 'active'
                        ? AppColors.success
                        : AppColors.error,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                  ),
                  child: Text(
                    widget.coach.status.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Contact Information',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingM),
        NeumorphicContainer(
          padding: const EdgeInsets.all(AppDimensions.paddingM),
          child: Column(
            children: [
              if (widget.coach.email.isNotEmpty)
                _buildInfoRow(
                  Icons.email_outlined, 
                  'Email', 
                  widget.coach.email,
                  onTap: () => ContactUtils.launchEmail(widget.coach.email),
                ),
              if (widget.coach.email.isNotEmpty && widget.coach.phone.isNotEmpty)
                const Divider(color: AppColors.textSecondary, height: 24),
              if (widget.coach.phone.isNotEmpty)
                _buildInfoRow(
                  Icons.phone_outlined, 
                  'Phone', 
                  widget.coach.phone,
                  onTap: () => ContactUtils.showContactOptions(context, widget.coach.phone, name: widget.coach.name),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfessionalInfo() {
    if (widget.coach.specialization == null && widget.coach.experienceYears == null) {
      return const SizedBox.shrink();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Professional Information',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingM),
        NeumorphicContainer(
          padding: const EdgeInsets.all(AppDimensions.paddingM),
          child: Column(
            children: [
              if (widget.coach.specialization != null && widget.coach.specialization!.isNotEmpty)
                _buildInfoRow(Icons.sports_tennis_outlined, 'Specialization', widget.coach.specialization!),
              if (widget.coach.specialization != null && widget.coach.experienceYears != null)
                const Divider(color: AppColors.textSecondary, height: 24),
              if (widget.coach.experienceYears != null)
                _buildInfoRow(Icons.calendar_today_outlined, 'Experience', '${widget.coach.experienceYears} years'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _toggleStatus(),
            icon: Icon(
              widget.coach.status == 'active' ? Icons.person_off : Icons.person,
              size: 18,
            ),
            label: Text(widget.coach.status == 'active' ? 'Mark Inactive' : 'Mark Active'),
            style: OutlinedButton.styleFrom(
              foregroundColor: widget.coach.status == 'active' 
                  ? AppColors.error 
                  : AppColors.success,
              padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingM),
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.spacingS),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _deleteCoach(),
            icon: const Icon(Icons.delete, size: 18),
            label: const Text('Delete Coach'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingM),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: AppDimensions.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
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
                            fontSize: 14,
                            color: AppColors.accent,
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.accent.withOpacity(0.5),
                          ),
                        ),
                      ),
                    )
                  : Text(
                      value,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
              ],
            ),
          ),
          if (onTap != null)
            const Icon(Icons.open_in_new, size: 14, color: AppColors.textTertiary),
        ],
      ),
    );
  }

  void _toggleStatus() async {
    try {
      final newStatus = widget.coach.status == 'active' ? 'inactive' : 'active';
      await ref.read(coachListProvider.notifier).updateCoach(widget.coach.id, {'status': newStatus});
      if (mounted) {
        SuccessSnackbar.show(context, 'Coach ${newStatus == 'active' ? 'activated' : 'deactivated'} successfully');
        widget.onCoachUpdated?.call();
      }
    } catch (e) {
      if (mounted) {
        SuccessSnackbar.showError(context, 'Failed to update coach status: ${e.toString()}');
      }
    }
  }

  void _deleteCoach() {
    ConfirmationDialog.showDelete(
      context,
      widget.coach.name,
      onConfirm: () async {
        try {
          await ref.read(coachListProvider.notifier).deleteCoach(widget.coach.id);
          if (mounted) {
            Navigator.of(context).pop(); // Close dialog
            // Also close the details dialog since the coach is deleted
            Navigator.of(context).pop(); 
            SuccessSnackbar.show(context, 'Coach deleted successfully');
          }
        } catch (e) {
          if (mounted) {
            SuccessSnackbar.showError(context, 'Failed to delete coach: ${e.toString()}');
          }
        }
      },
    );
  }
}
