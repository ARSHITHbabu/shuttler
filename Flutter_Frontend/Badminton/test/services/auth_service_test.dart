import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:badminton/core/services/auth_service.dart';
import 'package:badminton/core/services/api_service.dart';
import 'package:badminton/core/services/storage_service.dart';

class MockApiService extends Mock implements ApiService {}
class MockStorageService extends Mock implements StorageService {}

void main() {
  late AuthService authService;
  late MockApiService mockApiService;
  late MockStorageService mockStorageService;

  setUp(() {
    mockApiService = MockApiService();
    mockStorageService = MockStorageService();
    authService = AuthService(mockApiService, mockStorageService);
  });

  group('AuthService Login Tests', () {
    const email = 'test@example.com';
    const password = 'password123';
    final loginResponseData = {
      'success': true,
      'userType': 'student',
      'access_token': 'test_access_token',
      'refresh_token': 'test_refresh_token',
      'user': {
        'id': 1,
        'email': email,
        'name': 'Test User',
      }
    };

    test('login success should save tokens and user data', () async {
      // Setup
      when(() => mockApiService.post(any(), data: any(named: 'data')))
          .thenAnswer((_) async => Response(
                requestOptions: RequestOptions(path: ''),
                data: loginResponseData,
                statusCode: 200,
              ));

      when(() => mockStorageService.saveAuthToken(any())).thenAnswer((_) async => true);
      when(() => mockStorageService.saveRefreshToken(any())).thenAnswer((_) async => true);
      when(() => mockStorageService.saveUserId(any())).thenAnswer((_) async => true);
      when(() => mockStorageService.saveUserType(any())).thenAnswer((_) async => true);
      when(() => mockStorageService.saveUserEmail(any())).thenAnswer((_) async => true);
      when(() => mockStorageService.saveUserName(any())).thenAnswer((_) async => true);

      // Execute
      final result = await authService.login(email: email, password: password);

      // Verify
      expect(result['success'], true);
      verify(() => mockStorageService.saveAuthToken('test_access_token')).called(1);
      verify(() => mockStorageService.saveRefreshToken('test_refresh_token')).called(1);
      verify(() => mockStorageService.saveUserId(1)).called(1);
    });

    test('login failure should throw exception', () async {
      // Setup
      when(() => mockApiService.post(any(), data: any(named: 'data')))
          .thenAnswer((_) async => Response(
                requestOptions: RequestOptions(path: ''),
                data: {'success': false, 'message': 'Invalid credentials'},
                statusCode: 200,
              ));

      // Execute & Verify
      expect(
        () => authService.login(email: email, password: password),
        throwsException,
      );
    });
  });

  group('AuthService Logout Tests', () {
    test('logout should clear storage', () async {
      // Setup
      when(() => mockStorageService.getRefreshToken()).thenReturn('refresh_token');
      when(() => mockApiService.post(any(), data: any(named: 'data')))
          .thenAnswer((_) async => Response(
                requestOptions: RequestOptions(path: ''),
                data: {'success': true},
                statusCode: 200,
              ));
      when(() => mockStorageService.clearAuthData()).thenAnswer((_) async => {});

      // Execute
      await authService.logout();

      // Verify
      verify(() => mockStorageService.clearAuthData()).called(1);
    });
  });
}
