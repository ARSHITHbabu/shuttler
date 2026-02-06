import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../widgets/common/neumorphic_container.dart';
import '../../widgets/common/success_snackbar.dart';
import '../../providers/service_providers.dart';
import '../../models/session.dart';
import '../../models/batch.dart';

// Placeholder for web download helper
import '../../utils/file_download_helper_stub.dart'
    if (dart.library.html) '../../utils/file_download_helper_web.dart';

enum ReportType { attendance, fee, performance }
enum FilterType { season, year, month }

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  ReportType _reportType = ReportType.attendance;
  FilterType _filterType = FilterType.season;
  
  // Selections
  String? _selectedSeasonId; // Session ID
  int _selectedYear = DateTime.now().year;
  DateTime _selectedMonth = DateTime.now();
  String _selectedBatchId = 'all';

  // Data
  List<dynamic> _seasons = []; // Use dynamic or Session model
  List<dynamic> _allBatches = [];
  List<dynamic> _filteredBatches = [];
  
  Map<String, dynamic>? _reportData;
  bool _isLoading = false;
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      final sessionService = ref.read(sessionServiceProvider);
      final batchService = ref.read(batchServiceProvider);
      
      // Fetch seasons and batches
      final seasons = await sessionService.getSessions();
      final batches = await batchService.getBatches();
      
      if (mounted) {
        setState(() {
          _seasons = seasons;
          _allBatches = batches;
          // Set default season if available
          if (_seasons.isNotEmpty) {
             // Find active season or first
             _selectedSeasonId = _seasons.last.id.toString(); 
          }
          _filterBatches();
          _isInitializing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        SuccessSnackbar.showError(context, 'Error loading data: $e');
        setState(() => _isInitializing = false);
      }
    }
  }

  void _filterBatches() {
    // Filter batches based on current selection
    // In strict mode, we should filter by season only when Season is selected
    if (_filterType == FilterType.season && _selectedSeasonId != null) {
      _filteredBatches = _allBatches.where((b) {
         try {
           return b.sessionId.toString() == _selectedSeasonId;
         } catch (e) {
           return false;
         }
      }).toList();
    } else {
      _filteredBatches = List.from(_allBatches);
    }
    
    // Reset batch selection if invalid
    if (_selectedBatchId != 'all') {
      bool exists = _filteredBatches.any((b) => b.id.toString() == _selectedBatchId);
      if (!exists) {
        _selectedBatchId = 'all';
      }
    }
  }

  Future<void> _generateReport() async {
    setState(() {
      _isLoading = true;
      _reportData = null;
    });

    try {
      final reportService = ref.read(reportServiceProvider);
      
      String filterValue = "";
      if (_filterType == FilterType.season) {
        if (_selectedSeasonId == null) throw Exception("Please select a season");
        filterValue = _selectedSeasonId!;
      } else if (_filterType == FilterType.year) {
        filterValue = _selectedYear.toString();
      } else {
        filterValue = DateFormat('yyyy-MM').format(_selectedMonth);
      }

      final data = await reportService.generateReport(
        type: _reportType.name,
        filterType: _filterType.name,
        filterValue: filterValue,
        batchId: _selectedBatchId,
      );

      setState(() {
        _reportData = data;
      });
    } catch (e) {
      SuccessSnackbar.showError(context, 'Failed to generate report: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Reports', style: TextStyle(color: AppColors.textPrimary)),
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: const BackButton(color: AppColors.textPrimary),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildReportTypeSelector(),
              const SizedBox(height: AppDimensions.spacingL),
              _buildFilters(),
              const SizedBox(height: AppDimensions.spacingL),
              _buildGenerateButton(),
              const SizedBox(height: AppDimensions.spacingL),
              if (_reportData != null) _buildReportPreview(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportTypeSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: ReportType.values.map((type) {
           bool isSelected = _reportType == type;
           return Padding(
             padding: const EdgeInsets.only(right: 8.0),
             child: ChoiceChip(
               label: Text(type.name.toUpperCase()),
               selected: isSelected,
               onSelected: (val) {
                 if (val) setState(() => _reportType = type);
               },
               selectedColor: AppColors.accent,
               labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.textPrimary),
             ),
           );
        }).toList(),
      ),
    );
  }

  Widget _buildFilters() {
    return NeumorphicContainer(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Type Toggle
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: FilterType.values.map((type) {
                bool isSelected = _filterType == type;
                return Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _filterType = type;
                        _filterBatches(); // Re-filter batches logic
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.accent : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        type.name.substring(0, 1).toUpperCase() + type.name.substring(1),
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingM),
          
          if (_filterType == FilterType.season)
             _buildSeasonDropdown(),
          if (_filterType == FilterType.year)
             _buildYearSelector(),
          if (_filterType == FilterType.month)
             _buildMonthSelector(),
             
          const SizedBox(height: AppDimensions.spacingM),
          
          Text("Batch", style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedBatchId,
                isExpanded: true,
                items: [
                  const DropdownMenuItem(value: "all", child: Text("All Batches")),
                  ..._filteredBatches.map((b) => DropdownMenuItem(
                    value: b.id.toString(),
                    child: Text(b.batchName ?? "Batch ${b.id}"), // Adapt to model
                  )),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _selectedBatchId = val);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeasonDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Select Season", style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedSeasonId,
              isExpanded: true,
              hint: const Text("Choose Season"),
              items: _seasons.map<DropdownMenuItem<String>>((s) { 
                return DropdownMenuItem(
                  value: s.id.toString(),
                  child: Text(s.name ?? "Season ${s.id}"),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedSeasonId = val;
                    _filterBatches();
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildYearSelector() {
    int current = DateTime.now().year;
    List<int> years = List.generate(10, (i) => current - 5 + i);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Select Year", style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        const SizedBox(height: 4),
        Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _selectedYear,
                isExpanded: true,
                items: years.map((y) => DropdownMenuItem(value: y, child: Text(y.toString()))).toList(),
                onChanged: (val) => setState(() => _selectedYear = val!),
              ),
            ),
        ),
      ],
    );
  }
  
  Widget _buildMonthSelector() {
     return InkWell(
        onTap: () async {
          final d = await showDatePicker(
            context: context,
            initialDate: _selectedMonth,
            firstDate: DateTime(2020),
            lastDate: DateTime(2030),
            initialDatePickerMode: DatePickerMode.year,
          );
          if (d != null) {
            setState(() => _selectedMonth = d);
          }
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(DateFormat('MMMM yyyy').format(_selectedMonth)),
              const Icon(Icons.calendar_today, size: 16),
            ],
          ),
        ),
     );
  }

  Widget _buildGenerateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: _isLoading ? null : _generateReport,
        child: _isLoading 
          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
          : const Text("Generate Report", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildReportPreview() {
    final overview = _reportData!['overview'];
    final breakdown = _reportData!['breakdown'] as List;
    final details = _reportData!['student_details'] as List?;
    final filterSummary = _reportData!['filter_summary'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Report Preview", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            IconButton(
              icon: const Icon(Icons.picture_as_pdf, color: Colors.red),
              onPressed: _exportPDF,
              tooltip: "Download PDF",
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(filterSummary ?? "", style: const TextStyle(fontWeight: FontWeight.w500)),
        const Divider(),
        
        NeumorphicContainer(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Overview", style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              if (_reportType == ReportType.attendance) ...[
                 _statRow("Total Students", "${overview['total_students']}"),
                 _statRow("Classes Conducted", "${overview['total_conducted']}"),
                 _statRow("Present", "${overview['present_count']}", color: Colors.green),
                 _statRow("Absent", "${overview['absent_count']}", color: Colors.red),
                 _statRow("Attendance Rate", "${overview['attendance_rate']}%", isBold: true),
              ] else if (_reportType == ReportType.fee) ...[
                 _statRow("Total Students", "${overview['total_students']}"),
                 _statRow("Expected Revenue", "₹${overview['total_expected']}"),
                 _statRow("Collected", "₹${overview['total_collected']}", color: Colors.green),
                 _statRow("Pending", "₹${overview['pending_amount']}", color: Colors.orange),
                 _statRow("Overdue Amount", "₹${overview['overdue_amount']}", color: Colors.red),
              ]
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        if (details != null && details.isNotEmpty) ...[
          const Text("Student Details", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: _reportType == ReportType.attendance 
                  ? const [DataColumn(label: Text("Name")), DataColumn(label: Text("Attended")), DataColumn(label: Text("%"))]
                  : const [DataColumn(label: Text("Name")), DataColumn(label: Text("Paid")), DataColumn(label: Text("Status"))],
              rows: details.map<DataRow>((s) {
                if (_reportType == ReportType.attendance) {
                   return DataRow(cells: [
                     DataCell(Text(s['name'])),
                     DataCell(Text("${s['classes_attended']}/${s['classes_assigned']}")),
                     DataCell(Text("${s['attendance_percentage']}%")),
                   ]);
                } else {
                   return DataRow(cells: [
                     DataCell(Text(s['name'])),
                     DataCell(Text("₹${s['amount_paid']}")),
                     DataCell(Text(s['payment_status'], style: TextStyle(
                       color: s['payment_status'] == 'Paid' ? Colors.green : Colors.red
                     ))),
                   ]);
                }
              }).toList(),
            ),
          )
        ] else ...[
          const Text("Breakdown", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: breakdown.length,
            itemBuilder: (ctx, i) {
               final item = breakdown[i];
               return Card(
                 child: ListTile(
                   title: Text(item['name']),
                   subtitle: Text(_reportType == ReportType.attendance 
                       ? "Att: ${item['attendance_rate']}%" 
                       : "Collected: ₹${item['collected']}"),
                   trailing: Text(_reportType == ReportType.attendance 
                       ? "${item['total_students']} Students" 
                       : "Pending: ${item['pending_count']}"),
                 ),
               );
            },
          ),
        ]
      ],
    );
  }

  Widget _statRow(String label, String value, {Color? color, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: TextStyle(
            color: color ?? AppColors.textPrimary,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          )),
        ],
      ),
    );
  }

  pw.Widget _buildPdfHeader(pw.Context context, String academyName, String address, String ownerName) {
      return pw.Column(
         crossAxisAlignment: pw.CrossAxisAlignment.start,
         children: [
            pw.Text(academyName, style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
            pw.Text(address, style: const pw.TextStyle(fontSize: 10)),
            pw.Text(ownerName, style: const pw.TextStyle(fontSize: 10)),
            pw.SizedBox(height: 10),
            pw.Row(
               mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
               children: [
                 pw.Column(
                   crossAxisAlignment: pw.CrossAxisAlignment.start,
                   children: [
                     pw.Text("Report Type: ${_reportType.name.toUpperCase()}", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                     pw.Text("Generated By: Owner/Coach (Admin)"), // TODO: Get actual user name
                   ]
                 ),
                 pw.Column(
                   crossAxisAlignment: pw.CrossAxisAlignment.end,
                   children: [
                     pw.Text("Generated On: ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now())}"),
                   ]
                 ),
               ]
            ),
            pw.SizedBox(height: 10),
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                 border: pw.Border.all(color: PdfColors.grey),
                 borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text("Coverage Summary", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                  pw.SizedBox(height: 4),
                  pw.Text("Coverage: ${_filterType.name.substring(0,1).toUpperCase()}${_filterType.name.substring(1)} (${_reportData!['period']?.replaceAll('Period: ', '') ?? ''}) • ${_selectedBatchId == 'all' ? 'All Batches' : 'Specific Batch'}"),
                ]
              )
            ),
            pw.Divider(),
            pw.SizedBox(height: 10),
         ]
      );
  }
  
  pw.Widget _buildPdfFooter(pw.Context context, String academyName) {
      return pw.Column(
        children: [
           pw.Divider(),
           pw.Row(
             mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
             children: [
               pw.Text("$academyName | Badmintion App", style: const pw.TextStyle(fontSize: 8)),
               pw.Text("Page ${context.pageNumber} of ${context.pagesCount}", style: const pw.TextStyle(fontSize: 8)),
             ]
           )
        ]
      );
  }
  
  pw.Widget _buildPdfContent(pw.Context context) {
    // Determine context: All Batches vs Specific Batch, Year vs Season
    final bool isAllBatches = _selectedBatchId == 'all';
    
    if (isAllBatches) {
      return _buildAllBatchesContent();
    } else {
      return _buildSpecificBatchContent();
    }
  }

  pw.Widget _buildAllBatchesContent() {
    final overview = _reportData!['overview'];
    final breakdown = _reportData!['breakdown'] as List;
    
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
         // Page 1: Overview
         pw.Text(
           _filterType == FilterType.year ? "Year Overview (Executive Summary)" : "Season Overview",
           style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)
         ),
         pw.SizedBox(height: 10),
         _buildOverviewTable(overview),
         
         pw.SizedBox(height: 20),
         pw.Text("Batch-wise Breakdown", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
         pw.SizedBox(height: 10),
         _buildBreakdownTable(breakdown),
      ]
    );
  }

  pw.Widget _buildSpecificBatchContent() {
    final overview = _reportData!['overview'];
    final details = _reportData!['student_details'] as List?;
    // Batch name from breakdown or filter (if available in overview it's better, but we have input)
    // For specific batch, overview usually contains data for that batch only
    
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
         pw.Text("Batch Overview", style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
         pw.SizedBox(height: 10),
         _buildOverviewTable(overview),
         
         pw.SizedBox(height: 20),
         pw.Text("Student-Level Details", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
         pw.SizedBox(height: 10),
         if (details != null && details.isNotEmpty)
           _buildStudentDetailsTable(details)
         else
           pw.Text("No student details available."),
      ]
    );
  }

  pw.Widget _buildOverviewTable(Map<String, dynamic> overview) {
    if (_reportType == ReportType.attendance) {
       return pw.Table.fromTextArray(
         headers: ['Metric', 'Value'],
         data: [
           ['Total Students', '${overview['total_students']}'],
           ['Classes Conducted', '${overview['total_conducted']}'],
           ['Present Count', '${overview['present_count']}'],
           ['Absent Count', '${overview['absent_count']}'],
           ['Attendance Rate', '${overview['attendance_rate']}%'],
         ],
         headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
         cellAlignment: pw.Alignment.centerLeft,
         headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
       );
    } else {
       // Fee
       return pw.Table.fromTextArray(
         headers: ['Metric', 'Value'],
         data: [
           ['Total Students', '${overview['total_students']}'],
           ['Expected Revenue', '${overview['total_expected']}'], // Using simple format for now
           ['Collected Revenue', '${overview['total_collected']}'],
           ['Pending Amount', '${overview['pending_amount']}'],
           ['Overdue Amount', '${overview['overdue_amount']}'],
         ],
         headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
         cellAlignment: pw.Alignment.centerLeft,
         headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
       );
    }
  }

  pw.Widget _buildBreakdownTable(List breakdown) {
    if (_reportType == ReportType.attendance) {
      return pw.Table.fromTextArray(
        headers: ['Batch Name', 'Students', 'Classes', 'Att. Rate'],
        data: breakdown.map((b) => [
          b['name'],
          '${b['total_students']}',
          '${b['classes_conducted']}',
          '${b['attendance_rate']}%'
        ]).toList(),
        headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
      );
    } else {
      return pw.Table.fromTextArray(
        headers: ['Batch Name', 'Students', 'Expected', 'Collected', 'Pending Ct'],
        data: breakdown.map((b) => [
          b['name'],
          '${b['total_students']}',
          '${b['expected']}',
          '${b['collected']}',
          '${b['pending_count']}'
        ]).toList(),
        headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
      );
    }
  }

  pw.Widget _buildStudentDetailsTable(List details) {
    if (_reportType == ReportType.attendance) {
      return pw.Table.fromTextArray(
        headers: ['Name', 'Phone', 'Assigned', 'Attended', 'Absent', '%'],
        columnWidths: {
          0: const pw.FlexColumnWidth(2), 
          1: const pw.FlexColumnWidth(1.5),
        },
        data: details.map((s) => [
          s['name'],
          s['phone'] ?? '-',
          '${s['classes_assigned']}',
          '${s['classes_attended']}',
          '${s['classes_absent']}',
          '${s['attendance_percentage']}%'
        ]).toList(),
        headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
        cellStyle: const pw.TextStyle(fontSize: 9),
        headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
      );
    } else {
      return pw.Table.fromTextArray(
        headers: ['Name', 'Phone', 'Total Fee', 'Paid', 'Pending', 'Status'],
        columnWidths: {
          0: const pw.FlexColumnWidth(2), 
          1: const pw.FlexColumnWidth(1.5),
        },
        data: details.map((s) => [
          s['name'],
          s['phone'] ?? '-',
          '${s['total_fee']}',
          '${s['amount_paid']}',
          '${s['pending_amount']}',
          s['payment_status']
        ]).toList(),
        headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
        cellStyle: const pw.TextStyle(fontSize: 9),
        headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
      );
    }
  }

  // Update _exportPDF to pass ownerName
  Future<void> _exportPDF() async {
    if (_reportData == null) return;
    
    try {
      final pdf = pw.Document();
      
      final academyName = "Badminton Academy"; // TODO: Get from store
      final address = "123 Sports Ave, Tech City"; // TODO: Get from store
      final ownerName = "Jane Doe"; // TODO: Get from store
      
      pdf.addPage(
        pw.MultiPage(
          header: (ctx) => _buildPdfHeader(ctx, academyName, address, ownerName),
          footer: (ctx) => _buildPdfFooter(ctx, academyName),
          build: (ctx) => [
             _buildPdfContent(ctx),
          ],
        ),
      );
      
      final name = "Report_${_reportType.name}_${DateTime.now().millisecondsSinceEpoch}.pdf";
      final bytes = await pdf.save();
      
      if (kIsWeb) {
        downloadFileWeb(bytes, name, 'application/pdf');
      } else {
        final dir = await getApplicationDocumentsDirectory();
        // Create reports directory if not exists
        final reportsDir = Directory('${dir.path}/Reports');
        if (!await reportsDir.exists()) {
           await reportsDir.create(recursive: true);
        }
        
        final file = File('${reportsDir.path}/$name');
        await file.writeAsBytes(bytes);
        if (mounted) {
           SuccessSnackbar.show(context, 'Report saved to ${file.path}');
        }
      }
    } catch (e) {
      if (mounted) {
         SuccessSnackbar.showError(context, 'Error generating PDF: $e');
      }
    }
  }
}

