import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:badminton/widgets/common/success_snackbar.dart';
import 'package:badminton/widgets/common/confirmation_dialog.dart';

/// Integration tests for success feedback
/// These tests verify that success feedback mechanisms work correctly
void main() {
  group('Success Feedback Integration Tests', () {
    testWidgets('SuccessSnackbar.show displays success message', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    SuccessSnackbar.show(
                      context,
                      'Operation completed successfully',
                    );
                  },
                  child: const Text('Show Success'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Success'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Operation completed successfully'), findsOneWidget);
    });

    testWidgets('SuccessSnackbar.showInfo displays info message', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    SuccessSnackbar.showInfo(
                      context,
                      'Information message',
                    );
                  },
                  child: const Text('Show Info'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Info'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Information message'), findsOneWidget);
    });

    testWidgets('SuccessSnackbar.showError displays error message', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    SuccessSnackbar.showError(
                      context,
                      'An error occurred',
                    );
                  },
                  child: const Text('Show Error'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Error'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('An error occurred'), findsOneWidget);
    });

    testWidgets('ConfirmationDialog returns true on confirm', (WidgetTester tester) async {
      bool? confirmed;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    confirmed = await ConfirmationDialog.show(
                      context,
                      'Test Title',
                      'Test message',
                      onConfirm: () {},
                    );
                  },
                  child: const Text('Show Dialog'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      expect(confirmed, isTrue);
    });

    testWidgets('ConfirmationDialog returns false on cancel', (WidgetTester tester) async {
      bool? confirmed;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    confirmed = await ConfirmationDialog.show(
                      context,
                      'Test Title',
                      'Test message',
                      onConfirm: () {},
                    );
                  },
                  child: const Text('Show Dialog'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(confirmed, isFalse);
    });
  });
}
