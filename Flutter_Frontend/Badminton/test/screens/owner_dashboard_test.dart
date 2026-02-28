import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:badminton/screens/owner/owner_dashboard.dart';
import 'package:badminton/providers/owner_navigation_provider.dart';
import 'package:badminton/screens/owner/home_screen.dart';
import 'package:badminton/screens/owner/batches_screen.dart';
import 'package:badminton/providers/auth_provider.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthNotifier extends _$Auth with Mock implements Auth {}

void main() {
  testWidgets('OwnerDashboard navigation should work', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
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
