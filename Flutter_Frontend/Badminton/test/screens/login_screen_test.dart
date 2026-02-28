import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:badminton/screens/auth/login_screen.dart';
import 'package:badminton/providers/auth_provider.dart';
import 'package:badminton/widgets/common/custom_text_field.dart';
import 'package:badminton/widgets/common/neumorphic_button.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthNotifier extends _$Auth with Mock implements Auth {}

void main() {
  testWidgets('LoginScreen UI elements should be present', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );

    // Verify presence of title and subtitle
    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Sign in to your account'), findsOneWidget);

    // Verify presence of email and password fields
    expect(find.byType(CustomTextField), findsNWidgets(2));
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);

    // Verify presence of Sign In button
    expect(find.byType(NeumorphicButton), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);

    // Verify presence of Sign Up link
    expect(find.text('Don\'t have an account? '), findsOneWidget);
    expect(find.text('Sign Up'), findsOneWidget);
  });

  testWidgets('LoginScreen form validation', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );

    // Tap the Sign In button without entering data
    await tester.tap(find.text('Sign In'));
    await tester.pump();

    // Verify validation error messages
    expect(find.text('Email is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
    
    // Enter invalid email
    await tester.enterText(find.byType(CustomTextField).first, 'invalid-email');
    await tester.tap(find.text('Sign In'));
    await tester.pump();
    
    expect(find.text('Enter a valid email address'), findsOneWidget);
  });
}
