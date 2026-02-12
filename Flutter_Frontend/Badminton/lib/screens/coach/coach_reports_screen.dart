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
import '../../core/constants/legal_content.dart';
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
  
  // History State
  int _tabIndex = 0; // 0: Generate, 1: History
  List<Map<String, dynamic>> _historyData = [];
  bool _isHistoryLoading = false;

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
              _buildTabSelector(),
              const SizedBox(height: AppDimensions.spacingL),
              if (_tabIndex == 0) ...[
                _buildReportTypeSelector(),
                const SizedBox(height: AppDimensions.spacingL),
                _buildFilters(),
                const SizedBox(height: AppDimensions.spacingL),
                _buildGenerateButton(),
                const SizedBox(height: AppDimensions.spacingL),
                if (_reportData != null) _buildReportPreview(),
              ] else ...[
                _buildHistoryList(),
              ]
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
                        _reportData = null;
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
                    child: Text(b.batchName ?? "Batch ${b.id}"),
                  )),
                ],
                onChanged: (val) {
                  if (val != null) setState(() {
                    _selectedBatchId = val;
                    _reportData = null;
                  });
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
                onChanged: (val) => setState(() {
                  _selectedYear = val!;
                  _reportData = null;
                }),
              ),
            ),
        ),
      ],
    );
  }
  
  Widget _buildMonthSelector() {
    int currentYear = DateTime.now().year;
    List<int> years = List.generate(10, (i) => currentYear - 5 + i);
    List<String> months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Month", style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _selectedMonth.month,
                        isExpanded: true,
                        items: List.generate(12, (i) => DropdownMenuItem(
                          value: i + 1,
                          child: Text(months[i]),
                        )),
                        onChanged: (val) => setState(() {
                          _selectedMonth = DateTime(_selectedMonth.year, val!);
                          _reportData = null;
                        }),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppDimensions.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Year", style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _selectedMonth.year,
                        isExpanded: true,
                        items: years.map((y) => DropdownMenuItem(
                          value: y,
                          child: Text(y.toString()),
                        )).toList(),
                        onChanged: (val) => setState(() {
                          _selectedMonth = DateTime(val!, _selectedMonth.month);
                          _reportData = null;
                        }),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
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
          : const Text("Generate Report", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }

  Widget _buildTabSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(child: _tabButton("Generate Report", 0)),
          Expanded(child: _tabButton("History", 1)),
        ],
      ),
    );
  }

  Widget _tabButton(String title, int index) {
      bool isSelected = _tabIndex == index;
      return InkWell(
        onTap: () {
          setState(() {
             _tabIndex = index;
             if (index == 1) _loadHistory();
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.accent : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
  }

  Future<void> _loadHistory() async {
     setState(() => _isHistoryLoading = true);
     try {
       final authState = ref.read(authProvider);
       int? userId;
       String? userRole;
       
       authState.whenData((state) {
         if (state is Authenticated) {
           userId = state.userId;
           userRole = state.userRole ?? 'coach';
         }
       });

       if (userId != null && userRole != null) {
         final history = await ref.read(reportServiceProvider).getReportHistory(
           userId: userId!,
           userRole: userRole!,
         );
         if (mounted) setState(() => _historyData = history);
       }
     } catch (e) {
       if (mounted) SuccessSnackbar.showError(context, "Error loading history: $e");
     } finally {
       if (mounted) setState(() => _isHistoryLoading = false);
     }
  }

  Widget _buildHistoryList() {
    if (_isHistoryLoading) return const Center(child: CircularProgressIndicator());
    if (_historyData.isEmpty) return const Center(child: Text("No report history found."));

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _historyData.length,
      itemBuilder: (context, index) {
        final item = _historyData[index];
        final date = DateTime.tryParse(item['generated_on'] ?? '') ?? DateTime.now();
        
        return NeumorphicContainer(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(Icons.description, color: AppColors.accent),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['report_type']?.toString().toUpperCase() ?? 'REPORT', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(item['filter_summary'] ?? '', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    Text(DateFormat('dd MMM yyyy, hh:mm a').format(date), style: TextStyle(color: AppColors.textSecondary, fontSize: 10)),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.download, color: AppColors.accent),
                onPressed: () {
                   setState(() {
                     _reportData = Map<String, dynamic>.from(item['report_data']);
                     try {
                        _reportType = ReportType.values.firstWhere((e) => e.name == item['report_type']);
                     } catch (_) {}
                   });
                   _downloadReport(isHistory: true);
                },
              ),
            ],
          ),
        );
      },
    );
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
    final filterSummary = _reportData!['filter_summary'] ?? 
        "Season: ${_seasons.firstWhere((s) => s.id.toString() == _selectedSeasonId, orElse: () => Session(id: -1, name: 'Unknown', startDate: DateTime.now(), endDate: DateTime.now(), status: 'active')).name} | Batch: ${_selectedBatchId == 'all' ? 'All' : _filteredBatches.firstWhere((b) => b.id.toString() == _selectedBatchId, orElse: () => Batch(id: -1, batchName: 'Unknown', timing: '', period: '', capacity: 0, fees: '', startDate: '', createdBy: '')).batchName}";
    final generatedOn = _reportData!['generated_on'] ?? DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Generated Report", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
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
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "$filterSummary",
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        ),
                         Text(
                          "Generated On: $generatedOn",
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _downloadReport(isHistory: false),
                    icon: const Icon(Icons.download, color: AppColors.accent),
                    tooltip: "Download PDF",
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.spacingL),
              const Divider(color: AppColors.textSecondary),
              const SizedBox(height: AppDimensions.spacingL),
              
              if (_reportData!['overview'] != null)
                Column(
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
                    ...(_reportData!['overview'] as Map<String, dynamic>).entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppDimensions.spacingS),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              entry.key.replaceAll('_', ' ').capitalize(),
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              entry.value.toString(),
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }



  Future<void> _downloadReport({bool isHistory = false}) async {
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
        
         // Create reports directory if not exists
        final reportsDir = Directory('${output.path}/Reports');
        if (!await reportsDir.exists()) {
           await reportsDir.create(recursive: true);
        }

        final fileName = _getFileName();
        final file = File('${reportsDir.path}/$fileName');
        await file.writeAsBytes(await pdf.save());
        if (mounted) {
          SuccessSnackbar.show(context, 'Report saved to ${file.path}');
        }
      }

      // Save history logic
      if (!isHistory) {
         try {
           final authState = ref.read(authProvider);
           int? userId;
           String? userRole;
           
           authState.whenData((state) {
             if (state is Authenticated) {
               userId = state.userId;
               userRole = state.userRole ?? 'coach';
             }
           });

           if (userId != null && userRole != null) {
             final reportService = ref.read(reportServiceProvider);
             
             // Ensure filter_summary exists
             final filterSummary = _reportData!['filter_summary'] ?? 
                "Season: ${_seasons.firstWhere((s) => s.id.toString() == _selectedSeasonId, orElse: () => Session(id: -1, name: 'Unknown', startDate: DateTime.now(), endDate: DateTime.now(), status: 'active')).name} | Batch: ${_selectedBatchId == 'all' ? 'All' : _filteredBatches.firstWhere((b) => b.id.toString() == _selectedBatchId, orElse: () => Batch(id: -1, batchName: 'Unknown', timing: '', period: '', capacity: 0, fees: '', startDate: '', createdBy: '')).batchName}";

             await reportService.saveReportHistory(
               reportType: _reportType.name,
               filterSummary: filterSummary,
               reportData: _reportData!,
               userId: userId!,
               userRole: userRole!,
             );
           }
         } catch (e) {
           print("History save error: $e");
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
        footer: (context) => _buildPdfFooter(context, LegalContent.appName),
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
                pw.Text(LegalContent.appName, style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                pw.Text(LegalContent.appName, style: const pw.TextStyle(fontSize: 12)),
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
            pw.Text("${LegalContent.appName} | Management System", style: const pw.TextStyle(fontSize: 8)),
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
      final values = skillAverages.values.map((v) => _sanitize(v)).toList();
      
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
    if (labels.isEmpty || values.isEmpty) return pw.Text("No comparison data");

    // Sanitize values to prevent NaN errors
    final sanitizedValues = values.map((v) => _sanitize(v)).toList();
    
    // If all values are 0 after sanitization, show message
    if (sanitizedValues.every((v) => v == 0.0)) {
      return pw.Text("No data available for chart", style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600));
    }

    final maxValue = sanitizedValues.reduce((a, b) => a > b ? a : b);
    final barHeight = 100.0;
    final barWidth = 30.0;

    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
      children: List.generate(labels.length, (index) {
        final value = sanitizedValues[index];
        final heightRatio = maxValue > 0 ? value / maxValue : 0.0;
        final currentBarHeight = barHeight * heightRatio;

        return pw.Column(
          mainAxisAlignment: pw.MainAxisAlignment.end,
          children: [
            pw.Text(value.toStringAsFixed(1), style: const pw.TextStyle(fontSize: 8)),
            pw.SizedBox(height: 4),
            pw.Container(
              width: 30,
              height: currentBarHeight.toDouble(),
              decoration: const pw.BoxDecoration(
                color: PdfColors.blue700,
                borderRadius: pw.BorderRadius.all(pw.Radius.circular(2)),
              ),
            ),
            pw.SizedBox(height: 4),
            pw.SizedBox(
              width: barWidth + 10,
              child: pw.Text(
                labels[index],
                style: const pw.TextStyle(fontSize: 7),
                textAlign: pw.TextAlign.center,
                maxLines: 2,
                overflow: pw.TextOverflow.clip,
              ),
            ),
          ],
        );
      }),
    );
  }

  double _sanitize(dynamic value) {
    if (value == null) return 0.0;
    if (value is! num) return 0.0;
    final d = value.toDouble();
    if (d.isNaN || d.isInfinite) return 0.0;
    return d < 0 ? 0.0 : d;
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
