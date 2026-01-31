import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../widgets/common/neumorphic_container.dart';
import '../../widgets/common/success_snackbar.dart';
import '../../widgets/common/confirmation_dialog.dart';
import '../../providers/service_providers.dart';
import '../../providers/coach_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/video_resource.dart';
import '../../models/student.dart';

/// Coach Video Management Screen - Upload and manage training videos for students
class CoachVideoManagementScreen extends ConsumerStatefulWidget {
  const CoachVideoManagementScreen({super.key});

  @override
  ConsumerState<CoachVideoManagementScreen> createState() => _CoachVideoManagementScreenState();
}

class _CoachVideoManagementScreenState extends ConsumerState<CoachVideoManagementScreen> {
  int? _selectedBatchId;
  int? _selectedStudentId;
  List<Student> _batchStudents = [];
  List<VideoResource> _videos = [];
  Map<int, String> _uploaderNames = {}; // Map of uploadedBy ID to name
  bool _loadingStudents = false;
  bool _loadingVideos = false;
  bool _showUploadForm = false;
  bool _isUploading = false;
  double _uploadProgress = 0;

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
      setState(() {
        _batchStudents = [];
        _selectedStudentId = null;
        _videos = [];
      });
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
        _selectedStudentId = null;
        _videos = [];
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingStudents = false);
      if (mounted) {
        SuccessSnackbar.showError(context, 'Failed to load students: ${e.toString()}');
      }
    }
  }

  Future<void> _loadVideos() async {
    if (_selectedStudentId == null) {
      setState(() {
        _videos = [];
        _uploaderNames = {};
      });
      return;
    }

    setState(() => _loadingVideos = true);
    try {
      final videoService = ref.read(videoServiceProvider);
      final videos = await videoService.getVideosForStudent(_selectedStudentId!);
      
      // Fetch uploader names for videos that have uploadedBy
      final Map<int, String> uploaderNames = {};
      final ownerService = ref.read(ownerServiceProvider);
      final coachService = ref.read(coachServiceProvider);
      
      for (final video in videos) {
        if (video.uploadedBy != null && !uploaderNames.containsKey(video.uploadedBy)) {
          try {
            // Try to fetch as owner first
            try {
              final owner = await ownerService.getOwnerById(video.uploadedBy!);
              uploaderNames[video.uploadedBy!] = owner.name;
            } catch (_) {
              // If not found as owner, try coach
              try {
                final coach = await coachService.getCoachById(video.uploadedBy!);
                uploaderNames[video.uploadedBy!] = coach.name;
              } catch (_) {
                uploaderNames[video.uploadedBy!] = 'Unknown';
              }
            }
          } catch (e) {
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
      if (!mounted) return;
      setState(() => _loadingVideos = false);
      if (mounted) {
        SuccessSnackbar.showError(context, 'Failed to load videos: ${e.toString()}');
      }
    }
  }

  Future<void> _pickVideos() async {
    try {
      // Use pickVideo which is specifically for video selection
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

    if (_selectedStudentId == null) {
      SuccessSnackbar.showError(context, 'Please select a student first');
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
          studentId: _selectedStudentId!,
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authState = ref.watch(authProvider);

    return authState.when(
      data: (authValue) {
        if (authValue is! Authenticated) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Video Management'),
              backgroundColor: isDark ? AppColors.background : AppColorsLight.background,
              elevation: 0,
            ),
            body: const Center(
              child: Text(
                'Please login',
                style: TextStyle(color: AppColors.error),
              ),
            ),
          );
        }

        final coachId = authValue.userId;
        final batchesAsync = ref.watch(coachBatchesProvider(coachId));

        return Scaffold(
          appBar: AppBar(
            title: const Text('Video Management'),
            backgroundColor: isDark ? AppColors.background : AppColorsLight.background,
            elevation: 0,
          ),
          backgroundColor: isDark ? AppColors.background : AppColorsLight.background,
          floatingActionButton: _selectedStudentId != null && !_showUploadForm
              ? FloatingActionButton(
                  onPressed: () => setState(() => _showUploadForm = true),
                  backgroundColor: AppColors.accent,
                  child: const Icon(Icons.add, color: Colors.white),
                )
              : null,
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.paddingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Batch Selector
                const Text(
                  'Select Batch',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingS),
                batchesAsync.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (e, _) => Text('Error: $e', style: const TextStyle(color: AppColors.error)),
                  data: (batches) {
                    if (batches.isEmpty) {
                      return NeumorphicContainer(
                        padding: const EdgeInsets.all(AppDimensions.paddingM),
                        child: Center(
                          child: Text(
                            'No batches assigned',
                            style: TextStyle(color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary),
                          ),
                        ),
                      );
                    }
                    return NeumorphicContainer(
                      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingM),
                      child: DropdownButtonFormField<int>(
                        value: _selectedBatchId,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Select a batch',
                          hintStyle: TextStyle(color: isDark ? AppColors.textHint : AppColorsLight.textHint),
                        ),
                        dropdownColor: isDark ? AppColors.cardBackground : AppColorsLight.cardBackground,
                        style: TextStyle(color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary),
                        items: batches.map((batch) {
                          return DropdownMenuItem<int>(
                            value: batch.id,
                            child: Text(batch.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedBatchId = value);
                          _loadBatchStudents();
                        },
                      ),
                    );
                  },
                ),

                const SizedBox(height: AppDimensions.spacingL),

                // Student Selector
                if (_selectedBatchId != null) ...[
                  const Text(
                    'Select Student',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingS),
                  if (_loadingStudents)
                    const LinearProgressIndicator()
                  else
                    NeumorphicContainer(
                      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingM),
                      child: DropdownButtonFormField<int>(
                        value: _selectedStudentId,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Select a student',
                          hintStyle: TextStyle(color: AppColors.textHint),
                        ),
                        dropdownColor: AppColors.cardBackground,
                        style: const TextStyle(color: AppColors.textPrimary),
                        items: _batchStudents.map((student) {
                          return DropdownMenuItem<int>(
                            value: student.id,
                            child: Text(student.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedStudentId = value;
                            _showUploadForm = false;
                          });
                          _loadVideos();
                        },
                      ),
                    ),
                ],

                const SizedBox(height: AppDimensions.spacingL),

                // Upload Form
                if (_showUploadForm && _selectedStudentId != null) ...[
                  _buildUploadForm(isDark),
                ] else if (_selectedStudentId != null) ...[
                  // Video List
                  _buildVideoList(isDark),
                ],
              ],
            ),
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(
          title: const Text('Video Management'),
          backgroundColor: isDark ? AppColors.background : AppColorsLight.background,
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(
          title: const Text('Video Management'),
          backgroundColor: isDark ? AppColors.background : AppColorsLight.background,
          elevation: 0,
        ),
        body: Center(
          child: Text(
            'Error: ${error.toString()}',
            style: const TextStyle(color: AppColors.error),
          ),
        ),
      ),
    );
  }

  Widget _buildUploadForm(bool isDark) {
    final selectedStudent = _batchStudents.firstWhere(
      (s) => s.id == _selectedStudentId,
      orElse: () => Student(id: 0, name: 'Unknown', phone: '', email: '', status: 'active'),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Upload Videos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
              ),
            ),
            IconButton(
              onPressed: () => setState(() {
                _showUploadForm = false;
                _selectedVideos.clear();
                _remarksController.clear();
              }),
              icon: Icon(Icons.close, color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.spacingM),

        // Student Info
        NeumorphicContainer(
          padding: const EdgeInsets.all(AppDimensions.paddingM),
          child: Row(
            children: [
              Icon(Icons.person_outline, color: isDark ? AppColors.accent : AppColorsLight.accent),
              const SizedBox(width: AppDimensions.spacingM),
              Text(
                'Uploading for: ${selectedStudent.name}',
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.spacingM),

        // Video Picker
        NeumorphicContainer(
          onTap: _isUploading ? null : _pickVideos,
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          child: Column(
            children: [
              Icon(
                Icons.video_call_outlined,
                size: 48,
                color: _isUploading 
                    ? (isDark ? AppColors.textHint : AppColorsLight.textHint)
                    : (isDark ? AppColors.accent : AppColorsLight.accent),
              ),
              const SizedBox(height: AppDimensions.spacingS),
              Text(
                _selectedVideos.isEmpty
                    ? 'Tap to select videos'
                    : '${_selectedVideos.length} video(s) selected',
                style: TextStyle(
                  fontSize: 14,
                  color: _isUploading 
                      ? (isDark ? AppColors.textHint : AppColorsLight.textHint)
                      : (isDark ? AppColors.textSecondary : AppColorsLight.textSecondary),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.spacingM),

        // Selected Videos List
        if (_selectedVideos.isNotEmpty) ...[
          Text(
            'Selected Videos:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
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
                    Icon(Icons.video_file, color: isDark ? AppColors.accent : AppColorsLight.accent, size: 20),
                    const SizedBox(width: AppDimensions.spacingS),
                    Expanded(
                      child: Text(
                        video.name,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
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
        Text(
          'Remarks (optional)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingS),
        NeumorphicContainer(
          padding: const EdgeInsets.all(AppDimensions.paddingM),
          child: TextField(
            controller: _remarksController,
            enabled: !_isUploading,
            maxLines: 3,
            style: TextStyle(color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary),
            decoration: InputDecoration(
              hintText: 'Add notes or remarks for this video...',
              hintStyle: TextStyle(color: isDark ? AppColors.textHint : AppColorsLight.textHint),
              border: InputBorder.none,
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.spacingL),

        // Upload Progress
        if (_isUploading) ...[
          LinearProgressIndicator(
            value: _uploadProgress,
            backgroundColor: isDark ? AppColors.cardBackground : AppColorsLight.cardBackground,
            valueColor: AlwaysStoppedAnimation<Color>(isDark ? AppColors.accent : AppColorsLight.accent),
          ),
          const SizedBox(height: AppDimensions.spacingS),
          Text(
            'Uploading... ${(_uploadProgress * 100).toInt()}%',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
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
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(isDark ? AppColors.accent : AppColorsLight.accent),
                      ),
                    )
                  : Text(
                      'Upload Videos',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.accent : AppColorsLight.accent,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVideoList(bool isDark) {
    if (_loadingVideos) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_videos.isEmpty) {
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
              'Tap + to upload training videos',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.textHint : AppColorsLight.textHint,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Videos (${_videos.length})',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingM),
        ...List.generate(_videos.length, (index) {
          final video = _videos[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: AppDimensions.spacingM),
            child: _buildVideoCard(video, isDark),
          );
        }),
      ],
    );
  }

  Widget _buildVideoCard(VideoResource video, bool isDark) {
    final accentColor = isDark ? AppColors.accent : AppColorsLight.accent;
    
    return NeumorphicContainer(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                ),
                child: Icon(
                  Icons.play_circle_outline,
                  color: accentColor,
                  size: 30,
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
                      maxLines: 1,
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
              IconButton(
                onPressed: () => _deleteVideo(video),
                icon: const Icon(Icons.delete_outline, color: AppColors.error),
              ),
            ],
          ),
          if (video.remarks != null && video.remarks!.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.spacingS),
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
        ],
      ),
    );
  }
}
