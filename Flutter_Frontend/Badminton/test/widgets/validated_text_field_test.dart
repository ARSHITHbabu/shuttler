import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:badminton/widgets/common/validated_text_field.dart';

void main() {
  group('ValidatedTextField Widget Tests', () {
    testWidgets('displays label and hint correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ValidatedTextField(
              label: 'Test Label',
              hint: 'Test hint',
            ),
          ),
        ),
      );

      expect(find.text('Test Label'), findsOneWidget);
    });

    testWidgets('shows validation error when validator fails', (WidgetTester tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ValidatedTextField(
              controller: controller,
              label: 'Email',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Email is required';
                }
                return null;
              },
            ),
          ),
        ),
      );

      // Focus and unfocus to trigger validation
      await tester.enterText(find.byType(TextField), '');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(find.text('Email is required'), findsOneWidget);
    });

    testWidgets('does not show error before field is touched', (WidgetTester tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ValidatedTextField(
              controller: controller,
              label: 'Email',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Email is required';
                }
                return null;
              },
            ),
          ),
        ),
      );

      // Error should not show before field is touched
      expect(find.text('Email is required'), findsNothing);
    });

    testWidgets('clears error when valid input is entered', (WidgetTester tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ValidatedTextField(
              controller: controller,
              label: 'Email',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Email is required';
                }
                if (!value.contains('@')) {
                  return 'Invalid email';
                }
                return null;
              },
            ),
          ),
        ),
      );

      // Enter invalid input and submit
      await tester.enterText(find.byType(TextField), 'invalid');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(find.text('Invalid email'), findsOneWidget);

      // Enter valid input
      await tester.enterText(find.byType(TextField), 'test@example.com');
      await tester.pump();

      expect(find.text('Invalid email'), findsNothing);
    });

    testWidgets('respects maxLength when provided', (WidgetTester tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ValidatedTextField(
              controller: controller,
              label: 'Phone',
              maxLength: 10,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), '12345678901');
      await tester.pump();

      expect(controller.text.length, lessThanOrEqualTo(10));
    });

    testWidgets('shows errorText when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ValidatedTextField(
              label: 'Test',
              errorText: 'Custom error message',
            ),
          ),
        ),
      );

      expect(find.text('Custom error message'), findsOneWidget);
    });

    testWidgets('handles obscureText for password fields', (WidgetTester tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ValidatedTextField(
              controller: controller,
              label: 'Password',
              obscureText: true,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'password123');
      await tester.pump();

      // Text should be obscured
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.obscureText, isTrue);
    });
  });
}
