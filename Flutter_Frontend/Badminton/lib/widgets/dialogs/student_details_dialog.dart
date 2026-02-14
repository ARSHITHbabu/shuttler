import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../widgets/common/neumorphic_container.dart';
import '../../models/student.dart';
import 'tabs/student_profile_tab.dart';
import 'tabs/student_performance_tab.dart';
import 'tabs/student_bmi_tab.dart';
import 'tabs/student_fees_tab.dart';

/// Student Details Dialog - Comprehensive dialog with tabs for managing individual student
class StudentDetailsDialog extends ConsumerStatefulWidget {
  final Student student;

  const StudentDetailsDialog({
    super.key,
    required this.student,
  });

  /// Show the dialog
  static Future<void> show(BuildContext context, Student student) async {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => StudentDetailsDialog(student: student),
    );
  }

  @override
  ConsumerState<StudentDetailsDialog> createState() => _StudentDetailsDialogState();
}

class _StudentDetailsDialogState extends ConsumerState<StudentDetailsDialog> {
  String _selectedTab = 'profile';

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
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.textSecondary.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.student.name,
                  style: const TextStyle(
                    fontSize: 20,
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
                    color: widget.student.status == 'active'
                        ? AppColors.success
                        : AppColors.error,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                  ),
                  child: Text(
                    widget.student.status.toUpperCase(),
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
                label: 'Performance',
                icon: Icons.trending_up,
                isActive: _selectedTab == 'performance',
                onTap: () => setState(() => _selectedTab = 'performance'),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: _TabButton(
                label: 'BMI',
                icon: Icons.monitor_weight,
                isActive: _selectedTab == 'bmi',
                onTap: () => setState(() => _selectedTab = 'bmi'),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: _TabButton(
                label: 'Fees',
                icon: Icons.attach_money,
                isActive: _selectedTab == 'fees',
                onTap: () => setState(() => _selectedTab = 'fees'),
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
        return StudentProfileTab(
          student: widget.student,
          onStudentUpdated: () {
            // Refresh student data if needed
            setState(() {});
          },
        );
      case 'performance':
        return StudentPerformanceTab(student: widget.student);
      case 'bmi':
        return StudentBMITab(student: widget.student);
      case 'fees':
        return StudentFeesTab(student: widget.student);
      default:
        return StudentProfileTab(
          student: widget.student,
          onStudentUpdated: () => setState(() {}),
        );
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isVerySmall = screenWidth < 400;
    
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: AppDimensions.spacingS,
          horizontal: isVerySmall ? 4 : AppDimensions.spacingXs,
        ),
        decoration: BoxDecoration(
          color: isActive ? AppColors.accent.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: isVerySmall ? 18 : 16,
              color: isActive ? AppColors.accent : AppColors.textSecondary,
            ),
            if (!isVerySmall) ...[
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isActive ? AppColors.accent : AppColors.textSecondary,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
