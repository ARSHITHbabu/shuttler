import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../widgets/common/neumorphic_container.dart';
import '../../widgets/common/success_snackbar.dart';
import '../../widgets/common/confirmation_dialog.dart';
import '../../providers/service_providers.dart';
import '../../providers/batch_provider.dart';
import '../../providers/session_provider.dart';
import '../../providers/auth_provider.dart';
import 'dart:io' if (dart.library.html) '../../utils/dart_io_stub.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/api_endpoints.dart';
import '../../widgets/video/video_player_dialog.dart';
import '../../utils/file_download_helper_stub.dart'
    if (dart.library.html) '../../utils/file_download_helper_web.dart';
import '../../utils/path_helper.dart';
import '../../models/video_resource.dart';
import '../../models/student.dart';
import '../../models/batch.dart';
import '../../models/session.dart';

/// Video Management Screen - Upload and manage training videos for students, batches, or seasons
class VideoManagementScreen extends ConsumerStatefulWidget {
  const VideoManagementScreen({super.key});

  @override
  ConsumerState<VideoManagementScreen> createState() => _VideoManagementScreenState();
}

class _VideoManagementScreenState extends ConsumerState<VideoManagementScreen> {
  final String _targetType = 'student'; // 'student', 'batch', 'session'
  int? _selectedBatchId;
  List<int> _selectedTargetIds = [];
  String _audienceType = 'student'; // 'all', 'batch', 'student'
  List<Student> _batchStudents = [];
  List<Batch> _batches = [];
  List<Session> _sessions = [];
  List<VideoResource> _videos = [];
  Map<int, String> _uploaderNames = {}; 
  bool _loadingStudents = false;
  bool _loadingVideos = false;
  bool _showUploadForm = false;
  bool _isUploading = false;
  bool _isDownloading = false;
  int? _downloadingVideoId;
  double _uploadProgress = 0;
  double _downloadProgress = 0;

