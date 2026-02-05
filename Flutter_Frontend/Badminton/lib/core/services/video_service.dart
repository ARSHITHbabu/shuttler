import 'package:dio/dio.dart' show ProgressCallback, Response;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import '../constants/api_endpoints.dart';
import 'api_service.dart';
import '../../models/video_resource.dart';

/// Service for video resource API operations
class VideoService {
  final ApiService _apiService;

  VideoService(this._apiService);

  Future<List<VideoResource>> getVideos({int? studentId, int? batchId, int? sessionId}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (studentId != null) queryParams['student_id'] = studentId;
      if (batchId != null) queryParams['batch_id'] = batchId;
      if (sessionId != null) queryParams['session_id'] = sessionId;

      final response = await _apiService.get(
        ApiEndpoints.videoResources,
        queryParameters: queryParams,
      );

      if (response.data is List) {
        return (response.data as List)
            .map((json) => VideoResource.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch videos: ${_apiService.getErrorMessage(e)}');
    }
  }

  /// Get all videos for a specific student (Legacy wrapper)
  Future<List<VideoResource>> getVideosForStudent(int studentId) async {
    return getVideos(studentId: studentId);
  }

  /// Get all videos (for owner view)
  Future<List<VideoResource>> getAllVideos() async {
    try {
      final response = await _apiService.get(ApiEndpoints.videoResources);

      if (response.data is List) {
        return (response.data as List)
            .map((json) => VideoResource.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch videos: ${_apiService.getErrorMessage(e)}');
    }
  }

  /// Get video by ID
  Future<VideoResource> getVideoById(int id) async {
    try {
      final response = await _apiService.get(ApiEndpoints.videoResourceById(id));
      return VideoResource.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to fetch video: ${_apiService.getErrorMessage(e)}');
    }
  }

  /// Upload a video for students/batches/everyone
  /// Supports both file paths (mobile/desktop) and XFile (web)
  Future<VideoResource> uploadVideo({
    required String audienceType,
    required List<int> targetIds,
    required String videoFilePath,
    String? title,
    String? remarks,
    int? uploadedBy,
    ProgressCallback? onProgress,
  }) async {
    try {
      final additionalData = <String, dynamic>{
        'audience_type': audienceType,
        'target_ids': targetIds.join(','),
        if (title != null) 'title': title,
        if (remarks != null) 'remarks': remarks,
        if (uploadedBy != null) 'uploaded_by': uploadedBy,
      };

      final response = await _apiService.uploadFile(
        '${ApiEndpoints.videoResources}upload',
        videoFilePath,
        fieldName: 'video',
        additionalData: additionalData,
        onSendProgress: onProgress,
      );

      return VideoResource.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to upload video: ${_apiService.getErrorMessage(e)}');
    }
  }

  /// Upload a video from XFile (supports web and mobile)
  Future<VideoResource> uploadVideoFromFile({
    required String audienceType,
    required List<int> targetIds,
    required XFile videoFile,
    String? title,
    String? remarks,
    int? uploadedBy,
    ProgressCallback? onProgress,
  }) async {
    try {
      final additionalData = <String, dynamic>{
        'audience_type': audienceType,
        'target_ids': targetIds.join(','),
        if (title != null) 'title': title,
        if (remarks != null) 'remarks': remarks,
        if (uploadedBy != null) 'uploaded_by': uploadedBy,
      };

      Response response;

      if (kIsWeb) {
        // On web, read bytes from XFile
        final bytes = await videoFile.readAsBytes();
        response = await _apiService.uploadFileBytes(
          '${ApiEndpoints.videoResources}upload',
          bytes,
          videoFile.name,
          fieldName: 'video',
          additionalData: additionalData,
          onSendProgress: onProgress,
        );
      } else {
        // On mobile/desktop, use file path
        response = await _apiService.uploadFile(
          '${ApiEndpoints.videoResources}upload',
          videoFile.path,
          fieldName: 'video',
          additionalData: additionalData,
          onSendProgress: onProgress,
        );
      }

      return VideoResource.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to upload video: ${_apiService.getErrorMessage(e)}');
    }
  }

  /// Upload multiple videos with flexible targeting
  Future<List<VideoResource>> uploadMultipleVideos({
    required String audienceType,
    required List<int> targetIds,
    required List<String> videoPaths,
    String? remarks,
    int? uploadedBy,
    void Function(int completed, int total)? onVideoProgress,
  }) async {
    final List<VideoResource> uploadedVideos = [];

    for (int i = 0; i < videoPaths.length; i++) {
      final video = await uploadVideo(
        audienceType: audienceType,
        targetIds: targetIds,
        videoFilePath: videoPaths[i],
        remarks: remarks,
        uploadedBy: uploadedBy,
      );
      uploadedVideos.add(video);
      onVideoProgress?.call(i + 1, videoPaths.length);
    }

    return uploadedVideos;
  }

  /// Delete a video resource
  Future<void> deleteVideo(int id) async {
    try {
      await _apiService.delete(ApiEndpoints.videoResourceById(id));
    } catch (e) {
      throw Exception('Failed to delete video: ${_apiService.getErrorMessage(e)}');
    }
  }

  /// Get full video URL with base URL
  String getFullVideoUrl(String relativeUrl) {
    if (relativeUrl.startsWith('http')) {
      return relativeUrl;
    }
    return '${ApiEndpoints.baseUrl}$relativeUrl';
  }
}
