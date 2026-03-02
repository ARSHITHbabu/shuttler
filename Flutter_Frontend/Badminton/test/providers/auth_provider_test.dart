import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:badminton/providers/auth_provider.dart';
import 'package:badminton/providers/service_providers.dart';
import 'package:badminton/core/services/auth_service.dart';
import 'package:badminton/core/services/storage_service.dart';

class MockAuthService extends Mock implements AuthService {}
class MockStorageService extends Mock implements StorageService {}

void main() {
  late MockAuthService mockAuthService;
  late MockStorageService mockStorageService;

  setUp(() {
    mockAuthService = MockAuthService();
    mockStorageService = MockStorageService();
  });

  ProviderContainer createContainer() {
    final container = ProviderContainer(
      overrides: [
        authServiceProvider.overrideWithValue(mockAuthService),
        storageServiceProvider.overrideWithValue(mockStorageService),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('AuthProvider Tests', () {
    test('initial state should be Unauthenticated if not logged in', () async {
      // Setup
      when(() => mockStorageService.isInitialized).thenReturn(true);
      when(() => mockAuthService.isLoggedIn()).thenReturn(false);

      final container = createContainer();
      
      // Execute
      final authState = await container.read(authProvider.future);

      // Verify
      expect(authState, isA<Unauthenticated>());
    });

    test('initial state should be Authenticated if logged in', () async {
      // Setup
      when(() => mockStorageService.isInitialized).thenReturn(true);
      when(() => mockAuthService.isLoggedIn()).thenReturn(true);
      when(() => mockAuthService.getCurrentUserType()).thenReturn('owner');
      when(() => mockAuthService.getCurrentUserId()).thenReturn(1);
      when(() => mockAuthService.getCurrentUserName()).thenReturn('Owner Name');
      when(() => mockAuthService.getCurrentUserEmail()).thenReturn('owner@test.com');
      when(() => mockAuthService.getUserRole()).thenReturn('owner');
      when(() => mockAuthService.getMustChangePassword()).thenReturn(false);

      final container = createContainer();
      
      // Execute
      final authState = await container.read(authProvider.future);

      // Verify
      expect(authState, isA<Authenticated>());
      final authenticated = authState as Authenticated;
      expect(authenticated.userId, 1);
      expect(authenticated.userType, 'owner');
    });

    test('login success should update state to Authenticated', () async {
      // Setup
      when(() => mockStorageService.isInitialized).thenReturn(true);
      when(() => mockAuthService.isLoggedIn()).thenReturn(false);
      
      final container = createContainer();
      
      final loginResult = {
        'success': true,
        'userType': 'owner',
        'user': {
          'id': 1,
          'name': 'Owner Name',
          'email': 'owner@test.com',
          'role': 'owner',
          'must_change_password': false,
        }
      };

      when(() => mockAuthService.login(
        email: 'owner@test.com',
        password: 'password123',
        rememberMe: false,
      )).thenAnswer((_) async => loginResult);

      // Execute
      await container.read(authProvider.notifier).login(
        email: 'owner@test.com',
        password: 'password123',
      );

      // Verify
      final authState = container.read(authProvider).value;
      expect(authState, isA<Authenticated>());
      expect((authState as Authenticated).userId, 1);
    });

    test('logout should update state to Unauthenticated', () async {
      // Setup
      when(() => mockStorageService.isInitialized).thenReturn(true);
      when(() => mockAuthService.isLoggedIn()).thenReturn(true);
      when(() => mockAuthService.getCurrentUserType()).thenReturn('owner');
      when(() => mockAuthService.getCurrentUserId()).thenReturn(1);
      when(() => mockAuthService.getCurrentUserName()).thenReturn('Owner');
      when(() => mockAuthService.getCurrentUserEmail()).thenReturn('owner@test.com');
      when(() => mockAuthService.getUserRole()).thenReturn('owner');
      when(() => mockAuthService.getMustChangePassword()).thenReturn(false);
      
      when(() => mockAuthService.logout()).thenAnswer((_) async => {});

      final container = createContainer();
      
      // Execute
      await container.read(authProvider.notifier).logout();

      // Verify
      final authState = container.read(authProvider).value;
      expect(authState, isA<Unauthenticated>());
    });
  });
}
