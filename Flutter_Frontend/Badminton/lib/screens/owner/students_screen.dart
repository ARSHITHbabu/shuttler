import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../widgets/common/neumorphic_container.dart';
import '../../widgets/common/loading_spinner.dart';
import '../../widgets/common/error_widget.dart';
import '../../providers/service_providers.dart';
import '../../models/student.dart';
import '../../widgets/forms/add_student_dialog.dart';

/// Students List Screen - Shows all students with add button
class StudentsScreen extends ConsumerStatefulWidget {
  const StudentsScreen({super.key});

  @override
  ConsumerState<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends ConsumerState<StudentsScreen> {
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
        title: const Text(
          'Students',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.accent),
            onPressed: () => _showAddStudentDialog(context),
          ),
        ],
      ),
      body: FutureBuilder<List<Student>>(
        future: ref.read(studentServiceProvider).getStudents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: LoadingSpinner());
          }

          if (snapshot.hasError) {
            return ErrorDisplay(
              message: 'Failed to load students',
              onRetry: () => setState(() {}),
            );
          }

          final students = snapshot.data ?? [];

          if (students.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.people_outline,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: AppDimensions.spacingM),
                  const Text(
                    'No students added yet',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingL),
                  ElevatedButton.icon(
                    onPressed: () => _showAddStudentDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Student'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {});
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              itemCount: students.length,
              itemBuilder: (context, index) {
                final student = students[index];
                return NeumorphicContainer(
                  padding: const EdgeInsets.all(AppDimensions.paddingM),
                  margin: const EdgeInsets.only(bottom: AppDimensions.spacingM),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              student.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.spacingM,
                              vertical: AppDimensions.spacingS,
                            ),
                            decoration: BoxDecoration(
                              color: student.status == 'active'
                                  ? AppColors.success
                                  : AppColors.error,
                              borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                            ),
                            child: Text(
                              student.status.toUpperCase(),
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
                      if (student.email.isNotEmpty)
                        _InfoRow(
                          icon: Icons.email_outlined,
                          label: 'Email',
                          value: student.email,
                        ),
                      if (student.phone.isNotEmpty) ...[
                        const SizedBox(height: AppDimensions.spacingS),
                        _InfoRow(
                          icon: Icons.phone_outlined,
                          label: 'Phone',
                          value: student.phone,
                        ),
                      ],
                      if (student.guardianName != null && student.guardianName!.isNotEmpty) ...[
                        const SizedBox(height: AppDimensions.spacingS),
                        _InfoRow(
                          icon: Icons.person_outline,
                          label: 'Guardian',
                          value: student.guardianName!,
                        ),
                      ],
                      if (student.guardianPhone != null && student.guardianPhone!.isNotEmpty) ...[
                        const SizedBox(height: AppDimensions.spacingS),
                        _InfoRow(
                          icon: Icons.phone_outlined,
                          label: 'Guardian Phone',
                          value: student.guardianPhone!,
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _showAddStudentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddStudentDialog(
        onSubmit: (studentData) async {
          final studentService = ref.read(studentServiceProvider);
          await studentService.createStudent(studentData);
          if (mounted) {
            setState(() {});
          }
        },
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: AppDimensions.spacingS),
        Text(
          '$label: ',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
