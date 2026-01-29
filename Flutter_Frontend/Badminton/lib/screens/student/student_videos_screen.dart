import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
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
  bool _isLoading = true;
  bool _isDownloading = false;
  double _downloadProgress = 0;
  int? _downloadingVideoId;

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

      if (mounted) {
        setState(() {
          _videos = videos;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        SuccessSnackbar.showError(context, 'Failed to load videos: ${e.toString()}');
      }
    }
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
        // Mobile/Desktop download: save to file system
        final directoryPath = await getApplicationDocumentsPath();
        if (directoryPath == null) {
          // Fallback: shouldn't happen on mobile/desktop, but handle gracefully
          if (mounted) {
            setState(() {
              _isDownloading = false;
              _downloadingVideoId = null;
            });
            SuccessSnackbar.showError(context, 'Download directory not available');
          }
          return;
        }

        // Sanitize filename to remove invalid characters
        final sanitizedFileName = _sanitizeFileName(fileName);
        final directory = Directory(directoryPath);
        
        // Ensure directory exists
        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }

        final filePath = '${directory.path}/$sanitizedFileName';

        await dio.download(
          fullUrl,
          filePath,
          onReceiveProgress: (received, total) {
            if (total != -1 && mounted) {
              setState(() {
                _downloadProgress = received / total;
              });
            }
          },
        );

        if (mounted) {
          setState(() {
            _isDownloading = false;
            _downloadingVideoId = null;
          });
          
          // Show user-friendly success message
          final displayPath = directoryPath.contains('Download') 
              ? 'Downloads folder' 
              : directoryPath.contains('Documents')
                  ? 'Documents folder'
                  : 'device storage';
          SuccessSnackbar.show(
            context, 
            'Video downloaded successfully!\nSaved to: $displayPath',
          );
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

            // Content
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _videos.isEmpty
                      ? _buildEmptyState(isDark)
                      : RefreshIndicator(
                          onRefresh: _loadVideos,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.paddingL,
                            ),
                            itemCount: _videos.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(
                                  bottom: AppDimensions.spacingM,
                                ),
                                child: _buildVideoCard(_videos[index], isDark),
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
