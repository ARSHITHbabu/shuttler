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

// Fee report type removed for coach
enum ReportType { attendance, performance }
enum FilterType { season, year, month }

class CoachReportsScreen extends ConsumerStatefulWidget {
  const CoachReportsScreen({super.key});

  @override
  ConsumerState<CoachReportsScreen> createState() => _CoachReportsScreenState();
}

class _CoachReportsScreenState extends ConsumerState<CoachReportsScreen> {
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
      _filteredBatches = _allBatches;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
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
            'Reports',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

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
          'Reports',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Report Type Selection (Attendance and Performance only)
            const Text(
              'Report Type',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingM),
            Row(
              children: [
                Expanded(
                  child: _ReportTypeCard(
                    icon: Icons.fact_check_outlined,
                    label: 'Attendance',
                    isSelected: _reportType == ReportType.attendance,
                    onTap: () {
                      setState(() {
                        _reportType = ReportType.attendance;
                        _reportData = null;
                      });
                    },
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingM),
                Expanded(
                  child: _ReportTypeCard(
                    icon: Icons.trending_up_outlined,
                    label: 'Performance',
                    isSelected: _reportType == ReportType.performance,
                    onTap: () {
                      setState(() {
                        _reportType = ReportType.performance;
                        _reportData = null;
                      });
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppDimensions.spacingL),

            // Filter Type Selection
            const Text(
              'Filter By',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingM),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(
                    label: 'Season',
                    isSelected: _filterType == FilterType.season,
                    onTap: () {
                      setState(() {
                        _filterType = FilterType.season;
                        _filterBatches();
                        _reportData = null;
                      });
                    },
                  ),
                  const SizedBox(width: AppDimensions.spacingS),
                  _FilterChip(
                    label: 'Year',
                    isSelected: _filterType == FilterType.year,
                    onTap: () {
                      setState(() {
                        _filterType = FilterType.year;
                        _filterBatches();
                        _reportData = null;
                      });
                    },
                  ),
                  const SizedBox(width: AppDimensions.spacingS),
                  _FilterChip(
                    label: 'Month',
                    isSelected: _filterType == FilterType.month,
                    onTap: () {
                      setState(() {
                        _filterType = FilterType.month;
                        _filterBatches();
                        _reportData = null;
                      });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppDimensions.spacingL),

            // Filter Value Selection
            _buildFilterValueSelector(),

            const SizedBox(height: AppDimensions.spacingL),

            // Batch Selection
            const Text(
              'Select Batch',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingM),
            NeumorphicContainer(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingM),
              child: DropdownButtonFormField<String>(
                value: _selectedBatchId,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Select Batch',
                  hintStyle: TextStyle(color: AppColors.textSecondary),
                ),
                dropdownColor: AppColors.cardBackground,
                style: const TextStyle(color: AppColors.textPrimary),
                items: [
                  const DropdownMenuItem(
                    value: 'all',
                    child: Text('All Batches'),
                  ),
                  ..._filteredBatches.map((batch) {
                    return DropdownMenuItem<String>(
                      value: batch.id.toString(),
                      child: Text(batch.batchName),
                    );
                  }),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedBatchId = value ?? 'all';
                    _reportData = null;
                  });
                },
              ),
            ),

            const SizedBox(height: AppDimensions.spacingXl),

            // Generate Report Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _generateReport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingM),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Generate Report',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),

            if (_reportData != null) ...[
              const SizedBox(height: AppDimensions.spacingXl),
              _buildReportPreview(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFilterValueSelector() {
    switch (_filterType) {
      case FilterType.season:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Season',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingM),
            NeumorphicContainer(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingM),
              child: DropdownButtonFormField<String>(
                value: _selectedSeasonId,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Select Season',
                  hintStyle: TextStyle(color: AppColors.textSecondary),
                ),
                dropdownColor: AppColors.cardBackground,
                style: const TextStyle(color: AppColors.textPrimary),
                items: _seasons.map<DropdownMenuItem<String>>((season) {
                  return DropdownMenuItem<String>(
                    value: season.id.toString(),
                    child: Text(season.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSeasonId = value;
                    _filterBatches();
                    _reportData = null;
                  });
                },
              ),
            ),
          ],
        );

      case FilterType.year:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Year',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingM),
            NeumorphicContainer(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingM),
              child: DropdownButtonFormField<int>(
                value: _selectedYear,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Select Year',
                  hintStyle: TextStyle(color: AppColors.textSecondary),
                ),
                dropdownColor: AppColors.cardBackground,
                style: const TextStyle(color: AppColors.textPrimary),
                items: List.generate(5, (index) {
                  final year = DateTime.now().year - index;
                  return DropdownMenuItem<int>(
                    value: year,
                    child: Text(year.toString()),
                  );
                }),
                onChanged: (value) {
                  setState(() {
                    _selectedYear = value ?? DateTime.now().year;
                    _reportData = null;
                  });
                },
              ),
            ),
          ],
        );

      case FilterType.month:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Month',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingM),
            NeumorphicContainer(
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              child: InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedMonth,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                    initialDatePickerMode: DatePickerMode.year,
                    builder: (context, child) {
                      return Theme(
                        data: ThemeData.dark().copyWith(
                          colorScheme: const ColorScheme.dark(
                            primary: AppColors.accent,
                            surface: AppColors.cardBackground,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null) {
                    setState(() {
                      _selectedMonth = picked;
                      _reportData = null;
                    });
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('MMMM yyyy').format(_selectedMonth),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                      ),
                    ),
                    const Icon(
                      Icons.calendar_today,
                      color: AppColors.accent,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
    }
  }

  Future<void> _generateReport() async {
    setState(() => _isLoading = true);

    try {
      final reportService = ref.read(reportServiceProvider);
      
      // Determine filter value based on type
      String filterValue;
      switch (_filterType) {
        case FilterType.season:
          if (_selectedSeasonId == null) {
            throw Exception('Please select a season');
          }
          filterValue = _selectedSeasonId!;
          break;
        case FilterType.year:
          filterValue = _selectedYear.toString();
          break;
        case FilterType.month:
          filterValue = DateFormat('yyyy-MM').format(_selectedMonth);
          break;
      }

      // Generate report
      final data = await reportService.generateReport(
        type: _reportType.name,
        filterType: _filterType.name,
        filterValue: filterValue,
        batchId: _selectedBatchId == 'all' ? null : _selectedBatchId,
      );

      if (mounted) {
        setState(() {
          _reportData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        SuccessSnackbar.showError(context, 'Error generating report: $e');
      }
    }
  }

  Widget _buildReportPreview() {
    return NeumorphicContainer(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Report Preview',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.download, color: AppColors.accent),
                onPressed: _downloadReport,
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingM),
          
          // Report metadata
          _buildMetadataRow('Report Type', _reportType.name.capitalize()),
          _buildMetadataRow('Filter', _filterType.name.capitalize()),
          _buildMetadataRow('Generated On', DateFormat('MMM dd, yyyy HH:mm').format(DateTime.now())),
          
          const SizedBox(height: AppDimensions.spacingL),
          const Divider(color: AppColors.textSecondary),
          const SizedBox(height: AppDimensions.spacingL),
          
          // Report summary
          if (_reportData!['overview'] != null)
            _buildOverviewSection(_reportData!['overview']),
        ],
      ),
    );
  }

  Widget _buildMetadataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacingS),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewSection(Map<String, dynamic> overview) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Overview',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingM),
        ...overview.entries.map((entry) {
          return _buildMetadataRow(
            entry.key.replaceAll('_', ' ').capitalize(),
            entry.value.toString(),
          );
        }),
      ],
    );
  }

  Future<void> _downloadReport() async {
    try {
      // Generate PDF
      final pdf = await _generatePDF();
      
      // Save and download
      if (kIsWeb) {
        // Web download
        final bytes = await pdf.save();
        final fileName = _getFileName();
        downloadFileWeb(bytes, fileName, 'application/pdf');
        if (mounted) {
          SuccessSnackbar.show(context, 'Report downloaded successfully');
        }
      } else {
        // Mobile download
        final output = await getApplicationDocumentsDirectory();
        final fileName = _getFileName();
        final file = File('${output.path}/$fileName');
        await file.writeAsBytes(await pdf.save());
        if (mounted) {
          SuccessSnackbar.show(context, 'Report saved to ${file.path}');
        }
      }
    } catch (e) {
      if (mounted) {
        SuccessSnackbar.showError(context, 'Error downloading report: $e');
      }
    }
  }

  String _getFileName() {
    final reportTypeName = _reportType.name.capitalize();
    final academyName = 'AceBadmintonAcademy';
    final period = _filterType == FilterType.month
        ? DateFormat('MMM_yyyy').format(_selectedMonth)
        : _filterType == FilterType.year
            ? _selectedYear.toString()
            : 'Season';
    final date = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    
    return '${reportTypeName}_${academyName}_${period}_$date.pdf';
  }

  Future<pw.Document> _generatePDF() async {
    final pdf = pw.Document();
    
    // Get user info
    final authState = ref.read(authProvider);
    String userName = 'Coach';
    String userRole = 'coach';
    
    authState.whenData((state) {
      if (state is Authenticated) {
        userName = state.userName;
        userRole = state.userRole ?? 'coach';
      }
    });

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (context) => _buildPdfHeader(context, userName, userRole),
        footer: (context) => _buildPdfFooter(context, 'Ace Badminton Academy'),
        build: (context) => _buildPdfContent(context),
      ),
    );

    return pdf;
  }

  pw.Widget _buildPdfHeader(pw.Context context, String userName, String userRole) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Badminton App', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                pw.Text('Ace Badminton Academy', style: const pw.TextStyle(fontSize: 12)),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text('${_reportType.name.capitalize()} Report', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.Text('Generated by: $userName ($userRole)', style: const pw.TextStyle(fontSize: 10)),
                pw.Text('Date: ${DateFormat('MMM dd, yyyy').format(DateTime.now())}', style: const pw.TextStyle(fontSize: 10)),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Divider(),
        pw.SizedBox(height: 10),
        pw.Text('Period: ${_reportData!['period']}', style: const pw.TextStyle(fontSize: 10)),
      ],
    );
  }

  pw.Widget _buildPdfFooter(pw.Context context, String academyName) {
    return pw.Column(
      children: [
        pw.Divider(),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text("$academyName | Badminton App", style: const pw.TextStyle(fontSize: 8)),
            pw.Text("Page ${context.pageNumber} of ${context.pagesCount}", style: const pw.TextStyle(fontSize: 8)),
          ],
        ),
      ],
    );
  }

  List<pw.Widget> _buildPdfContent(pw.Context context) {
    if (_reportType == ReportType.performance) {
      return _buildPerformanceReportContent();
    }

    // Determine context: All Batches vs Specific Batch, Year vs Season
    final bool isAllBatches = _selectedBatchId == 'all';
    
    if (isAllBatches) {
      return _buildAllBatchesContent();
    } else {
      return _buildSpecificBatchContent();
    }
  }

  List<pw.Widget> _buildPerformanceReportContent() {
    final breakdown = _reportData!['breakdown'] as List;
    final overview = _reportData!['overview'];
    final List<pw.Widget> content = [];

    content.add(pw.Text("Performance Report", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)));
    content.add(pw.SizedBox(height: 5));
    content.add(pw.Text("Period: ${_reportData!['period']}", style: const pw.TextStyle(fontSize: 10)));
    content.add(pw.SizedBox(height: 15));

    // Summary Visual for the whole report
    final skillAverages = overview['skill_averages'] as Map<String, dynamic>? ?? {};
    if (skillAverages.isNotEmpty) {
      content.add(pw.Text("Overall Skill Distribution", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)));
      content.add(pw.SizedBox(height: 10));
      
      final labels = skillAverages.keys.toList();
      final values = skillAverages.values.map((v) => (v as num).toDouble()).toList();
      
      content.add(pw.SizedBox(
        height: 150,
        width: double.infinity,
        child: _buildBarChart(labels, values),
      ));
      content.add(pw.SizedBox(height: 25));
    }

    // Batch-wise breakdown
    for (var batch in breakdown) {
      content.add(pw.Container(
        padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 10),
        decoration: const pw.BoxDecoration(color: PdfColors.grey200),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text("Batch: ${batch['name']}", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.Text("Batch Avg: ${batch['average_rating']} / 5.0", style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
          ],
        ),
      ));
      content.add(pw.SizedBox(height: 10));

      final students = batch['students'] as List? ?? [];
      if (students.isEmpty) {
        content.add(pw.Padding(
          padding: const pw.EdgeInsets.only(left: 20, top: 10, bottom: 20),
          child: pw.Text("No student performance data recorded for this batch in the selected period.", 
            style: const pw.TextStyle(fontSize: 9, fontStyle: pw.FontStyle.italic, color: PdfColors.grey600)),
        ));
      } else {
        // Build rows of student performance
        for (var student in students) {
          content.add(_buildStudentPerformanceRow(student));
        }
      }
      content.add(pw.SizedBox(height: 15));
    }

    return content;
  }

  pw.Widget _buildStudentPerformanceRow(Map<String, dynamic> student) {
    final skills = student['skill_breakdown'] as Map<String, dynamic>? ?? {};
    
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 6),
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey200, width: 0.5),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(student['name'], style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                  pw.Text("${student['email'] ?? student['phone'] ?? '-'}", style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
                ],
              ),
              pw.Row(
                children: [
                   pw.Text("Rating: ", style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                   pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: const pw.BoxDecoration(color: PdfColors.blue700, borderRadius: pw.BorderRadius.all(pw.Radius.circular(2))),
                    child: pw.Text("${student['average_rating']} / 5.0", style: pw.TextStyle(fontSize: 10, color: PdfColors.white, fontWeight: pw.FontWeight.bold)),
                  ),
                ]
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          
          if (skills.isNotEmpty)
            pw.Wrap(
              spacing: 12,
              runSpacing: 6,
              children: skills.entries.map((e) {
                return pw.SizedBox(
                  width: 85,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(e.key.capitalize(), style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey800)),
                      pw.Row(
                        children: [
                          _buildPdfMiniRatingBar(e.value),
                          pw.SizedBox(width: 4),
                          pw.Text("${e.value}", style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            )
          else
             pw.Text("No skill-wise ratings recorded in this period.", style: const pw.TextStyle(fontSize: 8, fontStyle: pw.FontStyle.italic, color: PdfColors.grey500)),
        ],
      ),
    );
  }

  pw.Widget _buildPdfMiniRatingBar(dynamic rating) {
    double val = (rating as num?)?.toDouble() ?? 0.0;
    return pw.Stack(
      children: [
        pw.Container(height: 4, width: 45, decoration: const pw.BoxDecoration(color: PdfColors.grey200)),
        pw.Container(height: 4, width: (val / 5.0) * 45, decoration: const pw.BoxDecoration(color: PdfColors.orange)),
      ],
    );
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
    final trendData = _reportData!['trend_data'];
    if (trendData == null || trendData['labels'] == null || (trendData['labels'] as List).isEmpty) {
      return pw.Text("No trend data available for visualization.", style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600));
    }

    final labels = (trendData['labels'] as List).map((e) => e.toString()).toList();
    final values = (trendData['values'] as List).map((e) => (e as num).toDouble()).toList();

    return pw.SizedBox(
      height: 150,
      width: double.infinity,
      child: _buildBarChart(labels, values),
    );
  }

  pw.Widget _buildBarChart(List<String> labels, List<double> values) {
    if (labels.isEmpty || values.isEmpty) {
      return pw.Text("No data available");
    }

    final maxValue = values.reduce((a, b) => a > b ? a : b);
    
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
      children: List.generate(labels.length, (index) {
        final barHeight = maxValue > 0 ? (values[index] / maxValue) * 120 : 0;
        return pw.Column(
          mainAxisAlignment: pw.MainAxisAlignment.end,
          children: [
            pw.Text(values[index].toStringAsFixed(1), style: const pw.TextStyle(fontSize: 8)),
            pw.SizedBox(height: 4),
            pw.Container(
              width: 30,
              height: barHeight.toDouble(),
              decoration: const pw.BoxDecoration(
                color: PdfColors.blue700,
                borderRadius: pw.BorderRadius.all(pw.Radius.circular(2)),
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Container(
              width: 40,
              child: pw.Text(
                labels[index],
                style: const pw.TextStyle(fontSize: 7),
                textAlign: pw.TextAlign.center,
              ),
            ),
          ],
        );
      }),
    );
  }

  pw.Widget _buildOverviewTable(Map<String, dynamic> overview) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400),
      children: overview.entries.map((entry) {
        return pw.TableRow(
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(entry.key.replaceAll('_', ' ').capitalize(), style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(entry.value.toString()),
            ),
          ],
        );
      }).toList(),
    );
  }

  pw.Widget _buildBreakdownTable(List breakdown) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400),
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Batch', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
            pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Students', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
            pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Metric', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
          ],
        ),
        ...breakdown.map((batch) {
          return pw.TableRow(
            children: [
              pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(batch['name'] ?? 'N/A')),
              pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(batch['total_students']?.toString() ?? '0')),
              pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(_getMetricValue(batch))),
            ],
          );
        }),
      ],
    );
  }

  pw.Widget _buildStudentDetailsTable(List details) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400),
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Student', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
            pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Contact', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
            pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Metric', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
          ],
        ),
        ...details.map((student) {
          return pw.TableRow(
            children: [
              pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(student['name'] ?? 'N/A')),
              pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(student['phone'] ?? student['email'] ?? 'N/A')),
              pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(_getStudentMetricValue(student))),
            ],
          );
        }),
      ],
    );
  }

  String _getMetricValue(Map<String, dynamic> batch) {
    if (_reportType == ReportType.attendance) {
      return '${batch['attendance_rate']?.toStringAsFixed(1) ?? '0'}%';
    } else {
      return '${batch['average_rating']?.toStringAsFixed(1) ?? '0'}/5.0';
    }
  }

  String _getStudentMetricValue(Map<String, dynamic> student) {
    if (_reportType == ReportType.attendance) {
      return '${student['attendance_rate']?.toStringAsFixed(1) ?? '0'}%';
    } else {
      return '${student['average_rating']?.toStringAsFixed(1) ?? '0'}/5.0';
    }
  }
}

class _ReportTypeCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ReportTypeCard({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: NeumorphicContainer(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.accent : AppColors.background,
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : AppColors.textSecondary,
                size: 28,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingS),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingM,
          vertical: AppDimensions.spacingS,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
