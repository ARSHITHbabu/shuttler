import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';
// Conditional import for File/Directory (only on non-web platforms)
import 'dart:io' if (dart.library.html) '../../utils/dart_io_stub.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../core/constants/api_endpoints.dart';
import '../../widgets/common/neumorphic_container.dart';
import '../../widgets/common/success_snackbar.dart';
import '../../widgets/video/video_player_dialog.dart';
import '../../providers/service_providers.dart';
import '../../providers/auth_provider.dart';
import '../../models/video_resource.dart';
// Conditional imports for web file download
import '../../utils/file_download_helper_stub.dart'
    if (dart.library.html) '../../utils/file_download_helper_web.dart';
// Platform-agnostic path helper
import '../../utils/path_helper.dart';

/// Student Videos Screen - View training videos uploaded by owner/coach
class StudentVideosScreen extends ConsumerStatefulWidget {
  final VoidCallback? onBack;

  const StudentVideosScreen({super.key, this.onBack});

  @override
  ConsumerState<StudentVideosScreen> createState() => _StudentVideosScreenState();
}

class _StudentVideosScreenState extends ConsumerState<StudentVideosScreen> {
  List<VideoResource> _videos = [];
  Map<int, String> _uploaderNames = {}; // Map of uploadedBy ID to name
  List<VideoResource> _filteredVideos = [];
  bool _isLoading = true;
  bool _isDownloading = false;
  double _downloadProgress = 0;
  int? _downloadingVideoId;
  
  // Filter state
  int? _selectedYear;
  int? _selectedMonth; // 1-12, null means all months

  @override
  void initState() {
    super.initState();
    _loadVideos();
  }

  Future<void> _loadVideos() async {
    setState(() => _isLoading = true);
    try {
      final authState = ref.read(authProvider).value;
      if (authState is! Authenticated) {
        if (mounted) {
          SuccessSnackbar.showError(context, 'Not logged in');
        }
        return;
      }

      final videoService = ref.read(videoServiceProvider);
      final videos = await videoService.getVideosForStudent(authState.userId);

      // Map to store uploader names (fallback if not provided by backend)
      final Map<int, String> uploaderNamesMap = {};
      final ownerService = ref.read(ownerServiceProvider);
      final coachService = ref.read(coachServiceProvider);
      
      for (final video in videos) {
        // If backend already provided uploaderName, use it
        if (video.uploaderName != null && video.uploadedBy != null) {
          uploaderNamesMap[video.uploadedBy!] = video.uploaderName!;
          continue;
        }

        // Fallback: Fetch uploader names for videos that have uploadedBy but no name
        if (video.uploadedBy != null && !uploaderNamesMap.containsKey(video.uploadedBy)) {
          try {
            // Try to fetch as owner first
            try {
              final owner = await ownerService.getOwnerById(video.uploadedBy!);
              uploaderNamesMap[video.uploadedBy!] = owner.name;
            } catch (_) {
              // If not found as owner, try coach
              try {
                final coach = await coachService.getCoachById(video.uploadedBy!);
                uploaderNamesMap[video.uploadedBy!] = coach.name;
              } catch (_) {
                uploaderNamesMap[video.uploadedBy!] = 'Unknown';
              }
            }
          } catch (e) {
            uploaderNamesMap[video.uploadedBy!] = 'Unknown';
          }
        }
      }

      if (mounted) {
        setState(() {
          _videos = videos;
          _uploaderNames = uploaderNamesMap;
          _isLoading = false;
        });
        _applyFilters();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        SuccessSnackbar.showError(context, 'Failed to load videos: ${e.toString()}');
      }
    }
  }

  void _applyFilters() {
    List<VideoResource> filtered = List.from(_videos);

    // Filter by year
    if (_selectedYear != null) {
      filtered = filtered.where((video) {
        return video.createdAt.year == _selectedYear;
      }).toList();
    }

    // Filter by month
    if (_selectedMonth != null) {
      filtered = filtered.where((video) {
        return video.createdAt.month == _selectedMonth;
      }).toList();
    }

    setState(() {
      _filteredVideos = filtered;
    });
  }

  void _onFilterChanged(int? year, int? month) {
    setState(() {
      _selectedYear = year;
      _selectedMonth = month;
    });
    _applyFilters();
  }

