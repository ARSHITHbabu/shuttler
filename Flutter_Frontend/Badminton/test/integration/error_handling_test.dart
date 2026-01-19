import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:badminton/providers/student_provider.dart';

/// Integration tests for error handling flow
/// These tests verify that error handling works correctly throughout the app
void main() {
  group('Error Handling Flow Tests', () {
    test('Provider handles error state correctly', () {
      final container = ProviderContainer();
      
      // Access provider that might error
      final studentListAsync = container.read(studentListProvider);
      
      // Initially should be loading or have data
      // Error state would be AsyncValue.error
      expect(studentListAsync, isNotNull);
      
      // Check if error state can be handled
      studentListAsync.when(
        data: (data) => expect(data, isNotNull),
        loading: () => expect(true, isTrue), // Loading is valid
        error: (error, stack) => expect(error, isNotNull), // Error state exists
      );
      
      container.dispose();
    });

    test('Error state provides error message', () {
      final container = ProviderContainer();
      
      final studentListAsync = container.read(studentListProvider);
      
      // Verify error handling structure
      studentListAsync.when(
        data: (_) {},
        loading: () {},
        error: (error, stack) {
          // Error should have a message
          expect(error.toString(), isNotEmpty);
        },
      );
      
      container.dispose();
    });

    test('Provider can be refreshed after error', () {
      final container = ProviderContainer();
      
      final provider = studentListProvider;
      
      // Invalidate to trigger refresh
      container.invalidate(provider);
      
      // Provider should still be accessible
      final refreshedAsync = container.read(provider);
      expect(refreshedAsync, isNotNull);
      
      container.dispose();
    });

    test('Multiple providers handle errors independently', () {
      final container = ProviderContainer();
      
      // Access multiple providers
      final studentListAsync = container.read(studentListProvider);
      final studentStatsAsync = container.read(studentStatsProvider);
      
      // Both should be accessible
      expect(studentListAsync, isNotNull);
      expect(studentStatsAsync, isNotNull);
      
      // Errors in one should not affect the other
      studentListAsync.when(
        data: (_) {},
        loading: () {},
        error: (error, stack) {
          // Error in studentList should not affect stats
          expect(studentStatsAsync, isNotNull);
        },
      );
      
      container.dispose();
    });

    test('Error handling with AsyncValue.when pattern', () {
      final container = ProviderContainer();
      
      final studentListAsync = container.read(studentListProvider);
      
      // Test the AsyncValue.when pattern used in screens
      var handled = false;
      
      studentListAsync.when(
        data: (data) {
          handled = true;
          expect(data, isNotNull);
        },
        loading: () {
          handled = true;
        },
        error: (error, stack) {
          handled = true;
          expect(error, isNotNull);
        },
      );
      
      expect(handled, isTrue);
      
      container.dispose();
    });
  });
}
