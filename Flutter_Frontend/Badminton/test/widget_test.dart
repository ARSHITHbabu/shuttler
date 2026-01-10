import 'package:flutter_test/flutter_test.dart';
import 'package:badminton/main.dart';
import 'package:badminton/core/services/storage_service.dart';

void main() {
  testWidgets('App loads placeholder screen', (WidgetTester tester) async {
    // Initialize storage service for testing
    final storageService = StorageService();
    await storageService.init();

    // Build our app and trigger a frame
    await tester.pumpWidget(MyApp(storageService: storageService));

    // Verify that the placeholder screen loads with app title
    expect(find.text('Badminton Academy'), findsOneWidget);
    expect(find.text('Management System'), findsOneWidget);
    expect(find.text('Phase 1: Foundation Complete ✅'), findsOneWidget);
  });
}
