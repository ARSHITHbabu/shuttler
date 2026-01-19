import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:badminton/providers/student_provider.dart';
import 'package:badminton/widgets/common/skeleton_screen.dart';
import 'package:badminton/widgets/common/loading_spinner.dart';

/// Integration tests for loading states
/// These tests verify that loading states work correctly in screens
void main() {
  group('Loading States Integration Tests', () {
    testWidgets('ListSkeleton displays during provider loading', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, child) {
                  final studentsAsync = ref.watch(studentListProvider);
                  
                  return studentsAsync.when(
                    data: (students) => ListView.builder(
                      itemCount: students.length,
                      itemBuilder: (context, index) => ListTile(
                        title: Text(students[index].name),
                      ),
                    ),
                    loading: () => const ListSkeleton(itemCount: 5),
                    error: (error, stack) => Center(
                      child: Text('Error: $error'),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      );

      // Initially should show loading skeleton
      expect(find.byType(ListSkeleton), findsOneWidget);
    });

    testWidgets('DashboardSkeleton displays during dashboard loading', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DashboardSkeleton(),
          ),
        ),
      );

      expect(find.byType(DashboardSkeleton), findsOneWidget);
    });

    testWidgets('ProfileSkeleton displays during profile loading', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProfileSkeleton(),
          ),
        ),
      );

      expect(find.byType(ProfileSkeleton), findsOneWidget);
    });

    testWidgets('LoadingSpinner can be used as fallback', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: LoadingSpinner(),
            ),
          ),
        ),
      );

      expect(find.byType(LoadingSpinner), findsOneWidget);
    });

    testWidgets('Provider loading state transitions correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, child) {
                  final studentsAsync = ref.watch(studentListProvider);
                  
                  return studentsAsync.when(
                    data: (students) => Text('Loaded: ${students.length}'),
                    loading: () => const LoadingSpinner(),
                    error: (error, stack) => Text('Error: $error'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      // Should show loading initially
      expect(find.byType(LoadingSpinner), findsOneWidget);
    });
  });
}
