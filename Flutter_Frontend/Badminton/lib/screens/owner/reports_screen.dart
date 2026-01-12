import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../core/theme/neumorphic_styles.dart';
import '../../widgets/common/neumorphic_container.dart';

/// Reports Screen - Generate and view reports
/// Matches React reference: ReportsScreen.tsx
class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  String? _selectedType; // 'attendance', 'fee', 'performance'
  DateTime? _startDate;
  DateTime? _endDate;

  final List<Map<String, dynamic>> _reportTypes = [
    {
      'id': 'attendance',
      'icon': Icons.people_outline,
      'title': 'Attendance Report',
      'description': 'Student attendance summary',
    },
    {
      'id': 'fee',
      'icon': Icons.attach_money_outlined,
      'title': 'Fee Report',
      'description': 'Fee collection & pending',
    },
    {
      'id': 'performance',
      'icon': Icons.trending_up,
      'title': 'Performance Report',
      'description': 'Student skill progress',
    },
  ];

  final List<Map<String, dynamic>> _generatedReports = [
    {
      'type': 'Attendance Report',
      'period': 'Dec 2025',
      'generatedOn': '2026-01-01',
    },
    {
      'type': 'Fee Report',
      'period': 'Dec 2025',
      'generatedOn': '2026-01-01',
    },
    {
      'type': 'Performance Report',
      'period': 'Q4 2025',
      'generatedOn': '2025-12-30',
    },
  ];

  @override
  Widget build(BuildContext context) {
    if (_selectedType != null) {
      return _buildReportConfig();
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              'Reports',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingL),

            // Report Type Selection
            Column(
              children: _reportTypes.map((type) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppDimensions.spacingM),
                  child: NeumorphicContainer(
                    padding: const EdgeInsets.all(AppDimensions.paddingL),
                    onTap: () {
                      setState(() {
                        _selectedType = type['id'];
                      });
                    },
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                            boxShadow: NeumorphicStyles.getInsetShadow(),
                          ),
                          child: Icon(
                            type['icon'],
                            color: AppColors.iconPrimary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.spacingM),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                type['title'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                type['description'],
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right,
                          color: AppColors.textTertiary,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: AppDimensions.spacingXl),

            // Previously Generated Reports
            const Text(
              'Previously Generated',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingM),
            ..._generatedReports.map((report) => Padding(
                  padding: const EdgeInsets.only(bottom: AppDimensions.spacingM),
                  child: NeumorphicContainer(
                    padding: const EdgeInsets.all(AppDimensions.paddingM),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              report['type'],
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              '${report['period']} • ${report['generatedOn']}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.download_outlined,
                            color: AppColors.iconPrimary,
                          ),
                          onPressed: () {
                            // Download report
                          },
                        ),
                      ],
                    ),
                  ),
                )),

            const SizedBox(height: 100), // Space for bottom nav
          ],
        ),
      ),
    );
  }

  Widget _buildReportConfig() {
    final reportType = _reportTypes.firstWhere((r) => r['id'] == _selectedType);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back Button
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedType = null;
                  _startDate = null;
                  _endDate = null;
                });
              },
              child: const Text(
                '← Back',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingM),

            // Header
            Text(
              reportType['title'],
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Configure and generate report',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingL),

            // Date Range
            NeumorphicContainer(
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select Date Range',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingM),
                  _DatePickerField(
                    label: 'Start Date',
                    date: _startDate,
                    onDateSelected: (date) {
                      setState(() {
                        _startDate = date;
                      });
                    },
                  ),
                  const SizedBox(height: AppDimensions.spacingM),
                  _DatePickerField(
                    label: 'End Date',
                    date: _endDate,
                    onDateSelected: (date) {
                      setState(() {
                        _endDate = date;
                      });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppDimensions.spacingM),

            // Filters (based on report type)
            if (_selectedType == 'attendance')
              NeumorphicContainer(
                padding: const EdgeInsets.all(AppDimensions.paddingM),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select Batch',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingS),
                    NeumorphicInsetContainer(
                      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingM),
                      child: DropdownButton<String>(
                        value: 'all',
                        isExpanded: true,
                        underline: const SizedBox(),
                        dropdownColor: AppColors.cardBackground,
                        style: const TextStyle(color: AppColors.textPrimary),
                        items: const [
                          DropdownMenuItem(value: 'all', child: Text('All Batches')),
                          DropdownMenuItem(value: '1', child: Text('Morning Batch A')),
                          DropdownMenuItem(value: '2', child: Text('Evening Batch B')),
                          DropdownMenuItem(value: '3', child: Text('Weekend Batch')),
                        ],
                        onChanged: (value) {},
                      ),
                    ),
                  ],
                ),
              ),

            if (_selectedType == 'fee')
              NeumorphicContainer(
                padding: const EdgeInsets.all(AppDimensions.paddingM),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Status Filter',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingS),
                    ...['All', 'Paid', 'Pending', 'Overdue'].map((status) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppDimensions.spacingS),
                        child: NeumorphicInsetContainer(
                          padding: const EdgeInsets.all(AppDimensions.spacingM),
                          child: Row(
                            children: [
                              Checkbox(
                                value: status == 'All',
                                onChanged: (value) {},
                                activeColor: AppColors.accent,
                              ),
                              Text(
                                status,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),

            const SizedBox(height: AppDimensions.spacingL),

            // Generate Button
            NeumorphicContainer(
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              onTap: () {
                // Generate report
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Report generated successfully'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.description_outlined,
                    color: AppColors.iconActive,
                    size: 20,
                  ),
                  const SizedBox(width: AppDimensions.spacingS),
                  const Text(
                    'Generate Report',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 100), // Space for bottom nav
          ],
        ),
      ),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final String label;
  final DateTime? date;
  final ValueChanged<DateTime> onDateSelected;

  const _DatePickerField({
    required this.label,
    required this.date,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return NeumorphicInsetContainer(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
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
          const SizedBox(height: AppDimensions.spacingS),
          GestureDetector(
            onTap: () async {
              final selectedDate = await showDatePicker(
                context: context,
                initialDate: date ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.dark(
                        primary: AppColors.accent,
                        surface: AppColors.cardBackground,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (selectedDate != null) {
                onDateSelected(selectedDate);
              }
            },
            child: Text(
              date != null
                  ? '${date!.day}/${date!.month}/${date!.year}'
                  : 'Select date',
              style: TextStyle(
                color: date != null ? AppColors.textPrimary : AppColors.textHint,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
