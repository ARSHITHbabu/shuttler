import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/announcement.dart';
import 'service_providers.dart';
import 'calendar_provider.dart';

part 'announcement_provider.g.dart';

/// Provider for announcement list
@riverpod
Future<List<Announcement>> announcementList(
  AnnouncementListRef ref, {
  String? targetAudience,
  String? priority,
  bool? isSent,
}) async {
  final announcementService = ref.watch(announcementServiceProvider);
  return announcementService.getAnnouncements(
    targetAudience: targetAudience,
    priority: priority,
    isSent: isSent,
  );
}

/// Provider for announcement by ID
@riverpod
Future<Announcement> announcementById(AnnouncementByIdRef ref, int id) async {
  final announcementService = ref.watch(announcementServiceProvider);
  return announcementService.getAnnouncementById(id);
}

/// Provider for announcements by target audience
@riverpod
Future<List<Announcement>> announcementByAudience(
  AnnouncementByAudienceRef ref,
  String audience,
) async {
  final announcementService = ref.watch(announcementServiceProvider);
  return announcementService.getAnnouncements(targetAudience: audience);
}

/// Provider for announcements by priority
@riverpod
Future<List<Announcement>> announcementByPriority(
  AnnouncementByPriorityRef ref,
  String priority,
) async {
  final announcementService = ref.watch(announcementServiceProvider);
  return announcementService.getAnnouncements(priority: priority);
}

/// Provider class for announcement CRUD operations
@riverpod
class AnnouncementManager extends _$AnnouncementManager {
  @override
  Future<List<Announcement>> build({
    String? targetAudience,
    String? priority,
    bool? isSent,
  }) async {
    final announcementService = ref.watch(announcementServiceProvider);
    return announcementService.getAnnouncements(
      targetAudience: targetAudience,
      priority: priority,
      isSent: isSent,
    );
  }

  /// Create a new announcement
  Future<void> createAnnouncement(Map<String, dynamic> announcementData) async {
    try {
      final announcementService = ref.read(announcementServiceProvider);
      await announcementService.createAnnouncement(announcementData);
      
      // Invalidate related providers
      final targetAudience = announcementData['target_audience'] as String?;
      final priority = announcementData['priority'] as String?;
      
      if (targetAudience != null) {
        ref.invalidate(announcementByAudienceProvider(targetAudience));
      }
      if (priority != null) {
        ref.invalidate(announcementByPriorityProvider(priority));
      }
      
      // Invalidate calendar providers since announcements can appear on calendar
      if (announcementData.containsKey('scheduled_at')) {
        try {
          final scheduledAt = DateTime.parse(announcementData['scheduled_at'].toString());
          ref.invalidate(yearlyEventsProvider(scheduledAt.year));
        } catch (_) {}
      }
      
      await refresh();
    } catch (e) {
      throw Exception('Failed to create announcement: $e');
    }
  }

  /// Update an announcement
  Future<void> updateAnnouncement(int id, Map<String, dynamic> announcementData) async {
    try {
      final announcementService = ref.read(announcementServiceProvider);
      final existing = await announcementService.getAnnouncementById(id);
      await announcementService.updateAnnouncement(id, announcementData);
      
      // Invalidate related providers
      ref.invalidate(announcementByIdProvider(id));
      ref.invalidate(announcementByAudienceProvider(existing.targetAudience));
      ref.invalidate(announcementByPriorityProvider(existing.priority));
      
      // If audience or priority changed, invalidate those too
      if (announcementData.containsKey('target_audience')) {
        ref.invalidate(announcementByAudienceProvider(announcementData['target_audience'] as String));
      }
      // Invalidate calendar providers
      if (existing.scheduledAt != null) {
        ref.invalidate(yearlyEventsProvider(existing.scheduledAt!.year));
      }
      if (announcementData.containsKey('scheduled_at')) {
        try {
          final scheduledAt = DateTime.parse(announcementData['scheduled_at'].toString());
          ref.invalidate(yearlyEventsProvider(scheduledAt.year));
        } catch (_) {}
      }
      
      await refresh();
    } catch (e) {
      throw Exception('Failed to update announcement: $e');
    }
  }

  /// Delete an announcement
  Future<void> deleteAnnouncement(int id) async {
    try {
      final announcementService = ref.read(announcementServiceProvider);
      final existing = await announcementService.getAnnouncementById(id);
      await announcementService.deleteAnnouncement(id);
      
      // Invalidate related providers
      ref.invalidate(announcementByIdProvider(id));
      ref.invalidate(announcementByAudienceProvider(existing.targetAudience));
      ref.invalidate(announcementByPriorityProvider(existing.priority));
      
      // Invalidate calendar providers
      if (existing.scheduledAt != null) {
        ref.invalidate(yearlyEventsProvider(existing.scheduledAt!.year));
      }
      
      await refresh();
    } catch (e) {
      throw Exception('Failed to delete announcement: $e');
    }
  }

  /// Refresh announcement list
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final announcementService = ref.read(announcementServiceProvider);
      return announcementService.getAnnouncements();
    });
  }
}
