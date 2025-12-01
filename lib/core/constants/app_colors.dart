import 'package:flutter/material.dart';

/// WatchTheFlix color palette inspired by GitHub's dark theme
abstract class AppColors {
  // Primary colors
  static const Color primary = Color(0xFF58A6FF);
  static const Color primaryLight = Color(0xFF79C0FF);
  static const Color primaryDark = Color(0xFF388BFD);

  // Background colors
  static const Color background = Color(0xFF0D1117);
  static const Color backgroundSecondary = Color(0xFF161B22);
  static const Color backgroundTertiary = Color(0xFF21262D);
  static const Color backgroundElevated = Color(0xFF30363D);

  // Surface colors
  static const Color surface = Color(0xFF161B22);
  static const Color surfaceLight = Color(0xFF21262D);
  static const Color surfaceDark = Color(0xFF0D1117);

  // Border colors
  static const Color border = Color(0xFF30363D);
  static const Color borderLight = Color(0xFF484F58);
  static const Color borderFocus = Color(0xFF58A6FF);

  // Text colors
  static const Color textPrimary = Color(0xFFE6EDF3);
  static const Color textSecondary = Color(0xFF8B949E);
  static const Color textTertiary = Color(0xFF6E7681);
  static const Color textLink = Color(0xFF58A6FF);

  // Semantic colors
  static const Color success = Color(0xFF3FB950);
  static const Color successLight = Color(0xFF56D364);
  static const Color warning = Color(0xFFD29922);
  static const Color warningLight = Color(0xFFE3B341);
  static const Color error = Color(0xFFF85149);
  static const Color errorLight = Color(0xFFFF7B72);
  static const Color info = Color(0xFF58A6FF);

  // Accent colors
  static const Color accent = Color(0xFFA371F7);
  static const Color accentLight = Color(0xFFBC8CFF);

  // Card colors
  static const Color cardBackground = Color(0xFF161B22);
  static const Color cardHover = Color(0xFF21262D);

  // Overlay colors
  static const Color overlay = Color(0xB30D1117); // 70% opacity
  static const Color overlayLight = Color(0x800D1117); // 50% opacity

  // Gradient colors
  static const Color gradientStart = Color(0xFF58A6FF);
  static const Color gradientEnd = Color(0xFFA371F7);

  // Player colors
  static const Color playerBackground = Color(0xFF000000);
  static const Color playerControls = Color(0xB3FFFFFF); // 70% opacity
  static const Color playerProgress = Color(0xFF58A6FF);
  static const Color playerBuffer = Color(0xFF484F58);

  // Category colors (for content categories)
  static const Color categoryMovies = Color(0xFFF85149);
  static const Color categorySeries = Color(0xFF58A6FF);
  static const Color categoryLive = Color(0xFF3FB950);
  static const Color categorySports = Color(0xFFD29922);
  static const Color categoryNews = Color(0xFFA371F7);
  static const Color categoryKids = Color(0xFFBC8CFF);
}
