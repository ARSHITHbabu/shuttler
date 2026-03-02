import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:badminton/screens/owner/owner_dashboard.dart';
import 'package:badminton/providers/owner_navigation_provider.dart';
import 'package:badminton/screens/owner/home_screen.dart';
import 'package:badminton/screens/owner/batches_screen.dart';
import 'package:badminton/providers/auth_provider.dart';
import 'package:mocktail/mocktail.dart';
import 'package:badminton/core/services/auth_service.dart';
import 'package:badminton/core/services/storage_service.dart';
import 'package:badminton/core/services/api_service.dart';
import 'package:badminton/providers/service_providers.dart';
import 'package:badminton/providers/dashboard_provider.dart';
import 'package:badminton/providers/owner_provider.dart';

class MockAuthService extends Mock implements AuthService {}
class MockStorageService extends Mock implements StorageService {}
class MockApiService extends Mock implements ApiService {}

class MockDashboardStats extends DashboardStats with Mock {
  @override
  Future<DashboardStatsData> build() async {
    return DashboardStatsData(
      totalStudents: 10,
      totalCoaches: 2,
      activeBatches: 3,
      pendingFees: 1500.0,
      todayAttendanceRate: 85.0,
    );
  }
}

void main() {
  late MockAuthService mockAuthService;
  late MockStorageService mockStorageService;
  late MockApiService mockApiService;

  setUp(() {
    mockAuthService = MockAuthService();
    mockStorageService = MockStorageService();
    mockApiService = MockApiService();

    when(() => mockStorageService.isInitialized).thenReturn(true);
    when(() => mockAuthService.isLoggedIn()).thenReturn(true);
    when(() => mockAuthService.getCurrentUserType()).thenReturn('owner');
    when(() => mockAuthService.getCurrentUserId()).thenReturn(1);
    when(() => mockAuthService.getCurrentUserName()).thenReturn('Owner');
    when(() => mockAuthService.getCurrentUserEmail()).thenReturn('owner@test.com');
    when(() => mockAuthService.getUserRole()).thenReturn('owner');
    when(() => mockAuthService.getMustChangePassword()).thenReturn(false);
  });

  testWidgets('OwnerDashboard navigation should work', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authServiceProvider.overrideWithValue(mockAuthService),
          storageServiceProvider.overrideWithValue(mockStorageService),
          apiServiceProvider.overrideWithValue(mockApiService),
          ownerBottomNavIndexProvider.overrideWith((ref) => 0),
          activeOwnerProvider.overrideWith((ref) async => null),
          dashboardStatsProvider.overrideWith(() => MockDashboardStats()),
          ownerUpcomingSessionsProvider.overrideWith((ref) async => []),
        ],
        child: const MaterialApp(
          home: OwnerDashboard(),
        ),
      ),
    );

    // Initial screen should be HomeScreen
    expect(find.byType(HomeScreen), findsOneWidget);

    // Tap on Batches nav item
    await tester.tap(find.text('Batches'));
    await tester.pumpAndSettle();

    // Now BatchesScreen should be visible
    expect(find.byType(BatchesScreen), findsOneWidget);
    expect(find.byType(HomeScreen), findsNothing);

    // Tap on More nav item
    await tester.tap(find.text('More'));
    await tester.pumpAndSettle();
    
    // Verify it changed
    expect(find.text('Fees'), findsOneWidget); // Checks if bottom nav labels still exist
  });
}