  final List<XFile> _selectedVideos = [];
  final TextEditingController _remarksController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _remarksController.dispose();
    super.dispose();
  }

  Future<void> _loadBatchStudents() async {
    if (_selectedBatchId == null) {
      if (mounted) {
        setState(() {
          _batchStudents = [];
        });
      }
      return;
    }

    setState(() => _loadingStudents = true);
    try {
      final batchService = ref.read(batchServiceProvider);
      final students = await batchService.getBatchStudents(_selectedBatchId!);
      if (!mounted) return;
      setState(() {
        _batchStudents = students;
        _loadingStudents = false;
      });
      
      // If in batch mode, load videos for batch immediately
      if (_targetType == 'batch') {
        _loadVideos();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingStudents = false);
      SuccessSnackbar.showError(context, 'Failed to load students: ${e.toString()}');
    }
  }

  Future<void> _loadInitialData() async {
    setState(() => _loadingVideos = true);
    try {
      // Load all videos for management
      final videoService = ref.read(videoServiceProvider);
      final videos = await videoService.getAllVideos();
      // Resolve uploader names
      final Map<int, String> uploaderNames = {};
      final ownerService = ref.read(ownerServiceProvider);
      final coachService = ref.read(coachServiceProvider);
      
      for (final video in videos) {
        if (video.uploaderName != null && video.uploadedBy != null) {
          uploaderNames[video.uploadedBy!] = video.uploaderName!;
          continue;
        }

        if (video.uploadedBy != null && !uploaderNames.containsKey(video.uploadedBy)) {
          try {
            try {
              final owner = await ownerService.getOwnerById(video.uploadedBy!);
              uploaderNames[video.uploadedBy!] = owner.name;
            } catch (_) {
              try {
                final coach = await coachService.getCoachById(video.uploadedBy!);
                uploaderNames[video.uploadedBy!] = coach.name;
              } catch (_) {
                uploaderNames[video.uploadedBy!] = 'Unknown';
              }
            }
          } catch (_) {
            uploaderNames[video.uploadedBy!] = 'Unknown';
          }
        }
      }
      
      if (!mounted) return;
      setState(() {
        _videos = videos;
        _uploaderNames = uploaderNames;
        _loadingVideos = false;
      });
      
      // Load batches for selection
      final batches = await ref.read(batchListProvider.future);
      
      // Load sessions for selection
      final sessions = await ref.read(activeSessionsProvider.future);

      if (mounted) {
        setState(() {
            _batches = batches;
            _sessions = sessions;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loadingVideos = false);
        SuccessSnackbar.showError(context, 'Failed to load initial data: ${e.toString()}');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadVideos() async {
    setState(() => _loadingVideos = true);
    try {
      final videoService = ref.read(videoServiceProvider);
      final videos = await videoService.getAllVideos();
      
      // Resolve uploader names
      final Map<int, String> uploaderNames = {};
      final ownerService = ref.read(ownerServiceProvider);
      final coachService = ref.read(coachServiceProvider);
      
      for (final video in videos) {
        if (video.uploaderName != null && video.uploadedBy != null) {
          uploaderNames[video.uploadedBy!] = video.uploaderName!;
          continue;
        }

        if (video.uploadedBy != null && !uploaderNames.containsKey(video.uploadedBy)) {
          try {
            try {
              final owner = await ownerService.getOwnerById(video.uploadedBy!);
              uploaderNames[video.uploadedBy!] = owner.name;
            } catch (_) {
              try {
                final coach = await coachService.getCoachById(video.uploadedBy!);
                uploaderNames[video.uploadedBy!] = coach.name;
              } catch (_) {
                uploaderNames[video.uploadedBy!] = 'Unknown';
              }
            }
          } catch (_) {
            uploaderNames[video.uploadedBy!] = 'Unknown';
          }
        }
      }

      if (!mounted) return;
      setState(() {
        _videos = videos;
        _uploaderNames = uploaderNames;
        _loadingVideos = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _loadingVideos = false);
        SuccessSnackbar.showError(context, 'Failed to reload videos: ${e.toString()}');
      }
    }
  }

  Future<void> _pickVideos() async {
    try {
      final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
      if (video != null) {
        setState(() {
          _selectedVideos.add(video);
        });
      }
    } catch (e) {
      if (mounted) {
        SuccessSnackbar.showError(context, 'Failed to pick video: ${e.toString()}');
      }
    }
  }

  void _removeVideo(int index) {
    setState(() {
      _selectedVideos.removeAt(index);
    });
  }

  Future<void> _uploadVideos() async {
    if (_selectedVideos.isEmpty) {
      SuccessSnackbar.showError(context, 'Please select at least one video');
      return;
    }

    if (_audienceType != 'all' && _selectedTargetIds.isEmpty) {
      SuccessSnackbar.showError(context, 'Please select at least one $_audienceType');
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0;
    });

    try {
      final videoService = ref.read(videoServiceProvider);
      final authState = ref.read(authProvider).value;
      int? uploadedBy;
      if (authState is Authenticated) {
        uploadedBy = authState.userId;
      }
      final remarks = _remarksController.text.trim().isEmpty ? null : _remarksController.text.trim();

      int completed = 0;
      for (final video in _selectedVideos) {
        await videoService.uploadVideoFromFile(
          audienceType: _audienceType,
          targetIds: _selectedTargetIds,
          videoFile: video,
          title: video.name,
          remarks: remarks,
          uploadedBy: uploadedBy,
          onProgress: (sent, total) {
            if (mounted) {
              setState(() {
                _uploadProgress = (completed + (sent / total)) / _selectedVideos.length;
              });
            }
          },
        );
        completed++;
        if (mounted) {
          setState(() {
            _uploadProgress = completed / _selectedVideos.length;
          });
        }
      }

      if (mounted) {
        setState(() {
          _isUploading = false;
          _showUploadForm = false;
          _selectedVideos.clear();
          _remarksController.clear();
          _selectedTargetIds = [];
        });
        SuccessSnackbar.show(context, 'Videos uploaded successfully');
        _loadVideos();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        SuccessSnackbar.showError(context, 'Failed to upload videos: ${e.toString()}');
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
        final response = await dio.get<Uint8List>(
          fullUrl,
          options: Options(responseType: ResponseType.bytes),
          onReceiveProgress: (received, total) {
            if (total != -1 && mounted) {
              setState(() => _downloadProgress = received / total);
            }
          },
        );

        if (response.data != null && mounted) {
          downloadFileWeb(response.data!, fileName, 'video/mp4');
          setState(() {
            _isDownloading = false;
            _downloadingVideoId = null;
          });
          SuccessSnackbar.show(context, 'Video download started');
        }
      } else {
        // Mobile/Desktop download: Use url_launcher to hand off to system browser
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
          // Fallback to internal storage
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

          final directory = Directory(directoryPath);
          if (!await directory.exists()) await directory.create(recursive: true);
          final filePath = '${directory.path}/$fileName';

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
            SuccessSnackbar.show(context, 'Video saved to $directoryPath');
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

  Future<void> _deleteVideo(VideoResource video) async {
    ConfirmationDialog.showDelete(
      context,
      'Video',
      onConfirm: () async {
        try {
          final videoService = ref.read(videoServiceProvider);
          await videoService.deleteVideo(video.id);
          if (mounted) {
            SuccessSnackbar.show(context, 'Video deleted successfully');
            _loadVideos();
          }
        } catch (e) {
          if (mounted) {
            SuccessSnackbar.showError(context, 'Failed to delete video: ${e.toString()}');
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Management'),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      backgroundColor: AppColors.background,
      floatingActionButton: !_showUploadForm
          ? FloatingActionButton(
              onPressed: () => setState(() => _showUploadForm = true),
              backgroundColor: AppColors.accent,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isSmallScreen ? AppDimensions.paddingM : AppDimensions.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_showUploadForm) ...[
              _buildUploadForm(isSmallScreen),
            ] else ...[
              _buildVideoList(isSmallScreen),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUploadForm(bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Upload Videos',
              style: TextStyle(
                fontSize: isSmallScreen ? 16 : 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            IconButton(
              onPressed: () => setState(() {
                _showUploadForm = false;
                _selectedVideos.clear();
                _remarksController.clear();
                _selectedTargetIds = [];
              }),
              icon: const Icon(Icons.close, color: AppColors.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.spacingM),

        // Audience Type Selector
        const Text(
          'Target Audience',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingS),
        Wrap(
          spacing: AppDimensions.spacingS,
          runSpacing: AppDimensions.spacingS,
          children: [
            _buildAudienceChip('Everyone', 'all'),
            _buildAudienceChip('Sessions', 'session'),
            _buildAudienceChip('Batches', 'batch'),
            _buildAudienceChip('Individuals', 'student'),
          ],
        ),
        const SizedBox(height: AppDimensions.spacingM),

        // Specific Target Selection
        if (_audienceType == 'session') _buildSessionMultiSelect(),
        if (_audienceType == 'batch') _buildBatchMultiSelect(),
        if (_audienceType == 'student') _buildStudentMultiSelect(),

        const SizedBox(height: AppDimensions.spacingL),

        // Video Picker
        NeumorphicContainer(
          onTap: _isUploading ? null : _pickVideos,
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          child: Column(
            children: [
              Icon(
                Icons.video_call_outlined,
                size: 48,
                color: _isUploading ? AppColors.textHint : AppColors.accent,
              ),
              const SizedBox(height: AppDimensions.spacingS),
              Text(
                _selectedVideos.isEmpty
                    ? 'Tap to select videos'
                    : '${_selectedVideos.length} video(s) selected',
                style: TextStyle(
                  fontSize: 14,
                  color: _isUploading ? AppColors.textHint : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.spacingM),

        // Selected Videos List
        if (_selectedVideos.isNotEmpty) ...[
          const Text(
            'Selected Videos:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingS),
          ...List.generate(_selectedVideos.length, (index) {
            final video = _selectedVideos[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.spacingS),
              child: NeumorphicContainer(
                padding: const EdgeInsets.all(AppDimensions.paddingS),
                child: Row(
                  children: [
                    const Icon(Icons.video_file, color: AppColors.accent, size: 20),
                    const SizedBox(width: AppDimensions.spacingS),
                    Expanded(
                      child: Text(
                        video.name,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (!_isUploading)
                      IconButton(
                        onPressed: () => _removeVideo(index),
                        icon: const Icon(Icons.close, color: AppColors.error, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: AppDimensions.spacingM),
        ],

        // Remarks Field
        const Text(
          'Remarks (optional)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingS),
        NeumorphicContainer(
          padding: const EdgeInsets.all(AppDimensions.paddingM),
          child: TextField(
            controller: _remarksController,
            enabled: !_isUploading,
            maxLines: 3,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(
              hintText: 'Add notes or remarks for this video...',
              hintStyle: TextStyle(color: AppColors.textHint),
              border: InputBorder.none,
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.spacingL),

        // Upload Progress
        if (_isUploading) ...[
          LinearProgressIndicator(
            value: _uploadProgress,
            backgroundColor: AppColors.cardBackground,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
          ),
          const SizedBox(height: AppDimensions.spacingS),
          Text(
            'Uploading... ${(_uploadProgress * 100).toInt()}%',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingM),
        ],

        // Submit Button
        SizedBox(
          width: double.infinity,
          child: NeumorphicContainer(
            onTap: _isUploading ? null : _uploadVideos,
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            child: Center(
              child: _isUploading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
                      ),
                    )
                  : const Text(
                      'Upload Videos',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accent,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAudienceChip(String label, String type) {
    final isSelected = _audienceType == type;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    
    return GestureDetector(
      onTap: () => setState(() {
        _audienceType = type;
        _selectedTargetIds = [];
      }),
      child: NeumorphicContainer(
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 10 : 16,
          vertical: isSmallScreen ? 6 : 8,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.accent : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: isSmallScreen ? 12 : 14,
          ),
        ),
      ),
    );
  }

  Widget _buildBatchMultiSelect() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Select Batches:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _batches.map((batch) {
            final isSelected = _selectedTargetIds.contains(batch.id);
            return FilterChip(
              label: Text(batch.name),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedTargetIds.add(batch.id);
                  } else {
                    _selectedTargetIds.remove(batch.id);
                  }
                });
              },
              selectedColor: AppColors.accent.withOpacity(0.2),
              checkmarkColor: AppColors.accent,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSessionMultiSelect() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Select Practice Sessions:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _sessions.map((session) {
            final isSelected = _selectedTargetIds.contains(session.id);
            return FilterChip(
              label: Text(session.name),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedTargetIds.add(session.id);
                  } else {
                    _selectedTargetIds.remove(session.id);
                  }
                });
              },
              selectedColor: AppColors.accent.withOpacity(0.2),
              checkmarkColor: AppColors.accent,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStudentMultiSelect() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Select Batch First:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        NeumorphicContainer(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingM),
          child: DropdownButtonFormField<int>(
            initialValue: _selectedBatchId,
            decoration: const InputDecoration(border: InputBorder.none, hintText: 'Select a batch'),
            dropdownColor: AppColors.cardBackground,
            items: _batches.map((batch) => DropdownMenuItem(value: batch.id, child: Text(batch.name))).toList(),
            onChanged: (value) {
              setState(() {
                _selectedBatchId = value;
                _selectedTargetIds = [];
              });
              _loadBatchStudents();
            },
          ),
        ),
        if (_selectedBatchId != null) ...[
          const SizedBox(height: 16),
          _loadingStudents 
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                        const Text('Select Students:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        TextButton(
                            onPressed: () {
                                setState(() {
                                    if (_selectedTargetIds.length == _batchStudents.length) {
                                        _selectedTargetIds = [];
                                    } else {
                                        _selectedTargetIds = _batchStudents.map((s) => s.id).toList();
                                    }
                                });
                            },
                            child: Text(_selectedTargetIds.length == _batchStudents.length ? 'Deselect All' : 'Select All'),
                        ),
                    ],
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _batchStudents.map((student) {
                      final isSelected = _selectedTargetIds.contains(student.id);
                      return FilterChip(
                        label: Text(student.name),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedTargetIds.add(student.id);
                            } else {
                              _selectedTargetIds.remove(student.id);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
        ],
      ],
    );
  }

  Widget _buildVideoList(bool isSmallScreen) {
    if (_loadingVideos) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_videos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.video_library_outlined, size: 64, color: AppColors.textHint),
            const SizedBox(height: AppDimensions.spacingM),
            const Text('No videos yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Manage Videos (${_videos.length})',
          style: TextStyle(
              fontSize: isSmallScreen ? 16 : 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary),
        ),
        SizedBox(height: isSmallScreen ? AppDimensions.spacingS : AppDimensions.spacingM),
        ...List.generate(_videos.length, (index) {
          final video = _videos[index];
          return Padding(
            padding: EdgeInsets.only(bottom: isSmallScreen ? AppDimensions.spacingS : AppDimensions.spacingM),
            child: _buildVideoCard(video, isSmallScreen),
          );
        }),
      ],
    );
  }

  Widget _buildVideoCard(VideoResource video, bool isSmallScreen) {
    final isDownloading = _isDownloading && _downloadingVideoId == video.id;

    return NeumorphicContainer(
      padding: EdgeInsets.all(isSmallScreen ? AppDimensions.paddingM : AppDimensions.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => _playVideo(video),
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  ),
                  child: const Icon(Icons.play_circle_outline, color: AppColors.accent, size: 30),
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
                          fontSize: isSmallScreen ? 14 : 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${video.formattedDate} • ${video.audienceType.toUpperCase()}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    if (video.uploadedBy != null && _uploaderNames.containsKey(video.uploadedBy)) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.person_outline, size: 12, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            'By: ${_uploaderNames[video.uploadedBy]}',
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                   IconButton(
                    onPressed: isDownloading ? null : () => _downloadVideo(video),
                    icon: isDownloading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.download_outlined, color: AppColors.accent),
                  ),
                  IconButton(
                    onPressed: () => _deleteVideo(video),
                    icon: const Icon(Icons.delete_outline, color: AppColors.error),
                  ),
                ],
              ),
            ],
          ),
          if (video.remarks != null && video.remarks!.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.spacingS),
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingS),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppDimensions.radiusS),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.notes,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: AppDimensions.spacingS),
                  Expanded(
                    child: Text(
                      video.remarks!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
