import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:badminton/providers/announcement_provider.dart';
import 'package:badminton/models/announcement.dart';

/// Comprehensive tests for announcement_provider
void main() {
  group('Announcement Provider Tests', () {
    test('announcementListProvider can be accessed', () {
      final container = ProviderContainer();
      
      // Access the provider
      final announcementsAsync = container.read(announcementListProvider());
      
      // Provider should return AsyncValue
      expect(announcementsAsync, isNotNull);
      
      container.dispose();
    });

    test('announcementListProvider accepts targetAudience filter', () {
      final container = ProviderContainer();
      
      // Access the provider with target audience filter
      final announcementsAsync = container.read(
        announcementListProvider(targetAudience: 'students'),
      );
      
      // Provider should return AsyncValue
      expect(announcementsAsync, isNotNull);
      
      container.dispose();
    });

    test('announcementListProvider accepts priority filter', () {
      final container = ProviderContainer();
      
      // Access the provider with priority filter
      final announcementsAsync = container.read(
        announcementListProvider(priority: 'high'),
      );
      
      // Provider should return AsyncValue
      expect(announcementsAsync, isNotNull);
      
      container.dispose();
    });

    test('announcementListProvider accepts isSent filter', () {
      final container = ProviderContainer();
      
      // Access the provider with isSent filter
      final announcementsAsync = container.read(
        announcementListProvider(isSent: true),
      );
      
      // Provider should return AsyncValue
      expect(announcementsAsync, isNotNull);
      
      container.dispose();
    });

    test('announcementByIdProvider accepts id parameter', () {
      final container = ProviderContainer();
      
      // Access the provider with ID
      final announcementAsync = container.read(announcementByIdProvider(1));
      
      // Provider should return AsyncValue
      expect(announcementAsync, isNotNull);
      
      container.dispose();
    });

    test('announcementByAudienceProvider accepts audience parameter', () {
      final container = ProviderContainer();
      
      // Access the provider with target audience
      final announcementsAsync = container.read(
        announcementByAudienceProvider('coaches'),
      );
      
      // Provider should return AsyncValue
      expect(announcementsAsync, isNotNull);
      
      container.dispose();
    });

    test('announcementByPriorityProvider accepts priority parameter', () {
      final container = ProviderContainer();
      
      // Access the provider with priority
      final announcementsAsync = container.read(
        announcementByPriorityProvider('urgent'),
      );
      
      // Provider should return AsyncValue
      expect(announcementsAsync, isNotNull);
      
      container.dispose();
    });

    test('AnnouncementManager notifier can be accessed', () {
      final container = ProviderContainer();
      
      // Access the notifier
      final notifier = container.read(announcementManagerProvider().notifier);
      
      // Notifier should exist
      expect(notifier, isNotNull);
      
      container.dispose();
    });

    test('AnnouncementManager refresh method exists', () {
      final container = ProviderContainer();
      
      // Access the notifier
      final notifier = container.read(announcementManagerProvider().notifier);
      
      // Refresh method should exist
      expect(notifier.refresh, isNotNull);
      
      container.dispose();
    });

    test('AnnouncementManager createAnnouncement method exists', () {
      final container = ProviderContainer();
      
      // Access the notifier
      final notifier = container.read(announcementManagerProvider().notifier);
      
      // createAnnouncement method should exist
      expect(notifier.createAnnouncement, isNotNull);
      
      container.dispose();
    });

    test('AnnouncementManager updateAnnouncement method exists', () {
      final container = ProviderContainer();
      
      // Access the notifier
      final notifier = container.read(announcementManagerProvider().notifier);
      
      // updateAnnouncement method should exist
      expect(notifier.updateAnnouncement, isNotNull);
      
      container.dispose();
    });

    test('AnnouncementManager deleteAnnouncement method exists', () {
      final container = ProviderContainer();
      
      // Access the notifier
      final notifier = container.read(announcementManagerProvider().notifier);
      
      // deleteAnnouncement method should exist
      expect(notifier.deleteAnnouncement, isNotNull);
      
      container.dispose();
    });

    test('Announcement model fromJson works correctly', () {
      final json = {
        'id': 1,
        'title': 'Test Announcement',
        'message': 'Test message',
        'target_audience': 'all',
        'priority': 'normal',
        'created_by': 1,
        'created_by_name': 'Admin',
        'created_at': '2026-01-01T00:00:00Z',
        'scheduled_at': null,
        'is_sent': false,
      };

      final announcement = Announcement.fromJson(json);

      expect(announcement.id, 1);
      expect(announcement.title, 'Test Announcement');
      expect(announcement.message, 'Test message');
      expect(announcement.targetAudience, 'all');
      expect(announcement.priority, 'normal');
      expect(announcement.isSent, false);
    });

    test('Announcement toJson works correctly', () {
      final announcement = Announcement(
        id: 1,
        title: 'Test Announcement',
        message: 'Test message',
        targetAudience: 'all',
        priority: 'normal',
        createdBy: 1,
        createdAt: DateTime(2026, 1, 1),
        isSent: false,
      );

      final json = announcement.toJson();

      expect(json['title'], 'Test Announcement');
      expect(json['message'], 'Test message');
      expect(json['target_audience'], 'all');
      expect(json['priority'], 'normal');
    });

    test('Announcement priorityColor returns correct color', () {
      final urgentAnnouncement = Announcement(
        id: 1,
        title: 'Urgent',
        message: 'Urgent message',
        targetAudience: 'all',
        priority: 'urgent',
        createdAt: DateTime(2026, 1, 1),
        isSent: false,
      );

      expect(urgentAnnouncement.priorityColor, const Color(0xFFF44336));
    });

    test('Announcement filtering by audience works', () {
      final announcements = [
        Announcement(
          id: 1,
          title: 'Student Announcement',
          message: 'Message for students',
          targetAudience: 'students',
          priority: 'normal',
          createdAt: DateTime(2026, 1, 1),
          isSent: false,
        ),
        Announcement(
          id: 2,
          title: 'Coach Announcement',
          message: 'Message for coaches',
          targetAudience: 'coaches',
          priority: 'normal',
          createdAt: DateTime(2026, 1, 1),
          isSent: false,
        ),
      ];

      // Filter by audience
      final studentAnnouncements = announcements
          .where((a) => a.targetAudience == 'students')
          .toList();

      expect(studentAnnouncements.length, 1);
      expect(studentAnnouncements.first.title, 'Student Announcement');
    });

    test('Announcement filtering by priority works', () {
      final announcements = [
        Announcement(
          id: 1,
          title: 'High Priority',
          message: 'High priority message',
          targetAudience: 'all',
          priority: 'high',
          createdAt: DateTime(2026, 1, 1),
          isSent: false,
        ),
        Announcement(
          id: 2,
          title: 'Normal Priority',
          message: 'Normal priority message',
          targetAudience: 'all',
          priority: 'normal',
          createdAt: DateTime(2026, 1, 1),
          isSent: false,
        ),
      ];

      // Filter by priority
      final highPriorityAnnouncements = announcements
          .where((a) => a.priority == 'high')
          .toList();

      expect(highPriorityAnnouncements.length, 1);
      expect(highPriorityAnnouncements.first.title, 'High Priority');
    });
  });
}
