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

  Future<void> _exportPDF() async {
    if (_reportData == null) return;
    
    try {
      final pdf = pw.Document();
      // Use standard fonts
      
      final academyName = "Badminton Academy";
      final address = "123 Sports Ave";
      
      pdf.addPage(
        pw.MultiPage(
          header: (ctx) => _buildPdfHeader(ctx, academyName, address),
          footer: (ctx) => _buildPdfFooter(ctx, academyName),
          build: (ctx) => [
             _buildPdfContent(ctx),
          ],
        ),
      );
      
      final name = "Report_${DateTime.now().millisecondsSinceEpoch}.pdf";
      final bytes = await pdf.save();
      
      if (kIsWeb) {
        downloadFileWeb(bytes, name, 'application/pdf');
      } else {
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/$name');
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
  
  pw.Widget _buildPdfHeader(pw.Context context, String academyName, String address) {
      return pw.Column(
         crossAxisAlignment: pw.CrossAxisAlignment.start,
         children: [
            pw.Text(academyName, style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
            pw.Text(address, style: const pw.TextStyle(fontSize: 10)),
            pw.SizedBox(height: 10),
            pw.Row(
               mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
               children: [
                 pw.Text("Report: ${_reportType.name.toUpperCase()}", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                 pw.Text("Generated: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}"),
               ]
            ),
            pw.Text("Period: ${_reportData!['filter_summary']}"),
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
               pw.Text(academyName, style: const pw.TextStyle(fontSize: 8)),
               pw.Text("Page ${context.pageNumber} of ${context.pagesCount}", style: const pw.TextStyle(fontSize: 8)),
             ]
           )
        ]
      );
  }
  
  pw.Widget _buildPdfContent(pw.Context context) {
    final overview = _reportData!['overview'];
    
    return pw.Column(
       crossAxisAlignment: pw.CrossAxisAlignment.start,
       children: [
          pw.Text("Overview", style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 5),
          pw.Text("Total Students: ${overview['total_students']}"),
          if (_reportType == ReportType.attendance) ...[
             pw.Text("Present: ${overview['present_count']}"),
             pw.Text("Absent: ${overview['absent_count']}"),
             pw.Text("Rate: ${overview['attendance_rate']}%"),
          ] else ...[
             pw.Text("Expected: ${overview['total_expected']}"),
             pw.Text("Collected: ${overview['total_collected']}"),
             pw.Text("Pending: ${overview['pending_amount']}"),
          ],
          
          pw.SizedBox(height: 20),
          pw.Text("Details", style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.Text(
            _reportData!['student_details'] != null 
              ? "See attached table for student details." 
              : "Summary Breakdown attached."
          ),
       ]
    );
  }
}
