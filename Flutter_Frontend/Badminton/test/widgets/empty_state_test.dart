import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:badminton/widgets/common/error_widget.dart';

void main() {
  group('EmptyState Widget Tests', () {
    testWidgets('displays noStudents variant correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState.noStudents(),
          ),
        ),
      );

      expect(find.text('No Students Yet'), findsOneWidget);
      expect(find.text('Start by adding your first student to the academy.'), findsOneWidget);
    });

    testWidgets('displays noBatches variant correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState.noBatches(),
          ),
        ),
      );

      expect(find.text('No Batches Created'), findsOneWidget);
    });

    testWidgets('displays noFees variant correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState.noFees(),
          ),
        ),
      );

      expect(find.text('No Fee Records'), findsOneWidget);
    });

    testWidgets('displays custom empty state correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.info,
              title: 'Custom Title',
              message: 'Custom message',
            ),
          ),
        ),
      );

      expect(find.text('Custom Title'), findsOneWidget);
      expect(find.text('Custom message'), findsOneWidget);
    });

    testWidgets('shows action button when provided', (WidgetTester tester) async {
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
