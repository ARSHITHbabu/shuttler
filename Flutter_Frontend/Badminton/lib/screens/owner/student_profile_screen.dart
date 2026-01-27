import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../widgets/common/neumorphic_container.dart';
import '../../providers/service_providers.dart';
import '../../models/student.dart';
import '../../models/fee.dart';
import 'performance_tracking_screen.dart';
import 'bmi_tracking_screen.dart';
import 'package:intl/intl.dart';

/// Detailed Student Profile Screen
class StudentProfileScreen extends ConsumerStatefulWidget {
  final Student student;

  const StudentProfileScreen({
    super.key,
    required this.student,
  });

  @override
  ConsumerState<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends ConsumerState<StudentProfileScreen> {
  String _selectedTab = 'details'; // 'details', 'fees', 'performance', 'bmi'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.student.name,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          // Tab Selector
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            child: NeumorphicContainer(
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  Expanded(
                    child: _TabButton(
                      label: 'Details',
                      isActive: _selectedTab == 'details',
                      onTap: () => setState(() => _selectedTab = 'details'),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: _TabButton(
                      label: 'Fees',
                      isActive: _selectedTab == 'fees',
                      onTap: () => setState(() => _selectedTab = 'fees'),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: _TabButton(
                      label: 'Performance',
                      isActive: _selectedTab == 'performance',
                      onTap: () => setState(() => _selectedTab = 'performance'),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: _TabButton(
                      label: 'BMI',
                      isActive: _selectedTab == 'bmi',
                      onTap: () => setState(() => _selectedTab = 'bmi'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          Expanded(
            child: _buildTabContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 'details':
        return _buildDetailsTab();
      case 'fees':
        return _buildFeesTab();
      case 'performance':
        return _buildPerformanceTab();
      case 'bmi':
        return _buildBMITab();
      default:
        return _buildDetailsTab();
    }
  }

  Widget _buildDetailsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Header
          NeumorphicContainer(
            padding: const EdgeInsets.all(AppDimensions.paddingL),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      widget.student.name[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingM),
                Text(
                  widget.student.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingS),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacingM,
                    vertical: AppDimensions.spacingS,
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
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppDimensions.spacingL),

          // Contact Information
          const Text(
            'Contact Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingM),
          NeumorphicContainer(
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            child: Column(
              children: [
                if (widget.student.email.isNotEmpty)
                  _buildInfoRow(Icons.email_outlined, 'Email', widget.student.email),
                if (widget.student.phone.isNotEmpty) ...[
                  if (widget.student.email.isNotEmpty)
                    const Divider(color: AppColors.textSecondary, height: 24),
                  _buildInfoRow(Icons.phone_outlined, 'Phone', widget.student.phone),
                ],
              ],
            ),
          ),

          if (widget.student.guardianName != null || widget.student.guardianPhone != null) ...[
            const SizedBox(height: AppDimensions.spacingL),
            const Text(
              'Guardian Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingM),
            NeumorphicContainer(
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              child: Column(
                children: [
                  if (widget.student.guardianName != null)
                    _buildInfoRow(
                      Icons.person_outline,
                      'Guardian Name',
                      widget.student.guardianName!,
                    ),
                  if (widget.student.guardianPhone != null) ...[
                    if (widget.student.guardianName != null)
                      const Divider(color: AppColors.textSecondary, height: 24),
                    _buildInfoRow(
                      Icons.phone_outlined,
                      'Guardian Phone',
                      widget.student.guardianPhone!,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFeesTab() {
    return FutureBuilder<List<Fee>>(
      future: ref.read(feeServiceProvider).getFees(studentId: widget.student.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Failed to load fees',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          );
        }

        final fees = snapshot.data ?? [];

        if (fees.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.attach_money_outlined,
                  size: 64,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: AppDimensions.spacingM),
                const Text(
                  'No fee records found',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          itemCount: fees.length,
          itemBuilder: (context, index) {
            final fee = fees[index];
            return NeumorphicContainer(
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              margin: const EdgeInsets.only(bottom: AppDimensions.spacingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${fee.amount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.spacingM,
                          vertical: AppDimensions.spacingS,
                        ),
                        decoration: BoxDecoration(
                          color: fee.status == 'paid'
                              ? AppColors.success
                              : fee.status == 'overdue'
                                  ? AppColors.error
                                  : AppColors.warning,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                        ),
                        child: Text(
                          fee.status.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.spacingM),
                  _buildInfoRow(Icons.calendar_today, 'Due Date', DateFormat('dd MMM, yyyy').format(fee.dueDate)),
                  if (fee.payments != null && fee.payments!.isNotEmpty) ...[
                    const SizedBox(height: AppDimensions.spacingS),
                    _buildInfoRow(
                      Icons.check_circle,
                      'Paid Date',
                      DateFormat('dd MMM, yyyy').format(
                        fee.payments!.map((p) => p.paidDate).reduce((a, b) => a.isAfter(b) ? a : b),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPerformanceTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.trending_up,
            size: 64,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: AppDimensions.spacingM),
          const Text(
            'Performance tracking',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingL),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const PerformanceTrackingScreen(),
                ),
              );
            },
            icon: const Icon(Icons.open_in_new),
            label: const Text('View Performance'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBMITab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.monitor_weight,
            size: 64,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: AppDimensions.spacingM),
          const Text(
            'BMI tracking',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingL),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const BMITrackingScreen(),
                ),
              );
            },
            icon: const Icon(Icons.open_in_new),
            label: const Text('View BMI Records'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
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
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingS),
        decoration: BoxDecoration(
          color: isActive ? AppColors.accent.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isActive ? AppColors.accent : AppColors.textSecondary,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}
