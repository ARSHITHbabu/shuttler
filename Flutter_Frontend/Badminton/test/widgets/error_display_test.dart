import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:badminton/widgets/common/error_widget.dart';

void main() {
  group('ErrorDisplay Widget Tests', () {
    testWidgets('displays error message correctly', (WidgetTester tester) async {
      const errorMessage = 'Something went wrong';
      
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ErrorDisplay(message: errorMessage),
          ),
        ),
      );

      expect(find.text(errorMessage), findsOneWidget);
    });

    testWidgets('shows retry button when onRetry is provided', (WidgetTester tester) async {
      bool retryCalled = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorDisplay(
              message: 'Error occurred',
              onRetry: () {
                retryCalled = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Retry'), findsOneWidget);
      
      await tester.tap(find.text('Retry'));
      await tester.pump();
      
      expect(retryCalled, isTrue);
    });

    testWidgets('does not show retry button when onRetry is null', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ErrorDisplay(message: 'Error occurred'),
          ),
        ),
      );

      expect(find.text('Retry'), findsNothing);
    });
  });
}
