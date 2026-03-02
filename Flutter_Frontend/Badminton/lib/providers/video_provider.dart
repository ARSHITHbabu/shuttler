import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/video_resource.dart';
import 'service_providers.dart';

part 'video_provider.g.dart';

/// Provider for videos by student ID
@riverpod
Future<List<VideoResource>> videosByStudent(
  VideosByStudentRef ref,
  int studentId,
) async {
  final videoService = ref.watch(videoServiceProvider);
  return videoService.getVideosForStudent(studentId);
}

/// Provider for all videos (owner view)
@riverpod
Future<List<VideoResource>> allVideos(AllVideosRef ref) async {
  final videoService = ref.watch(videoServiceProvider);
  return videoService.getAllVideos();
}

/// Provider for video by ID
@riverpod
Future<VideoResource> videoById(VideoByIdRef ref, int id) async {
  final videoService = ref.watch(videoServiceProvider);
  return videoService.getVideoById(id);
}

/// Provider class for video CRUD operations
@riverpod
class VideoManager extends _$VideoManager {
  @override
  Future<List<VideoResource>> build({int? studentId}) async {
    final videoService = ref.watch(videoServiceProvider);
    if (studentId != null) {
      return videoService.getVideosForStudent(studentId);
    }
    return videoService.getAllVideos();
  }

  /// Upload a video for a student
  Future<VideoResource> uploadVideo({
    required int studentId,
    required String videoFilePath,
    String? title,
    String? remarks,
    int? uploadedBy,
    void Function(int sent, int total)? onProgress,
  }) async {
    try {
      final videoService = ref.read(videoServiceProvider);
      final video = await videoService.uploadVideo(
        audienceType: 'student',
        targetIds: [studentId],
        videoFilePath: videoFilePath,
        title: title,
        remarks: remarks,
        uploadedBy: uploadedBy,
        onProgress: onProgress,
      );

      // Invalidate related providers
      ref.invalidate(videosByStudentProvider(studentId));
      ref.invalidate(allVideosProvider);

      await refresh(studentId: studentId);
      return video;
    } catch (e) {
      throw Exception('Failed to upload video: $e');
    }
  }

  /// Upload multiple videos for a student
  Future<List<VideoResource>> uploadMultipleVideos({
    required int studentId,
    required List<String> videoPaths,
    String? remarks,
    int? uploadedBy,
    void Function(int completed, int total)? onVideoProgress,
  }) async {
    try {
      final videoService = ref.read(videoServiceProvider);
      final videos = await videoService.uploadMultipleVideos(
        audienceType: 'student',
        targetIds: [studentId],
        videoPaths: videoPaths,
        remarks: remarks,
        uploadedBy: uploadedBy,
        onVideoProgress: onVideoProgress,
      );

      // Invalidate related providers
      ref.invalidate(videosByStudentProvider(studentId));
      ref.invalidate(allVideosProvider);

      await refresh(studentId: studentId);
      return videos;
    } catch (e) {
      throw Exception('Failed to upload videos: $e');
    }
  }

  /// Delete a video
  Future<void> deleteVideo(int videoId, {int? studentId}) async {
    try {
      final videoService = ref.read(videoServiceProvider);
      await videoService.deleteVideo(videoId);

      // Invalidate related providers
      ref.invalidate(videoByIdProvider(videoId));
      if (studentId != null) {
        ref.invalidate(videosByStudentProvider(studentId));
      }
      ref.invalidate(allVideosProvider);

      await refresh(studentId: studentId);
    } catch (e) {
      throw Exception('Failed to delete video: $e');
    }
  }

  /// Refresh video list
  Future<void> refresh({int? studentId}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final videoService = ref.read(videoServiceProvider);
      if (studentId != null) {
        return videoService.getVideosForStudent(studentId);
      }
      return videoService.getAllVideos();
    });
  }
}
