import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:badminton/widgets/common/error_widget.dart';
import 'package:badminton/providers/student_provider.dart';

/// Integration tests for empty states
/// These tests verify that empty states work correctly in screens
void main() {
  group('Empty States Integration Tests', () {
    testWidgets('EmptyState.noStudents displays when student list is empty', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, child) {
                  final studentsAsync = ref.watch(studentListProvider);
                  
                  return studentsAsync.when(
                    data: (students) {
                      if (students.isEmpty) {
                        return EmptyState.noStudents();
                      }
                      return ListView.builder(
                        itemCount: students.length,
                        itemBuilder: (context, index) => ListTile(
                          title: Text(students[index].name),
                        ),
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (error, stack) => ErrorDisplay(message: error.toString()),
                  );
                },
              ),
            ),
          ),
        ),
      );

      // Should be able to find EmptyState widget
      expect(find.byType(EmptyState), findsWidgets);
    });

    testWidgets('EmptyState.noBatches displays correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState.noBatches(),
          ),
        ),
      );

      expect(find.text('No Batches Created'), findsOneWidget);
      expect(find.text('Create your first batch to organize training sessions.'), findsOneWidget);
    });

    testWidgets('EmptyState.noFees displays correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState.noFees(),
          ),
        ),
      );

      expect(find.text('No Fee Records'), findsOneWidget);
    });

    testWidgets('EmptyState.noEvents displays correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState.noEvents(),
          ),
        ),
      );

      expect(find.text('No Events'), findsOneWidget);
    });

    testWidgets('EmptyState.noAnnouncements displays correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState.noAnnouncements(),
          ),
        ),
      );

      expect(find.text('No Announcements'), findsOneWidget);
    });

    testWidgets('EmptyState with action button works', (WidgetTester tester) async {
      bool actionCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState.noStudents(
              onAdd: () {
                actionCalled = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Add Student'), findsOneWidget);
      
      await tester.tap(find.text('Add Student'));
      await tester.pump();
      
      expect(actionCalled, isTrue);
    });
  });
}
