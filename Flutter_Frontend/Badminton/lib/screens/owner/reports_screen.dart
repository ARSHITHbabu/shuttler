import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import '../../core/utils/string_extensions.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../widgets/common/neumorphic_container.dart';
import '../../widgets/common/success_snackbar.dart';
import '../../providers/service_providers.dart';
import '../../providers/auth_provider.dart';
import '../../models/session.dart';
import 'package:fl_chart/fl_chart.dart';
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

      final authState = ref.read(authProvider);
      String userName = "Admin";
      String userRole = "Owner";
      
      authState.whenData((state) {
        if (state is Authenticated) {
          userName = state.userName;
          userRole = state.userType;
        }
      });

      final data = await reportService.generateReport(
        type: _reportType.name,
        filterType: _filterType.name,
        filterValue: filterValue,
        batchId: _selectedBatchId,
        generatedByName: userName,
        generatedByRole: userRole,
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
                  if (val) {
                    setState(() {
                      _reportType = type;
                      _reportData = null; // Clear previous report data
                    });
                  }
                },
                selectedColor: AppColors.accent,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
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
    final filterSummary = _reportData!['filter_summary'];
    final generatedBy = _reportData!['generated_by'] ?? "Unknown";
    final generatedOn = _reportData!['generated_on'] ?? "N/A";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Generated Report", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        NeumorphicContainer(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _reportType == ReportType.attendance 
                        ? Icons.fact_check 
                        : _reportType == ReportType.fee 
                          ? Icons.payments 
                          : Icons.insights,
                      color: AppColors.accent,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${_reportType.name.toUpperCase()} REPORT",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          filterSummary ?? "",
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.picture_as_pdf, color: Colors.red, size: 28),
                    onPressed: _exportPDF,
                    tooltip: "Download PDF",
                  ),
                ],
              ),
              const Divider(height: 32),
              _infoRow(Icons.person_outline, "Generated By", generatedBy),
              const SizedBox(height: 8),
              _infoRow(Icons.calendar_today_outlined, "Generated On", generatedOn),
              const SizedBox(height: 20),
              
              const SizedBox(height: 16),
              const SizedBox(height: 16),
              
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _exportPDF,
                  icon: const Icon(Icons.download, size: 18),
                  label: const Text("Download Full PDF Report"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.accent,
                    side: const BorderSide(color: AppColors.accent),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text("$label: ", style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
      ],
    );
  }

  Widget _buildChart() {
    final chartData = _reportData!['chart_data'];
    if (chartData == null || (chartData['labels'] as List).isEmpty) {
      return const Center(child: Text("No data for chart"));
    }

    final List<String> labels = List<String>.from(chartData['labels']);
    final List<double> values = (chartData['values'] as List).map((e) => (e as num).toDouble()).toList();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: values.isEmpty ? 100 : (values.reduce((a, b) => a > b ? a : b) * 1.2).clamp(10, double.infinity),
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < labels.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      labels[value.toInt()].length > 8 
                        ? labels[value.toInt()].substring(0, 6) + '..' 
                        : labels[value.toInt()],
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                }
                return const SizedBox();
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: values.asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value,
                color: AppColors.accent,
                width: 16,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ],
          );
        }).toList(),
      ),
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
                      pw.Text("Generated By: ${_reportData!['generated_by'] ?? 'Admin'}"),
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
                  pw.Text("Coverage: ${_filterType.name.substring(0,1).toUpperCase()}${_filterType.name.substring(1)} (${_reportData!['period']?.replaceAll('Period: ', '') ?? ''}) | ${_selectedBatchId == 'all' ? 'All Batches' : 'Specific Batch'}"),
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
  
  List<pw.Widget> _buildPdfContent(pw.Context context) {
    // Determine context: All Batches vs Specific Batch, Year vs Season
    final bool isAllBatches = _selectedBatchId == 'all';
    
    if (isAllBatches) {
      return _buildAllBatchesContent();
    } else {
      return _buildSpecificBatchContent();
    }
  }

  List<pw.Widget> _buildAllBatchesContent() {
    final overview = _reportData!['overview'];
    final breakdown = _reportData!['breakdown'] as List;
    
    return [
         // Page 1: Overview
         pw.Text(
           _filterType == FilterType.year ? "Year Overview (Executive Summary)" : 
           _filterType == FilterType.month ? "Month Overview" : "Season Overview",
           style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)
         ),
         pw.SizedBox(height: 10),
         _buildOverviewTable(overview),
         
         pw.SizedBox(height: 20),
         pw.Text("Visual Analytics", style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
         pw.SizedBox(height: 10),
         _buildPdfVisuals(),
         
         pw.SizedBox(height: 20),
         pw.Text("Batch-wise Breakdown", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
         pw.SizedBox(height: 10),
         _buildBreakdownTable(breakdown),
    ];
  }

  List<pw.Widget> _buildSpecificBatchContent() {
    final overview = _reportData!['overview'];
    final details = _reportData!['student_details'] as List?;
    
    return [
         pw.Text("Batch Overview", style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
         pw.SizedBox(height: 10),
         _buildOverviewTable(overview),

         pw.SizedBox(height: 20),
         pw.Text("Visual Analytics", style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
         pw.SizedBox(height: 10),
         _buildPdfVisuals(),
         
         pw.SizedBox(height: 20),
         pw.Text("Student-Level Details", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
         pw.SizedBox(height: 10),
         if (details != null && details.isNotEmpty)
           _buildStudentDetailsTable(details)
         else
           pw.Text("No student details available."),
    ];
  }

  pw.Widget _buildPdfVisuals() {
    final chartData = _reportData!['chart_data'];
    final overview = _reportData!['overview'];
    
    List<String> labels = [];
    List<double> values = [];
    if (chartData != null) {
      labels = List<String>.from(chartData['labels'] ?? []);
      values = (chartData['values'] as List?)?.map((e) => _sanitize(e)).toList() ?? [];
    }

    return pw.Container(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              pw.SizedBox(
                width: 250,
                height: 180,
                child: _buildPieChart(overview),
              ),
            ],
          ),
          pw.SizedBox(height: 30),
          
          pw.Text("Batch Comparison", style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.SizedBox(
            width: double.infinity,
            height: 150,
            child: _buildBarChart(labels, values),
          ),
          
          if (_reportData!['trend_data'] != null && (_reportData!['trend_data']['labels'] as List).isNotEmpty) ...[
             pw.SizedBox(height: 30),
             pw.Text("Monthly Performance Trend", style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
             pw.SizedBox(height: 10),
             pw.SizedBox(
               width: double.infinity,
               height: 150,
               child: _buildLineChart(),
             ),
          ],
          
          pw.SizedBox(height: 30),
          pw.Text("Batch-wise Detailed Comparison", style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          _buildHorizontalBarChart(labels, values),
        ],
      ),
    );
  }

  pw.Widget _buildLineChart() {
    final trendData = _reportData!['trend_data'];
    final labels = List<String>.from(trendData['labels'] ?? []);
    final values = (trendData['values'] as List?)?.map((e) => _sanitize(e)).toList() ?? [];
    
    if (labels.isEmpty || values.isEmpty) return pw.SizedBox();

    return pw.Chart(
      grid: pw.CartesianGrid(
        xAxis: pw.FixedAxis(
          List.generate(labels.length, (i) => i.toDouble()),
          format: (v) {
            final s = labels[v.toInt()];
            return s.length >= 7 ? s.substring(2) : s;
          },
          textStyle: const pw.TextStyle(fontSize: 6),
        ),
        yAxis: pw.FixedAxis(
          [0, 20, 40, 60, 80, 100],
          textStyle: const pw.TextStyle(fontSize: 6),
        ),
      ),
      datasets: [
        pw.LineDataSet(
          color: PdfColors.red,
          drawPoints: true,
          pointSize: 2,
          data: List.generate(values.length, (i) => pw.LineChartValue(i.toDouble(), values[i])),
        ),
      ],
    );
  }

  pw.Widget _buildPieChart(Map<String, dynamic> overview) {
    List<pw.PieDataSet> datasets = [];
    
    if (_reportType == ReportType.attendance) {
      final present = _sanitize(overview['present_count']);
      final absent = _sanitize(overview['absent_count']);
      if (present == 0 && absent == 0) return pw.Center(child: pw.Text("No attendance data recorded"));
      datasets = [
        pw.PieDataSet(legend: 'Present', value: present, color: PdfColors.green),
        pw.PieDataSet(legend: 'Absent', value: absent, color: PdfColors.red),
      ];
    } else if (_reportType == ReportType.fee) {
      final collected = _sanitize(overview['total_collected']);
      final pending = _sanitize(overview['pending_amount']);
      if (collected == 0 && pending == 0) return pw.Center(child: pw.Text("No fee data recorded"));
      datasets = [
        pw.PieDataSet(legend: 'Collected', value: collected, color: PdfColors.blue),
        pw.PieDataSet(legend: 'Pending', value: pending, color: PdfColors.orange),
      ];
    } else {
      final reviewed = _sanitize(overview['students_reviewed']);
      final total = _sanitize(overview['total_students']);
      if (total == 0) return pw.Center(child: pw.Text("No performance data recorded"));
      datasets = [
        pw.PieDataSet(legend: 'Reviewed', value: reviewed, color: PdfColors.purple),
        pw.PieDataSet(legend: 'Not Reviewed', value: total - reviewed, color: PdfColors.grey),
      ];
    }

    return pw.Chart(
      title: pw.Text("Overall Distribution", style: const pw.TextStyle(fontSize: 10)),
      grid: pw.PieGrid(),
      datasets: datasets,
    );
  }

  pw.Widget _buildBarChart(List<String> labels, List<double> values) {
    if (labels.isEmpty || values.isEmpty) return pw.Text("No comparison data");

    return pw.Chart(
      grid: pw.CartesianGrid(
        xAxis: pw.FixedAxis(
          List.generate(labels.length, (i) => i.toDouble()),
          format: (v) {
             final label = labels[v.toInt()];
             return label.length > 8 ? label.substring(0, 7) + ".." : label;
          },
          textStyle: const pw.TextStyle(fontSize: 6),
          angle: labels.length > 5 ? 0.3 : 0, // Slight slant if many
        ),
        yAxis: pw.FixedAxis(
          [0, 20, 40, 60, 80, 100],
          textStyle: const pw.TextStyle(fontSize: 6),
        ),
      ),
      datasets: [
        pw.BarDataSet(
          color: PdfColors.blue,
          width: (250 / (labels.length * 1.5).clamp(1, 50)), // Better width calc
          data: List.generate(values.length, (i) => pw.LineChartValue(i.toDouble(), values[i])),
        ),
      ],
    );
  }

  pw.Widget _buildHorizontalBarChart(List<String> labels, List<double> values) {
    if (labels.isEmpty || values.isEmpty) return pw.SizedBox();

    // Use a custom drawing for horizontal bars since pw.BarDataSet is vertical
    return pw.Column(
      children: List.generate(labels.length.clamp(0, 10), (index) {
        final label = labels[index];
        final value = values[index];
        final maxVal = values.isNotEmpty ? values.reduce((a, b) => a > b ? a : b) : 100.0;
        final percentage = maxVal > 0 ? value / maxVal : 0.0;

        return pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 2),
          child: pw.Row(
            children: [
              pw.SizedBox(width: 60, child: pw.Text(label, style: const pw.TextStyle(fontSize: 8))),
              pw.Expanded(
                child: pw.Stack(
                  children: [
                    pw.Container(
                      height: 10,
                      decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                    ),
                    pw.Container(
                      height: 10,
                      width: 300 * percentage, // Rough estimation for width
                      decoration: const pw.BoxDecoration(color: PdfColors.blue600),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(width: 50, child: pw.Text(" ${value.toStringAsFixed(1)}", style: const pw.TextStyle(fontSize: 8))),
            ],
          ),
        );
      }),
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
    } else if (_reportType == ReportType.fee) {
       // Fee
       return pw.Table.fromTextArray(
         headers: ['Metric', 'Value'],
         data: [
           ['Total Students', '${overview['total_students']}'],
           ['Expected Revenue', '${overview['total_expected']}'], 
           ['Collected Revenue', '${overview['total_collected']}'],
           ['Pending Amount', '${overview['pending_amount']}'],
           ['Overdue Amount', '${overview['overdue_amount']}'],
         ],
         headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
         cellAlignment: pw.Alignment.centerLeft,
         headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
       );
    } else {
       // Performance
       return pw.Table.fromTextArray(
         headers: ['Metric', 'Value'],
         data: [
           ['Total Students', '${overview['total_students']}'],
           ['Total Reviews', '${overview['reviews_count']}'],
           ['Students Reviewed', '${overview['students_reviewed']}'],
           ['Average Rating', '${overview['average_rating']} / 5.0'],
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
    } else if (_reportType == ReportType.fee) {
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
    } else {
      return pw.Table.fromTextArray(
        headers: ['Batch Name', 'Students', 'Reviews', 'Avg Rating'],
        data: breakdown.map((b) => [
          b['name'],
          '${b['total_students']}',
          '${b['reviews_count']}',
          '${b['average_rating']}'
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
    } else if (_reportType == ReportType.fee) {
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
    } else {
      return pw.Table.fromTextArray(
        headers: ['Name', 'Phone', 'Reviews', 'Avg Rating', 'Last Review'],
        columnWidths: {
          0: const pw.FlexColumnWidth(2), 
          1: const pw.FlexColumnWidth(1.5),
        },
        data: details.map((s) => [
          s['name'],
          s['phone'] ?? '-',
          '${s['reviews_count']}',
          '${s['average_rating']}',
          '${s['last_review']}',
          'Reviewed'
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
          build: (ctx) => _buildPdfContent(ctx),
        ),
      );
      
      final typeStr = _reportType.name.capitalize();
      final dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final periodStr = (_reportData?['period']?.toString() ?? 'Report').replaceAll(' ', '');
      final cleanAcademyName = academyName.replaceAll(' ', '');
      
      final name = "${typeStr}_${cleanAcademyName}_${periodStr}_$dateStr.pdf";
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

  double _sanitize(dynamic value) {
    if (value == null) return 0.0;
    if (value is! num) return 0.0;
    final d = value.toDouble();
    if (d.isNaN || d.isInfinite) return 0.0;
    // Also avoid negative values for charts if they represent counts/rates
    return d < 0 ? 0.0 : d;
  }
}

