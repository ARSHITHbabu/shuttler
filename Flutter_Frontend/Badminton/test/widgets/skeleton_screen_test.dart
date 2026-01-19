import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:badminton/widgets/common/skeleton_screen.dart';

void main() {
  group('Skeleton Screen Widget Tests', () {
    testWidgets('ListSkeleton displays correct number of items', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ListSkeleton(itemCount: 5),
          ),
        ),
      );

      // ListSkeleton should render without errors
      expect(find.byType(ListSkeleton), findsOneWidget);
    });

    testWidgets('ListSkeleton respects itemCount parameter', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ListSkeleton(itemCount: 3),
          ),
        ),
      );

      expect(find.byType(ListSkeleton), findsOneWidget);
    });

    testWidgets('DashboardSkeleton renders without errors', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DashboardSkeleton(),
          ),
        ),
      );

      expect(find.byType(DashboardSkeleton), findsOneWidget);
    });

    testWidgets('ProfileSkeleton renders without errors', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProfileSkeleton(),
          ),
        ),
      );

      expect(find.byType(ProfileSkeleton), findsOneWidget);
    });

    testWidgets('GridSkeleton displays correct number of items', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GridSkeleton(itemCount: 6, crossAxisCount: 2),
          ),
        ),
      );

      expect(find.byType(GridSkeleton), findsOneWidget);
    });

    testWidgets('ListSkeleton with hasLeading false works', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ListSkeleton(itemCount: 3, hasLeading: false),
          ),
        ),
      );

      expect(find.byType(ListSkeleton), findsOneWidget);
    });

    testWidgets('ListSkeleton with hasSubtitle false works', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ListSkeleton(itemCount: 3, hasSubtitle: false),
          ),
        ),
      );

      expect(find.byType(ListSkeleton), findsOneWidget);
    });
  });
}
