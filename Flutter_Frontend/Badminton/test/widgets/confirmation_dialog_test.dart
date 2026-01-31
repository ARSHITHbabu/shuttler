import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:badminton/widgets/common/confirmation_dialog.dart';

void main() {
  group('ConfirmationDialog Widget Tests', () {
    testWidgets('displays title and message correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => ConfirmationDialog(
                        title: 'Test Title',
                        message: 'Test message',
                        onConfirm: () {},
                      ),
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

      expect(find.text('Test Title'), findsOneWidget);
      expect(find.text('Test message'), findsOneWidget);
    });

    testWidgets('shows confirm and cancel buttons', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => ConfirmationDialog(
                        title: 'Test',
                        message: 'Test message',
                        onConfirm: () {},
                      ),
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

      expect(find.text('Confirm'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('calls onConfirm when confirm button is tapped', (WidgetTester tester) async {
      bool confirmCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => ConfirmationDialog(
                        title: 'Test',
                        message: 'Test message',
                        onConfirm: () {
                          confirmCalled = true;
                          Navigator.of(context).pop();
                        },
                      ),
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

      expect(confirmCalled, isTrue);
    });

    testWidgets('calls onCancel when cancel button is tapped', (WidgetTester tester) async {
      bool cancelCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => ConfirmationDialog(
                        title: 'Test',
                        message: 'Test message',
                        onConfirm: () {},
                        onCancel: () {
                          cancelCalled = true;
                          Navigator.of(context).pop();
                        },
                      ),
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

      expect(cancelCalled, isTrue);
    });

    testWidgets('showDelete static method works correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    await ConfirmationDialog.showDelete(
                      context,
                      'Student',
                    );
                  },
                  child: const Text('Show Delete Dialog'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Delete Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Delete Student?'), findsOneWidget);
      expect(find.text('This action cannot be undone. Are you sure you want to delete this item?'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });

    testWidgets('show static method works correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    await ConfirmationDialog.show(
                      context,
                      'Custom Title',
                      'Custom message',
                      confirmText: 'Yes',
                      cancelText: 'No',
                    );
                  },
                  child: const Text('Show Custom Dialog'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Custom Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Custom Title'), findsOneWidget);
      expect(find.text('Custom message'), findsOneWidget);
      expect(find.text('Yes'), findsOneWidget);
      expect(find.text('No'), findsOneWidget);
    });
  });
}
