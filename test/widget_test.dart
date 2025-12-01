// Basic Flutter widget test for the WatchTheFlix app.
//
// This test verifies the app can be instantiated and shows a loading indicator
// during initialization.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:watchtheflix/app.dart';

void main() {
  testWidgets('App shows loading indicator during initialization',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const WatchTheFlixApp());

    // While initializing, should show a loading indicator.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
