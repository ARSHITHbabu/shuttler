import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../widgets/common/neumorphic_container.dart';
import '../../models/student.dart';
import '../../providers/student_provider.dart';
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

    // Watch student for reactivity
    final studentAsync = ref.watch(studentByIdProvider(widget.student.id));
    
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
        child: studentAsync.when(
          data: (student) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              _buildHeader(student),
              
              // Tab Selector
              _buildTabSelector(),
              
              // Tab Content
              Expanded(
                child: _buildTabContent(student),
              ),
            ],
          ),
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(AppDimensions.paddingL),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: AppColors.error, size: 48),
                  const SizedBox(height: AppDimensions.spacingM),
                  Text(
                    'Error: ${error.toString()}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                  TextButton(
                    onPressed: () => ref.invalidate(studentByIdProvider(widget.student.id)),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Student student) {
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

  Widget _buildTabContent(Student student) {
    switch (_selectedTab) {
      case 'profile':
        return StudentProfileTab(
          student: student,
          onStudentUpdated: () {
            // No need to call setState, provider watch handles it
          },
        );
      case 'performance':
        return StudentPerformanceTab(student: student);
      case 'bmi':
        return StudentBMITab(student: student);
      case 'fees':
        return StudentFeesTab(student: student);
      default:
        return StudentProfileTab(
          student: student,
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
