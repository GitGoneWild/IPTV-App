import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watchtheflix/core/constants/app_strings.dart';
import 'package:watchtheflix/features/onboarding/screens/onboarding_screen.dart';

void main() {
  group('OnboardingScreen', () {
    testWidgets('should display welcome message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: OnboardingScreen(),
        ),
      );

      expect(find.text('Welcome to WatchTheFlix'), findsOneWidget);
    });

    testWidgets('should display skip button', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: OnboardingScreen(),
        ),
      );

      expect(find.text(AppStrings.onboardingSkip), findsOneWidget);
    });

    testWidgets('should display next button', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: OnboardingScreen(),
        ),
      );

      expect(find.text(AppStrings.onboardingNext), findsOneWidget);
    });

    testWidgets('should have 4 page indicators', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: OnboardingScreen(),
        ),
      );

      // Find the page indicators (Container widgets with specific decoration)
      final indicators = find.byWidgetPredicate(
        (widget) =>
            widget is AnimatedContainer &&
            widget.constraints?.maxHeight == 8,
      );

      expect(indicators, findsNWidgets(4));
    });

    testWidgets('should navigate to next page on next button tap',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: OnboardingScreen(),
        ),
      );

      // Initially on first page
      expect(find.text('Welcome to WatchTheFlix'), findsOneWidget);

      // Tap next
      await tester.tap(find.text(AppStrings.onboardingNext));
      await tester.pumpAndSettle();

      // Should show second page content
      expect(find.text('Movies & Series'), findsOneWidget);
    });
  });
}
