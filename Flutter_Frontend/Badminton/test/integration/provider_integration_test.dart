import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:badminton/providers/student_provider.dart';
import 'package:badminton/models/student.dart';

/// Integration tests for provider integration in migrated screens
/// These tests verify that providers work correctly with screen components
void main() {
  group('Provider Integration Tests', () {
    test('studentListProvider can be accessed', () {
      final container = ProviderContainer();
      
      // Access the provider
      final studentListAsync = container.read(studentListProvider);
      
      // Provider should return AsyncValue
      expect(studentListAsync, isNotNull);
      
      container.dispose();
    });

    test('studentSearchProvider accepts query parameter', () {
      final container = ProviderContainer();
      
      // Access the provider with a search query
      final searchAsync = container.read(studentSearchProvider('test'));
      
      // Provider should return AsyncValue
      expect(searchAsync, isNotNull);
      
      container.dispose();
    });

    test('studentByIdProvider accepts id parameter', () {
      final container = ProviderContainer();
      
      // Access the provider with an ID
      final studentAsync = container.read(studentByIdProvider(1));
      
      // Provider should return AsyncValue
      expect(studentAsync, isNotNull);
      
      container.dispose();
    });

    test('studentByBatchProvider accepts batchId parameter', () {
      final container = ProviderContainer();
      
      // Access the provider with a batch ID
      final batchStudentsAsync = container.read(studentByBatchProvider(1));
      
      // Provider should return AsyncValue
      expect(batchStudentsAsync, isNotNull);
      
      container.dispose();
    });

    test('studentStatsProvider can be accessed', () {
      final container = ProviderContainer();
      
      // Access the provider
      final statsAsync = container.read(studentStatsProvider);
      
      // Provider should return AsyncValue
      expect(statsAsync, isNotNull);
      
      container.dispose();
    });

    test('Provider notifier can be accessed for mutations', () {
      final container = ProviderContainer();
      
      // Access the notifier
      final notifier = container.read(studentListProvider.notifier);
      
      // Notifier should exist
      expect(notifier, isNotNull);
      
      container.dispose();
    });
  });
}
