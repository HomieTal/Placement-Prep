// Basic Flutter widget test for Placement Prep App

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:placement_prep/main.dart';

void main() {
  testWidgets('App should build successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(child: PlacementPrepApp()),
    );

    // Verify that the app builds without errors
    expect(find.byType(PlacementPrepApp), findsOneWidget);
  });
}
