import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../core/theme/neumorphic_styles.dart';
import '../../core/utils/theme_colors.dart';
import '../../widgets/common/standard_page_header.dart';
import '../../widgets/common/neumorphic_container.dart';
import 'tabs/coach_salary_tab.dart';
import 'tabs/student_fees_view.dart';

class FeesScreen extends ConsumerStatefulWidget {
  final int? selectedStudentId;
  final String? selectedStudentName;

  const FeesScreen({
    super.key,
    this.selectedStudentId,
    this.selectedStudentName,
  });

  @override
  ConsumerState<FeesScreen> createState() => _FeesScreenState();
}

class _FeesScreenState extends ConsumerState<FeesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.canPop(context);
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Standardized Header
        StandardPageHeader(
          title: 'Fees Management',
          showBackButton: canPop,
        ),
        const SizedBox(height: AppDimensions.spacingS),

        // Custom Neumorphic Tab Bar
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppDimensions.getScreenPadding(context)),
          child: NeumorphicContainer(
            padding: const EdgeInsets.all(4),
            child: Row(
              children: [
                Expanded(
                  child: _TabButton(
                    label: 'Student Fees',
                    icon: Icons.people_outline,
                    isActive: _tabController.index == 0,
                    onTap: () => setState(() => _tabController.animateTo(0)),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: _TabButton(
                    label: 'Coach Salaries',
                    icon: Icons.payments_outlined,
                    isActive: _tabController.index == 1,
                    onTap: () => setState(() => _tabController.animateTo(1)),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Tab Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            physics: const NeverScrollableScrollPhysics(), // Disable swipe to keep custom buttons in sync
            children: [
              StudentFeesView(
                selectedStudentId: widget.selectedStudentId,
                selectedStudentName: widget.selectedStudentName,
              ),
              const CoachSalaryTab(),
            ],
          ),
        ),
      ],
    );

    if (!canPop) {
      return content;
    }

    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: context.backgroundGradient,
        ),
        child: SafeArea(child: content),
      ),
    );
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingM),
        decoration: BoxDecoration(
          color: isActive ? AppColors.cardBackground : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          boxShadow: isActive ? NeumorphicStyles.getPressedShadow() : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 20,
              color: isActive ? AppColors.iconActive : AppColors.textTertiary,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isActive ? AppColors.iconActive : AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
