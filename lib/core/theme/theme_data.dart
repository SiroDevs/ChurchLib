// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../common/utils/app_util.dart';
import '../../common/utils/constants/app_constants.dart';
import '../../domain/repos/pref_repo.dart';
import '../di/injectable.dart';
import 'theme_colors.dart';

class AppTheme {
  AppTheme._();

  static String currentTheme() {
    var prefRepo = getIt<PrefRepo>();
    return getThemeModeString(prefRepo.getThemeMode());
  }

  static const _lightBg = Color(0xFFFBF8F4);
  static const _lightSurface = Color(0xFFFFFFFF);
  static const _lightChrome = Color(0xFFF4ECE0);
  static const _lightOutline = Color(0xFFE5DBCD);

  static const _darkBg = Color(0xFF0F0B0A);
  static const _darkSurface = Color(0xFF171211);
  static const _darkChrome = Color(0xFF201816);
  static const _darkOutline = Color(0xFF3A2E2A);

  static ThemeData lightTheme() {
    final scheme = ColorScheme.fromSeed(
      seedColor: ThemeColors.primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: ThemeColors.primary,
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFFFFE2C2),
      onPrimaryContainer: ThemeColors.primaryDark1,
      secondary: ThemeColors.primary1,
      onSecondary: Colors.white,
      secondaryContainer: _lightChrome,
      onSecondaryContainer: ThemeColors.primaryDark,
      tertiary: ThemeColors.accent2,
      surface: _lightSurface,
      onSurface: const Color(0xFF1E1A18),
      surfaceContainerLowest: _lightBg,
      surfaceContainerLow: _lightBg,
      surfaceContainer: _lightChrome,
      onSurfaceVariant: const Color(0xFF6B5F58),
      outline: const Color(0xFFB8A99B),
      outlineVariant: _lightOutline,
      error: ThemeColors.error,
    );
    return _build(scheme, _lightBg);
  }

  static ThemeData darkTheme() {
    final scheme = ColorScheme.fromSeed(
      seedColor: ThemeColors.primary,
      brightness: Brightness.dark,
    ).copyWith(
      primary: const Color(0xFFF0A24B),
      onPrimary: const Color(0xFF2A1400),
      primaryContainer: ThemeColors.primary3,
      onPrimaryContainer: ThemeColors.accent1,
      secondary: ThemeColors.accent3,
      onSecondary: Colors.black,
      secondaryContainer: _darkChrome,
      onSecondaryContainer: ThemeColors.accent1,
      tertiary: ThemeColors.accent2,
      surface: _darkSurface,
      onSurface: const Color(0xFFF3ECE6),
      surfaceContainerLowest: _darkBg,
      surfaceContainerLow: _darkBg,
      surfaceContainer: _darkChrome,
      onSurfaceVariant: const Color(0xFFBFB2A8),
      outline: const Color(0xFF7A6A60),
      outlineVariant: _darkOutline,
      error: const Color(0xFFFFB4AB),
    );
    return _build(scheme, _darkBg);
  }

  static ThemeData _build(ColorScheme scheme, Color background) {
    final radius = BorderRadius.circular(12);
    final isDark = scheme.brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: scheme.brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      fontFamily: AppConstants.kFontFamily,
      visualDensity: VisualDensity.standard,
      splashFactory: InkSparkle.splashFactory,
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.secondaryContainer,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: AppConstants.kFontFamily,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: scheme.onSurface,
        ),
        iconTheme: IconThemeData(color: scheme.onSurface),
        actionsIconTheme: IconThemeData(color: scheme.onSurface),
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.secondaryContainer,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        indicatorColor: scheme.primary.withValues(alpha: .16),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? scheme.primary
                : scheme.onSurfaceVariant,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontFamily: AppConstants.kFontFamily,
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
            color: states.contains(WidgetState.selected)
                ? scheme.primary
                : scheme.onSurfaceVariant,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: radius),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: radius),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: radius),
          side: BorderSide(color: scheme.outlineVariant),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: radius),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: radius),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: scheme.primary, width: 1.6),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        side: BorderSide(color: scheme.outlineVariant),
        selectedColor: scheme.primary.withValues(alpha: .18),
        backgroundColor: Colors.transparent,
        labelStyle: TextStyle(color: scheme.onSurface),
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: radius),
        iconColor: scheme.onSurfaceVariant,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? scheme.onPrimary
              : scheme.outline,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? scheme.primary
              : scheme.surfaceContainerHighest,
        ),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: scheme.primary,
        thumbColor: scheme.primary,
        inactiveTrackColor: scheme.primary.withValues(alpha: .2),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? const Color(0xFF2B211E) : const Color(0xFF2A211D),
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: radius),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF3A2E2A) : const Color(0xFF2A211D),
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: scheme.primary),
    );
  }
}
