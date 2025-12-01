import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watchtheflix/core/constants/app_colors.dart';
import 'package:watchtheflix/core/constants/app_strings.dart';
import 'package:watchtheflix/core/constants/app_dimensions.dart';

void main() {
  group('AppColors', () {
    test('should have correct primary color', () {
      expect(AppColors.primary, equals(const Color(0xFF58A6FF)));
    });

    test('should have correct background color', () {
      expect(AppColors.background, equals(const Color(0xFF0D1117)));
    });

    test('should have correct background secondary color', () {
      expect(AppColors.backgroundSecondary, equals(const Color(0xFF161B22)));
    });

    test('should have correct text primary color', () {
      expect(AppColors.textPrimary, equals(const Color(0xFFE6EDF3)));
    });

    test('should have correct text secondary color', () {
      expect(AppColors.textSecondary, equals(const Color(0xFF8B949E)));
    });

    test('should have correct error color', () {
      expect(AppColors.error, equals(const Color(0xFFF85149)));
    });

    test('should have correct success color', () {
      expect(AppColors.success, equals(const Color(0xFF3FB950)));
    });

    test('should have correct warning color', () {
      expect(AppColors.warning, equals(const Color(0xFFD29922)));
    });

    test('should have correct accent color', () {
      expect(AppColors.accent, equals(const Color(0xFFA371F7)));
    });

    test('should have correct border color', () {
      expect(AppColors.border, equals(const Color(0xFF30363D)));
    });
  });

  group('AppStrings', () {
    test('should have correct app name', () {
      expect(AppStrings.appName, equals('WatchTheFlix'));
    });

    test('should have correct app tagline', () {
      expect(AppStrings.appTagline, equals('Your Ultimate IPTV Experience'));
    });

    test('should have correct app version', () {
      expect(AppStrings.appVersion, equals('1.0.0'));
    });

    test('should have navigation strings', () {
      expect(AppStrings.navHome, equals('Home'));
      expect(AppStrings.navLiveTV, equals('Live TV'));
      expect(AppStrings.navMovies, equals('Movies'));
      expect(AppStrings.navSeries, equals('Series'));
      expect(AppStrings.navSettings, equals('Settings'));
    });

    test('should have onboarding strings', () {
      expect(AppStrings.onboardingWelcome, equals('Welcome to WatchTheFlix'));
      expect(AppStrings.onboardingSkip, equals('Skip'));
      expect(AppStrings.onboardingNext, equals('Next'));
      expect(AppStrings.onboardingGetStarted, equals('Get Started'));
    });

    test('should have setup strings', () {
      expect(AppStrings.setupTitle, equals('Setup Your IPTV Source'));
      expect(AppStrings.setupM3U, equals('M3U Playlist'));
      expect(AppStrings.setupXtream, equals('Xtream Codes'));
    });

    test('should have settings strings', () {
      expect(AppStrings.settingsTitle, equals('Settings'));
      expect(AppStrings.settingsAccounts, equals('IPTV Accounts'));
      expect(AppStrings.settingsParental, equals('Parental Controls'));
    });

    test('should have message strings', () {
      expect(AppStrings.messageLoading, equals('Loading...'));
      expect(AppStrings.messageError, equals('Something went wrong'));
      expect(AppStrings.messageSuccess, equals('Success'));
    });
  });

  group('AppDimensions', () {
    test('should have correct spacing values', () {
      expect(AppDimensions.spacingXS, equals(4.0));
      expect(AppDimensions.spacingS, equals(8.0));
      expect(AppDimensions.spacingM, equals(12.0));
      expect(AppDimensions.spacingL, equals(16.0));
      expect(AppDimensions.spacingXL, equals(20.0));
      expect(AppDimensions.spacingXXL, equals(24.0));
    });

    test('should have correct padding values', () {
      expect(AppDimensions.paddingS, equals(8.0));
      expect(AppDimensions.paddingM, equals(12.0));
      expect(AppDimensions.paddingL, equals(16.0));
      expect(AppDimensions.paddingXL, equals(20.0));
    });

    test('should have correct border radius values', () {
      expect(AppDimensions.radiusXS, equals(4.0));
      expect(AppDimensions.radiusS, equals(8.0));
      expect(AppDimensions.radiusM, equals(12.0));
      expect(AppDimensions.radiusL, equals(16.0));
    });

    test('should have correct icon sizes', () {
      expect(AppDimensions.iconS, equals(20.0));
      expect(AppDimensions.iconM, equals(24.0));
      expect(AppDimensions.iconL, equals(32.0));
      expect(AppDimensions.iconXL, equals(48.0));
    });

    test('should have correct button dimensions', () {
      expect(AppDimensions.buttonHeightSmall, equals(32.0));
      expect(AppDimensions.buttonHeightMedium, equals(44.0));
      expect(AppDimensions.buttonHeightLarge, equals(56.0));
    });
  });
}
