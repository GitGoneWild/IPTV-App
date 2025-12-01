import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_text_styles.dart';

/// WatchTheFlix app theme configuration
class AppTheme {
  /// Dark theme (default)
  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: _darkColorScheme,
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: _appBarTheme,
        cardTheme: _cardTheme,
        elevatedButtonTheme: _elevatedButtonTheme,
        outlinedButtonTheme: _outlinedButtonTheme,
        textButtonTheme: _textButtonTheme,
        inputDecorationTheme: _inputDecorationTheme,
        textTheme: _textTheme,
        iconTheme: _iconTheme,
        bottomNavigationBarTheme: _bottomNavigationBarTheme,
        navigationRailTheme: _navigationRailTheme,
        dividerTheme: _dividerTheme,
        dialogTheme: _dialogTheme,
        snackBarTheme: _snackBarTheme,
        chipTheme: _chipTheme,
        tabBarTheme: _tabBarTheme,
        progressIndicatorTheme: _progressIndicatorTheme,
        sliderTheme: _sliderTheme,
        switchTheme: _switchTheme,
        checkboxTheme: _checkboxTheme,
        listTileTheme: _listTileTheme,
        drawerTheme: _drawerTheme,
        tooltipTheme: _tooltipTheme,
        popupMenuTheme: _popupMenuTheme,
      );

  // Color Scheme
  static ColorScheme get _darkColorScheme => const ColorScheme.dark(
        primary: AppColors.primary,
        onPrimary: AppColors.textPrimary,
        primaryContainer: AppColors.primaryDark,
        onPrimaryContainer: AppColors.textPrimary,
        secondary: AppColors.accent,
        onSecondary: AppColors.textPrimary,
        secondaryContainer: AppColors.accent,
        onSecondaryContainer: AppColors.textPrimary,
        tertiary: AppColors.success,
        onTertiary: AppColors.textPrimary,
        error: AppColors.error,
        onError: AppColors.textPrimary,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        surfaceContainerHighest: AppColors.surfaceLight,
        outline: AppColors.border,
        outlineVariant: AppColors.borderLight,
        shadow: AppColors.background,
        inverseSurface: AppColors.textPrimary,
        onInverseSurface: AppColors.background,
      );

  // AppBar Theme
  static AppBarTheme get _appBarTheme => AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.titleLarge.copyWith(
          color: AppColors.textPrimary,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.textPrimary,
          size: AppDimensions.iconM,
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: AppColors.background,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      );

  // Card Theme
  static CardTheme get _cardTheme => CardTheme(
        color: AppColors.cardBackground,
        elevation: AppDimensions.cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        ),
        margin: EdgeInsets.zero,
      );

  // Elevated Button Theme
  static ElevatedButtonThemeData get _elevatedButtonTheme =>
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textPrimary,
          disabledBackgroundColor: AppColors.backgroundTertiary,
          disabledForegroundColor: AppColors.textTertiary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingXL,
            vertical: AppDimensions.paddingM,
          ),
          minimumSize: const Size(
            AppDimensions.buttonWidthMin,
            AppDimensions.buttonHeightMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusS),
          ),
          textStyle: AppTextStyles.labelLarge,
        ),
      );

  // Outlined Button Theme
  static OutlinedButtonThemeData get _outlinedButtonTheme =>
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          disabledForegroundColor: AppColors.textTertiary,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingXL,
            vertical: AppDimensions.paddingM,
          ),
          minimumSize: const Size(
            AppDimensions.buttonWidthMin,
            AppDimensions.buttonHeightMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusS),
            side: const BorderSide(color: AppColors.border),
          ),
          side: const BorderSide(color: AppColors.border),
          textStyle: AppTextStyles.labelLarge,
        ),
      );

  // Text Button Theme
  static TextButtonThemeData get _textButtonTheme => TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          disabledForegroundColor: AppColors.textTertiary,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingL,
            vertical: AppDimensions.paddingS,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusS),
          ),
          textStyle: AppTextStyles.labelLarge,
        ),
      );

  // Input Decoration Theme
  static InputDecorationTheme get _inputDecorationTheme => InputDecorationTheme(
        filled: true,
        fillColor: AppColors.backgroundSecondary,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingL,
          vertical: AppDimensions.paddingM,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
          borderSide: const BorderSide(
            color: AppColors.borderFocus,
            width: AppDimensions.inputBorderWidthFocus,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: AppDimensions.inputBorderWidthFocus,
          ),
        ),
        labelStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textTertiary,
        ),
        errorStyle: AppTextStyles.bodySmall.copyWith(
          color: AppColors.error,
        ),
        prefixIconColor: AppColors.textSecondary,
        suffixIconColor: AppColors.textSecondary,
      );

  // Text Theme
  static TextTheme get _textTheme => TextTheme(
        displayLarge:
            AppTextStyles.displayLarge.copyWith(color: AppColors.textPrimary),
        displayMedium:
            AppTextStyles.displayMedium.copyWith(color: AppColors.textPrimary),
        displaySmall:
            AppTextStyles.displaySmall.copyWith(color: AppColors.textPrimary),
        headlineLarge:
            AppTextStyles.headlineLarge.copyWith(color: AppColors.textPrimary),
        headlineMedium:
            AppTextStyles.headlineMedium.copyWith(color: AppColors.textPrimary),
        headlineSmall:
            AppTextStyles.headlineSmall.copyWith(color: AppColors.textPrimary),
        titleLarge:
            AppTextStyles.titleLarge.copyWith(color: AppColors.textPrimary),
        titleMedium:
            AppTextStyles.titleMedium.copyWith(color: AppColors.textPrimary),
        titleSmall:
            AppTextStyles.titleSmall.copyWith(color: AppColors.textPrimary),
        bodyLarge:
            AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimary),
        bodyMedium:
            AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
        bodySmall:
            AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
        labelLarge:
            AppTextStyles.labelLarge.copyWith(color: AppColors.textPrimary),
        labelMedium:
            AppTextStyles.labelMedium.copyWith(color: AppColors.textPrimary),
        labelSmall:
            AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary),
      );

  // Icon Theme
  static IconThemeData get _iconTheme => const IconThemeData(
        color: AppColors.textPrimary,
        size: AppDimensions.iconM,
      );

  // Bottom Navigation Bar Theme
  static BottomNavigationBarThemeData get _bottomNavigationBarTheme =>
      const BottomNavigationBarThemeData(
        backgroundColor: AppColors.backgroundSecondary,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: AppTextStyles.labelSmall,
        unselectedLabelStyle: AppTextStyles.labelSmall,
      );

  // Navigation Rail Theme
  static NavigationRailThemeData get _navigationRailTheme =>
      NavigationRailThemeData(
        backgroundColor: AppColors.backgroundSecondary,
        selectedIconTheme: const IconThemeData(
          color: AppColors.primary,
          size: AppDimensions.iconM,
        ),
        unselectedIconTheme: const IconThemeData(
          color: AppColors.textSecondary,
          size: AppDimensions.iconM,
        ),
        selectedLabelTextStyle: AppTextStyles.labelSmall.copyWith(
          color: AppColors.primary,
        ),
        unselectedLabelTextStyle: AppTextStyles.labelSmall.copyWith(
          color: AppColors.textSecondary,
        ),
        indicatorColor: AppColors.primary.withValues(alpha: 0.1),
      );

  // Divider Theme
  static DividerThemeData get _dividerTheme => const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      );

  // Dialog Theme
  static DialogTheme get _dialogTheme => DialogTheme(
        backgroundColor: AppColors.backgroundSecondary,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        ),
        titleTextStyle:
            AppTextStyles.titleLarge.copyWith(color: AppColors.textPrimary),
        contentTextStyle:
            AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
      );

  // SnackBar Theme
  static SnackBarThemeData get _snackBarTheme => SnackBarThemeData(
        backgroundColor: AppColors.backgroundTertiary,
        contentTextStyle:
            AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        ),
      );

  // Chip Theme
  static ChipThemeData get _chipTheme => ChipThemeData(
        backgroundColor: AppColors.backgroundTertiary,
        selectedColor: AppColors.primary,
        disabledColor: AppColors.backgroundSecondary,
        labelStyle:
            AppTextStyles.labelMedium.copyWith(color: AppColors.textPrimary),
        secondaryLabelStyle:
            AppTextStyles.labelMedium.copyWith(color: AppColors.textPrimary),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingM,
          vertical: AppDimensions.paddingXS,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusRound),
          side: const BorderSide(color: AppColors.border),
        ),
      );

  // Tab Bar Theme
  static TabBarTheme get _tabBarTheme => TabBarTheme(
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: AppTextStyles.labelLarge,
        unselectedLabelStyle: AppTextStyles.labelLarge,
        indicatorColor: AppColors.primary,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: AppColors.border,
      );

  // Progress Indicator Theme
  static ProgressIndicatorThemeData get _progressIndicatorTheme =>
      const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.backgroundTertiary,
        circularTrackColor: AppColors.backgroundTertiary,
      );

  // Slider Theme
  static SliderThemeData get _sliderTheme => SliderThemeData(
        activeTrackColor: AppColors.primary,
        inactiveTrackColor: AppColors.backgroundTertiary,
        thumbColor: AppColors.primary,
        overlayColor: AppColors.primary.withValues(alpha: 0.1),
        trackHeight: 4,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
      );

  // Switch Theme
  static SwitchThemeData get _switchTheme => SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.textSecondary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary.withValues(alpha: 0.4);
          }
          return AppColors.backgroundTertiary;
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      );

  // Checkbox Theme
  static CheckboxThemeData get _checkboxTheme => CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(AppColors.textPrimary),
        side: const BorderSide(color: AppColors.border, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusXS),
        ),
      );

  // List Tile Theme
  static ListTileThemeData get _listTileTheme => ListTileThemeData(
        tileColor: Colors.transparent,
        selectedTileColor: AppColors.primary.withValues(alpha: 0.1),
        iconColor: AppColors.textSecondary,
        selectedColor: AppColors.primary,
        textColor: AppColors.textPrimary,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingL,
          vertical: AppDimensions.paddingXS,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        ),
      );

  // Drawer Theme
  static DrawerThemeData get _drawerTheme => DrawerThemeData(
        backgroundColor: AppColors.backgroundSecondary,
        scrimColor: AppColors.overlay,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(AppDimensions.radiusL),
            bottomRight: Radius.circular(AppDimensions.radiusL),
          ),
        ),
      );

  // Tooltip Theme
  static TooltipThemeData get _tooltipTheme => TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.backgroundElevated,
          borderRadius: BorderRadius.circular(AppDimensions.radiusXS),
        ),
        textStyle:
            AppTextStyles.bodySmall.copyWith(color: AppColors.textPrimary),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingS,
          vertical: AppDimensions.paddingXS,
        ),
      );

  // Popup Menu Theme
  static PopupMenuThemeData get _popupMenuTheme => PopupMenuThemeData(
        color: AppColors.backgroundSecondary,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
          side: const BorderSide(color: AppColors.border),
        ),
        textStyle:
            AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
      );
}