  void _playVideo(VideoResource video) {
    final fullUrl = '${ApiEndpoints.baseUrl}${video.url}';
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => VideoPlayerDialog(
        videoUrl: fullUrl,
        title: video.displayTitle,
        remarks: video.remarks,
      ),
    );
  }

  /// Sanitize filename to remove invalid characters for file system
  String _sanitizeFileName(String fileName) {
    // Remove or replace invalid characters
    return fileName
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_') // Replace invalid chars with underscore
        .replaceAll(RegExp(r'\s+'), '_') // Replace spaces with underscore
        .replaceAll(RegExp(r'_+'), '_') // Replace multiple underscores with single
        .trim();
  }

  Future<void> _downloadVideo(VideoResource video) async {
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0;
      _downloadingVideoId = video.id;
    });

    try {
      final dio = Dio();
      final fullUrl = '${ApiEndpoints.baseUrl}${video.url}';
      final fileName = video.title ?? 'video_${video.id}.mp4';

      if (kIsWeb) {
        // Web download: fetch as bytes and use web helper
        final response = await dio.get<Uint8List>(
          fullUrl,
          options: Options(
            responseType: ResponseType.bytes,
          ),
          onReceiveProgress: (received, total) {
            if (total != -1 && mounted) {
              setState(() {
                _downloadProgress = received / total;
              });
            }
          },
        );

        if (response.data != null && mounted) {
          downloadFileWeb(
            response.data!,
            fileName,
            'video/mp4',
          );
          setState(() {
            _isDownloading = false;
            _downloadingVideoId = null;
          });
          SuccessSnackbar.show(context, 'Video download started');
        }
      } else {
        // Mobile/Desktop download: Use url_launcher to hand off to system browser
        // This is the most reliable way to get the file into the public Downloads folder
        final Uri videoUri = Uri.parse(fullUrl);
        
        if (await canLaunchUrl(videoUri)) {
          await launchUrl(videoUri, mode: LaunchMode.externalApplication);
          if (mounted) {
            setState(() {
              _isDownloading = false;
              _downloadingVideoId = null;
            });
            SuccessSnackbar.show(context, 'Opening download in browser...');
          }
        } else {
          // Fallback to private storage download if browser fails
          final directoryPath = await getApplicationDocumentsPath();
          if (directoryPath == null) {
            if (mounted) {
              setState(() {
                _isDownloading = false;
                _downloadingVideoId = null;
              });
              SuccessSnackbar.showError(context, 'Download directory not available');
            }
            return;
          }

          final sanitizedFileName = _sanitizeFileName(fileName);
          final directory = Directory(directoryPath);
          if (!await directory.exists()) await directory.create(recursive: true);
          final filePath = '${directory.path}/$sanitizedFileName';

          await dio.download(
            fullUrl,
            filePath,
            onReceiveProgress: (received, total) {
              if (total != -1 && mounted) {
                setState(() => _downloadProgress = received / total);
              }
            },
          );

          if (mounted) {
            setState(() {
              _isDownloading = false;
              _downloadingVideoId = null;
            });
            SuccessSnackbar.show(
              context, 
              'Video saved to app storage. Tap PLAY to view.',
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isDownloading = false;
          _downloadingVideoId = null;
        });
        SuccessSnackbar.showError(context, 'Failed to download video: ${e.toString()}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.background : AppColorsLight.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              child: Row(
                children: [
                  if (widget.onBack != null)
                    IconButton(
                      onPressed: widget.onBack,
                      icon: Icon(
                        Icons.arrow_back,
                        color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
                      ),
                    ),
                  Expanded(
                    child: Text(
                      'Training Videos',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _loadVideos,
                    icon: Icon(
                      Icons.refresh,
                      color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Filter Section
            if (!_isLoading && _videos.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingL,
                  vertical: AppDimensions.spacingS,
                ),
                child: _buildFilterSection(isDark),
              ),
            ],

            // Content
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _videos.isEmpty
                      ? _buildEmptyState(isDark)
                      : RefreshIndicator(
                          onRefresh: _loadVideos,
                          child: _filteredVideos.isEmpty && (_selectedYear != null || _selectedMonth != null)
                              ? _buildNoFilterResults(isDark)
                              : ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppDimensions.paddingL,
                                  ),
                                  itemCount: _filteredVideos.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: AppDimensions.spacingM,
                                      ),
                                      child: _buildVideoCard(_filteredVideos[index], isDark),
                                    );
                                  },
                                ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection(bool isDark) {
    // Get available years and months from videos
    final years = _videos.map((v) => v.createdAt.year).toSet().toList()..sort((a, b) => b.compareTo(a));
    final months = [
      {'value': null, 'label': 'All Months'},
      {'value': 1, 'label': 'January'},
      {'value': 2, 'label': 'February'},
      {'value': 3, 'label': 'March'},
      {'value': 4, 'label': 'April'},
      {'value': 5, 'label': 'May'},
      {'value': 6, 'label': 'June'},
      {'value': 7, 'label': 'July'},
      {'value': 8, 'label': 'August'},
      {'value': 9, 'label': 'September'},
      {'value': 10, 'label': 'October'},
      {'value': 11, 'label': 'November'},
      {'value': 12, 'label': 'December'},
    ];

    return Row(
      children: [
        Expanded(
          child: NeumorphicContainer(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingM),
            child: DropdownButtonFormField<int?>(
              initialValue: _selectedYear,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'All Years',
                hintStyle: TextStyle(
                  color: isDark ? AppColors.textHint : AppColorsLight.textHint,
                ),
                contentPadding: EdgeInsets.zero,
              ),
              dropdownColor: isDark ? AppColors.cardBackground : AppColorsLight.cardBackground,
              style: TextStyle(
                color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
                fontSize: 14,
              ),
              items: [
                const DropdownMenuItem<int?>(value: null, child: Text('All Years')),
                ...years.map((year) => DropdownMenuItem<int?>(
                      value: year,
                      child: Text(year.toString()),
                    )),
              ],
              onChanged: (value) => _onFilterChanged(value, _selectedMonth),
            ),
          ),
        ),
        const SizedBox(width: AppDimensions.spacingM),
        Expanded(
          child: NeumorphicContainer(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingM),
            child: DropdownButtonFormField<int?>(
              initialValue: _selectedMonth,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'All Months',
                hintStyle: TextStyle(
                  color: isDark ? AppColors.textHint : AppColorsLight.textHint,
                ),
                contentPadding: EdgeInsets.zero,
              ),
              dropdownColor: isDark ? AppColors.cardBackground : AppColorsLight.cardBackground,
              style: TextStyle(
                color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
                fontSize: 14,
              ),
              items: months.map((month) => DropdownMenuItem<int?>(
                    value: month['value'] as int?,
                    child: Text(month['label'] as String),
                  )).toList(),
              onChanged: (value) => _onFilterChanged(_selectedYear, value),
            ),
          ),
        ),
        if (_selectedYear != null || _selectedMonth != null)
          IconButton(
            onPressed: () => _onFilterChanged(null, null),
            icon: Icon(
              Icons.clear,
              color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
            ),
            tooltip: 'Clear filters',
          ),
      ],
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.video_library_outlined,
            size: 64,
            color: isDark ? AppColors.textHint : AppColorsLight.textHint,
          ),
          const SizedBox(height: AppDimensions.spacingM),
          Text(
            'No videos yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingS),
          Text(
            'Your coach will upload training videos here',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.textHint : AppColorsLight.textHint,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNoFilterResults(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.filter_alt_off,
            size: 64,
            color: isDark ? AppColors.textHint : AppColorsLight.textHint,
          ),
          const SizedBox(height: AppDimensions.spacingM),
          Text(
            'No videos found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingS),
          Text(
            'Try adjusting your filters',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.textHint : AppColorsLight.textHint,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildVideoCard(VideoResource video, bool isDark) {
    final isDownloading = _isDownloading && _downloadingVideoId == video.id;

    return NeumorphicContainer(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Video thumbnail placeholder
              GestureDetector(
                onTap: () => _playVideo(video),
                child: Container(
                  width: 80,
                  height: 60,
                  decoration: BoxDecoration(
                    color: (isDark ? AppColors.accent : AppColorsLight.accent)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  ),
                  child: Icon(
                    Icons.play_circle_filled,
                    color: isDark ? AppColors.accent : AppColorsLight.accent,
                    size: 36,
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video.displayTitle,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      video.formattedDate,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
                      ),
                    ),
                    if (video.uploadedBy != null && _uploaderNames.containsKey(video.uploadedBy)) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.person_outline,
                            size: 14,
                            color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Uploaded by: ${_uploaderNames[video.uploadedBy]}',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              // Action buttons
              Column(
                children: [
                  IconButton(
                    onPressed: () => _playVideo(video),
                    icon: Icon(
                      Icons.play_arrow,
                      color: isDark ? AppColors.accent : AppColorsLight.accent,
                    ),
                    tooltip: 'Play',
                  ),
                  IconButton(
                    onPressed: isDownloading ? null : () => _downloadVideo(video),
                    icon: isDownloading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              value: _downloadProgress,
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isDark ? AppColors.accent : AppColorsLight.accent,
                              ),
                            ),
                          )
                        : Icon(
                            Icons.download,
                            color: isDark
                                ? AppColors.textSecondary
                                : AppColorsLight.textSecondary,
                          ),
                    tooltip: 'Download',
                  ),
                ],
              ),
            ],
          ),

          // Remarks
          if (video.remarks != null && video.remarks!.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.spacingM),
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingS),
              decoration: BoxDecoration(
                color: isDark ? AppColors.background : AppColorsLight.background,
                borderRadius: BorderRadius.circular(AppDimensions.radiusS),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.notes,
                    size: 16,
                    color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
                  ),
                  const SizedBox(width: AppDimensions.spacingS),
                  Expanded(
                    child: Text(
                      video.remarks!,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Download progress
          if (isDownloading) ...[
            const SizedBox(height: AppDimensions.spacingS),
            LinearProgressIndicator(
              value: _downloadProgress,
              backgroundColor: isDark ? AppColors.cardBackground : AppColorsLight.cardBackground,
              valueColor: AlwaysStoppedAnimation<Color>(
                isDark ? AppColors.accent : AppColorsLight.accent,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Downloading... ${(_downloadProgress * 100).toInt()}%',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
