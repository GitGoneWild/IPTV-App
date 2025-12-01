import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watchtheflix/core/constants/app_colors.dart';
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

  group('AppColors', () {
    test('should have correct primary color', () {
      expect(AppColors.primary, equals(const Color(0xFF58A6FF)));
    });

    test('should have correct background color', () {
      expect(AppColors.background, equals(const Color(0xFF0D1117)));
    });

    test('should have correct text primary color', () {
      expect(AppColors.textPrimary, equals(const Color(0xFFE6EDF3)));
    });

    test('should have correct error color', () {
      expect(AppColors.error, equals(const Color(0xFFF85149)));
    });

    test('should have correct success color', () {
      expect(AppColors.success, equals(const Color(0xFF3FB950)));
    });
  });

  group('AppStrings', () {
    test('should have correct app name', () {
      expect(AppStrings.appName, equals('WatchTheFlix'));
    });

    test('should have navigation strings', () {
      expect(AppStrings.navHome, equals('Home'));
      expect(AppStrings.navLiveTV, equals('Live TV'));
      expect(AppStrings.navMovies, equals('Movies'));
      expect(AppStrings.navSeries, equals('Series'));
      expect(AppStrings.navSettings, equals('Settings'));
    });
  });
}
