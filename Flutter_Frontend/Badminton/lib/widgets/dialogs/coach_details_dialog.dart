import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../widgets/common/neumorphic_container.dart';
import '../../models/coach.dart';
import 'tabs/coach_profile_tab.dart';
import 'tabs/coach_batches_tab.dart';

/// Coach Details Dialog - Comprehensive dialog with tabs for managing individual coach
class CoachDetailsDialog extends ConsumerStatefulWidget {
  final Coach coach;

  const CoachDetailsDialog({
    super.key,
    required this.coach,
  });

  /// Show the dialog
  static Future<void> show(BuildContext context, Coach coach) async {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => CoachDetailsDialog(coach: coach),
    );
  }

  @override
  ConsumerState<CoachDetailsDialog> createState() => _CoachDetailsDialogState();
}

class _CoachDetailsDialogState extends ConsumerState<CoachDetailsDialog> {
  String _selectedTab = 'profile'; // 'profile', 'batches'

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingM,
        vertical: AppDimensions.paddingL,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: screenHeight * 0.85,
          maxWidth: screenWidth > 800 ? 700 : screenWidth * 0.95,
        ),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            _buildHeader(),
            
            // Tab Selector
            _buildTabSelector(),
            
            // Tab Content
            Expanded(
              child: _buildTabContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(AppDimensions.paddingL, AppDimensions.paddingL / 1.5, AppDimensions.paddingL / 2, AppDimensions.paddingL / 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.textSecondary),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      margin: const EdgeInsets.all(AppDimensions.paddingM),
      child: NeumorphicContainer(
        padding: EdgeInsets.zero,
        child: Row(
          children: [
            Expanded(
              child: _TabButton(
                label: 'Profile',
                icon: Icons.person,
                isActive: _selectedTab == 'profile',
                onTap: () => setState(() => _selectedTab = 'profile'),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: _TabButton(
                label: 'Batches',
                icon: Icons.group,
                isActive: _selectedTab == 'batches',
                onTap: () => setState(() => _selectedTab = 'batches'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 'profile':
        return CoachProfileTab(
          coach: widget.coach,
          onCoachUpdated: () {
            // Refresh dialog state if needed, mostly handled by parent providers
            setState(() {});
          },
        );
      case 'batches':
        return CoachBatchesTab(coach: widget.coach);
      default:
        return CoachProfileTab(coach: widget.coach);
    }
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusS),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppDimensions.spacingM,
        ),
        decoration: BoxDecoration(
          color: isActive ? AppColors.accent.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        ),
        child: Icon(
          icon,
          size: 24,
          color: isActive ? AppColors.accent : AppColors.textSecondary,
        ),
      ),
    );
  }
}
