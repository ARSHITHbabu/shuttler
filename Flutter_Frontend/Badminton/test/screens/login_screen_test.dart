import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:badminton/screens/auth/login_screen.dart';
import 'package:badminton/providers/auth_provider.dart';
import 'package:badminton/widgets/common/custom_text_field.dart';
import 'package:badminton/widgets/common/neumorphic_button.dart';
import 'package:mocktail/mocktail.dart';
import 'package:badminton/core/services/auth_service.dart';
import 'package:badminton/core/services/storage_service.dart';
import 'package:badminton/core/services/api_service.dart';
import 'package:badminton/providers/service_providers.dart';

class MockAuthService extends Mock implements AuthService {}
class MockStorageService extends Mock implements StorageService {}
class MockApiService extends Mock implements ApiService {}

void main() {
  late MockAuthService mockAuthService;
  late MockStorageService mockStorageService;
  late MockApiService mockApiService;

  setUp(() {
    mockAuthService = MockAuthService();
    mockStorageService = MockStorageService();
    mockApiService = MockApiService();
    
    when(() => mockStorageService.isInitialized).thenReturn(true);
    when(() => mockAuthService.isLoggedIn()).thenReturn(false);
  });

  testWidgets('LoginScreen UI elements should be present', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authServiceProvider.overrideWithValue(mockAuthService),
          storageServiceProvider.overrideWithValue(mockStorageService),
        ],
        child: const MaterialApp(
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
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authServiceProvider.overrideWithValue(mockAuthService),
          storageServiceProvider.overrideWithValue(mockStorageService),
        ],
        child: const MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );

    // Tap the Sign In button without entering data
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();

    // Verify validation error messages
    expect(find.text('Email is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
    
    // Enter invalid email
    await tester.enterText(find.byType(CustomTextField).first, 'invalid-email');
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();
    
    expect(find.text('Please enter a valid email address'), findsOneWidget);
  });
}
