import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:badminton/widgets/common/success_snackbar.dart';

void main() {
  group('SuccessSnackbar Tests', () {
    testWidgets('shows success snackbar', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    SuccessSnackbar.show(
                      context,
                      'Operation successful',
                    );
                  },
                  child: const Text('Show Snackbar'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Snackbar'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Operation successful'), findsOneWidget);
    });

    testWidgets('shows info snackbar', (WidgetTester tester) async {
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

    testWidgets('shows error snackbar', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    SuccessSnackbar.showError(
                      context,
                      'Error occurred',
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

      expect(find.text('Error occurred'), findsOneWidget);
    });
  });
}
