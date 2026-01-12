import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../core/theme/neumorphic_styles.dart';
import '../../widgets/common/neumorphic_container.dart';
import '../../widgets/common/loading_spinner.dart';
import '../../providers/service_providers.dart';
import '../../core/services/attendance_service.dart';
import '../../core/services/fee_service.dart';
import '../../models/attendance.dart';
import '../../models/fee.dart';

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
  int? _selectedBatchId;
  int? _selectedStudentId;
  String? _selectedStatus;
  bool _isGenerating = false;
  Map<String, dynamic>? _generatedReport;

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

  Future<void> _generateReport() async {
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select start and end dates'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
      _generatedReport = null;
    });

    try {
      if (_selectedType == 'attendance') {
        final attendanceService = ref.read(attendanceServiceProvider);
        final attendance = await attendanceService.getAttendance(
          startDate: _startDate!,
          endDate: _endDate!,
          batchId: _selectedBatchId,
        );

        final totalDays = _endDate!.difference(_startDate!).inDays + 1;
        final presentCount = attendance.where((a) => a.status == 'present').length;
        final absentCount = attendance.where((a) => a.status == 'absent').length;
        final attendanceRate = attendance.isEmpty
            ? 0.0
            : (presentCount / attendance.length) * 100;

        setState(() {
          _generatedReport = {
            'type': 'Attendance Report',
            'period': '${_startDate!.day}/${_startDate!.month}/${_startDate!.year} - ${_endDate!.day}/${_endDate!.month}/${_endDate!.year}',
            'generatedOn': DateTime.now().toIso8601String().split('T')[0],
            'data': {
              'totalDays': totalDays,
              'totalRecords': attendance.length,
              'presentCount': presentCount,
              'absentCount': absentCount,
              'attendanceRate': attendanceRate,
              'attendance': attendance,
            },
          };
        });
      } else if (_selectedType == 'fee') {
        final feeService = ref.read(feeServiceProvider);
        final fees = await feeService.getFees(
          startDate: _startDate!,
          endDate: _endDate!,
          status: _selectedStatus,
          studentId: _selectedStudentId,
        );

        double totalAmount = 0.0;
        double paidAmount = 0.0;
        double pendingAmount = 0.0;
        
        for (final fee in fees) {
          totalAmount += fee.amount;
          if (fee.status == 'paid') {
            paidAmount += fee.amount;
          } else if (fee.status == 'pending') {
            pendingAmount += fee.amount;
          }
        }

        setState(() {
          _generatedReport = {
            'type': 'Fee Report',
            'period': '${_startDate!.day}/${_startDate!.month}/${_startDate!.year} - ${_endDate!.day}/${_endDate!.month}/${_endDate!.year}',
            'generatedOn': DateTime.now().toIso8601String().split('T')[0],
            'data': {
              'totalFees': fees.length,
              'totalAmount': totalAmount,
              'paidAmount': paidAmount,
              'pendingAmount': pendingAmount,
              'fees': fees,
            },
          };
        });
      } else if (_selectedType == 'performance') {
        // Performance reports would need a performance service
        // For now, show a placeholder
        setState(() {
          _generatedReport = {
            'type': 'Performance Report',
            'period': '${_startDate!.day}/${_startDate!.month}/${_startDate!.year} - ${_endDate!.day}/${_endDate!.month}/${_endDate!.year}',
            'generatedOn': DateTime.now().toIso8601String().split('T')[0],
            'data': {
              'message': 'Performance report generation coming soon',
            },
          };
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Report generated successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating report: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }

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

            // Previously Generated Reports (if any)
            if (_generatedReport != null) ...[
              const SizedBox(height: AppDimensions.spacingXl),
              const Text(
                'Generated Report',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppDimensions.spacingM),
            ],

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
              onTap: _isGenerating ? null : _generateReport,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isGenerating)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    const Icon(
                      Icons.description_outlined,
                      color: AppColors.iconActive,
                      size: 20,
                    ),
                  const SizedBox(width: AppDimensions.spacingS),
                  Text(
                    _isGenerating ? 'Generating...' : 'Generate Report',
                    style: TextStyle(
                      fontSize: 16,
                      color: _isGenerating
                          ? AppColors.textSecondary
                          : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            // Generated Report Display
            if (_generatedReport != null) ...[
              const SizedBox(height: AppDimensions.spacingL),
              NeumorphicContainer(
                padding: const EdgeInsets.all(AppDimensions.paddingL),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _generatedReport!['type'] as String,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.download_outlined,
                            color: AppColors.iconPrimary,
                          ),
                          onPressed: () {
                            // TODO: Implement export functionality
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Export functionality coming soon'),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.spacingM),
                    Text(
                      'Period: ${_generatedReport!['period']}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingM),
                    _buildReportSummary(_generatedReport!['data'] as Map<String, dynamic>),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 100), // Space for bottom nav
          ],
        ),
      ),
    );
  }

  Widget _buildReportSummary(Map<String, dynamic> data) {
    if (_selectedType == 'attendance') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SummaryRow(
            label: 'Total Days',
            value: data['totalDays'].toString(),
          ),
          _SummaryRow(
            label: 'Total Records',
            value: data['totalRecords'].toString(),
          ),
          _SummaryRow(
            label: 'Present',
            value: data['presentCount'].toString(),
            color: AppColors.success,
          ),
          _SummaryRow(
            label: 'Absent',
            value: data['absentCount'].toString(),
            color: AppColors.error,
          ),
          _SummaryRow(
            label: 'Attendance Rate',
            value: '${(data['attendanceRate'] as double).toStringAsFixed(1)}%',
            color: AppColors.iconPrimary,
          ),
        ],
      );
    } else if (_selectedType == 'fee') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SummaryRow(
            label: 'Total Fees',
            value: data['totalFees'].toString(),
          ),
          _SummaryRow(
            label: 'Total Amount',
            value: '₹${_formatCurrency(data['totalAmount'] as double)}',
          ),
          _SummaryRow(
            label: 'Paid Amount',
            value: '₹${_formatCurrency(data['paidAmount'] as double)}',
            color: AppColors.success,
          ),
          _SummaryRow(
            label: 'Pending Amount',
            value: '₹${_formatCurrency(data['pendingAmount'] as double)}',
            color: AppColors.error,
          ),
        ],
      );
    } else {
      return Text(
        data['message'] ?? 'No data available',
        style: const TextStyle(
          color: AppColors.textSecondary,
        ),
      );
    }
  }

  String _formatCurrency(double amount) {
    if (amount >= 100000) {
      return '${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return amount.toStringAsFixed(0);
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

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacingS),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
